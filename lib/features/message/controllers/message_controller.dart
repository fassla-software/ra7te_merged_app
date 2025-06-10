import 'dart:convert';
import 'dart:io';
import 'package:dart_pusher_channels/dart_pusher_channels.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ride_sharing_user_app/data/api_checker.dart';
import 'package:ride_sharing_user_app/data/api_client.dart';
import 'package:ride_sharing_user_app/features/auth/controllers/auth_controller.dart';
import 'package:ride_sharing_user_app/features/message/domain/services/message_service_interface.dart';
import 'package:ride_sharing_user_app/features/message/screens/message_screen.dart';
import 'package:ride_sharing_user_app/features/message/domain/models/channel_model.dart';
import 'package:ride_sharing_user_app/features/message/domain/models/message_model.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'package:ride_sharing_user_app/helper/pusher_helper.dart';
import 'package:path/path.dart' as path;
import 'dart:async';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:ride_sharing_user_app/lib2/common_widgets/snackbar_widget.dart';

class MessageController extends GetxController implements GetxService {
  final MessageServiceInterface messageServiceInterface;
  MessageController({required this.messageServiceInterface});

  List<XFile>? _pickedImageFiles = [];
  List<XFile>? get pickedImageFile => _pickedImageFiles;
  bool isLoading = false;

  FilePickerResult? _otherFile;
  FilePickerResult? get otherFile => _otherFile;

  File? _file;
  PlatformFile? objFile;
  File? get file => _file;

  // Voice recording variables with audio_waveforms
  final RecorderController recorderController = RecorderController();
  List<File> _voiceFiles = [];
  List<File> get voiceFiles => _voiceFiles;
  List<PlatformFile> _voicePlatformFiles = [];
  List<PlatformFile> get voicePlatformFiles => _voicePlatformFiles;
  List<MultipartBody> _selectedVoiceList = [];
  List<MultipartBody> get selectedVoiceList => _selectedVoiceList;

  // Voice playback controllers for each recording
  List<PlayerController> _playerControllers = [];
  List<PlayerController> get playerControllers => _playerControllers;

  // Current recording state
  bool _isRecording = false;
  bool get isRecording => _isRecording;
  bool _isRecordingLocked = false;
  bool get isRecordingLocked => _isRecordingLocked;
  bool _showLockIcon = false;
  bool get showLockIcon => _showLockIcon;
  Duration _recordingDuration = Duration.zero;
  Duration get recordingDuration => _recordingDuration;
  Timer? _recordingTimer;

  // Voice playback control
  bool _isPlayingVoice = false;
  bool get isPlayingVoice => _isPlayingVoice;
  int _playingVoiceIndex = -1;
  int get playingVoiceIndex => _playingVoiceIndex;

  List<MultipartBody> _selectedImageList = [];
  List<MultipartBody> get selectedImageList => _selectedImageList;

  final List<dynamic> _conversationList = [];
  List<dynamic> get conversationList => _conversationList;

  final bool _paginationLoading = true;
  bool get paginationLoading => _paginationLoading;

  final String _name = '';
  String get name => _name;
  final String _image = '';
  String get image => _image;

  var conversationController = TextEditingController();
  final GlobalKey<FormState> conversationKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    conversationController.text = '';
    _initializeRecorder();
  }

  @override
  void onClose() {
    _recordingTimer?.cancel();
    recorderController.dispose();
    for (var player in _playerControllers) {
      player.dispose();
    }
    super.onClose();
  }

  bool isImagePicked = false;

  void pickMultipleImage(bool isRemove, {int? index}) async {
    if (isRemove) {
      if (index != null) {
        _pickedImageFiles!.removeAt(index);
        _selectedImageList.removeAt(index);
      }
    } else {
      isImagePicked = true;
      Future.delayed(const Duration(seconds: 1)).then((value) {
        update();
      });
      _pickedImageFiles = await ImagePicker().pickMultiImage(imageQuality: 40);
      if (_pickedImageFiles != null) {
        for (int i = 0; i < _pickedImageFiles!.length; i++) {
          _selectedImageList
              .add(MultipartBody('files[$i]', _pickedImageFiles![i]));
        }
      }
      isImagePicked = false;
    }
    update();
  }

  bool permissionGranted = false;

  Future getStoragePermission() async {
    if (await Permission.storage.request().isGranted) {
      permissionGranted = true;
    } else if (await Permission.storage.request().isPermanentlyDenied) {
      await openAppSettings();
    } else if (await Permission.storage.request().isDenied) {
      await openAppSettings();
      Permission.storage.request();
    }
    update();
  }

  void pickOtherFile(bool isRemove) async {
    if (isRemove) {
      _otherFile = null;
      _file = null;
    } else {
      _otherFile = (await FilePicker.platform.pickFiles())!;
      if (_otherFile != null) {
        objFile = _otherFile!.files.single;
      }
    }
    update();
  }

  void removeFile() async {
    _otherFile = null;
    update();
  }

  cleanOldData() {
    _pickedImageFiles = [];
    _selectedImageList = [];
    _otherFile = null;
    _file = null;
    // Clean up voice files
    try {
      for (var file in _voiceFiles) {
        if (file.existsSync()) {
          file.delete();
        }
      }
    } catch (e) {
      print('Error cleaning voice files: $e');
    }
    _voiceFiles = [];
    _voicePlatformFiles = [];
    _selectedVoiceList = [];
    _playerControllers = [];
  }

  ChannelModel? channelModel;

  Future<void> getChannelList(int offset) async {
    Response response = await messageServiceInterface.getChannelList(offset);
    if (response.statusCode == 200) {
      if (offset == 1) {
        channelModel = ChannelModel.fromJson(response.body);
      } else {
        channelModel!.totalSize =
            ChannelModel.fromJson(response.body).totalSize;
        channelModel!.offset = ChannelModel.fromJson(response.body).offset;
        channelModel!.data!.addAll(ChannelModel.fromJson(response.body).data!);
      }
      isLoading = false;
    } else {
      ApiChecker.checkApi(response);
    }
    update();
  }

  Future<void> createChannel(String userId, String? tripId) async {
    isLoading = true;
    Response response =
        await messageServiceInterface.createChannel(userId, tripId!);
    if (response.statusCode == 200) {
      isLoading = false;
      Map map = response.body;
      String channelId = map['data']['channel']['id'];
      String tripId = map['data']['channel']['trip_id'];
      Get.to(() => MessageScreen(
            channelId: channelId,
            tripId: tripId,
            userName: map['data']['user']['first_name'] +
                ' ' +
                map['data']['user']['last_name'],
          ));
    } else {
      isLoading = false;
      ApiChecker.checkApi(response);
    }
    update();
  }

  MessageModel? messageModel;
  Future<void> getConversation(String channelId, int offset) async {
    isLoading = true;
    Response response =
        await messageServiceInterface.getConversation(channelId, offset);
    if (response.statusCode == 200) {
      if (offset == 1) {
        messageModel = MessageModel.fromJson(response.body);
      } else {
        messageModel!.totalSize =
            MessageModel.fromJson(response.body).totalSize;
        messageModel!.offset = MessageModel.fromJson(response.body).offset;
        messageModel!.data!.addAll(MessageModel.fromJson(response.body).data!);
      }
      isLoading = false;
    } else {
      isLoading = false;
      ApiChecker.checkApi(response);
    }
    update();
  }

  bool isSending = false;
  Future<void> sendMessage(String channelId, String tripId) async {
    isSending = true;
    update();

    // Send voice recordings first (one by one if multiple)
    if (_voicePlatformFiles.isNotEmpty) {
      for (int i = 0; i < _voicePlatformFiles.length; i++) {
        Response voiceResponse = await messageServiceInterface.sendMessage(
            '', // Empty text for voice-only message
            channelId,
            tripId,
            [], // No images for voice message
            null, // No other files
            _voicePlatformFiles[i] // Voice file
            );

        if (voiceResponse.statusCode != 200) {
          isSending = false;
          SnackBarWidget('failed_to_send_voice_message'.tr);
          update();
          return;
        }

        // Small delay between voice messages
        await Future.delayed(Duration(milliseconds: 200));
      }
    }
    // Send text message with images and other files (if any)
    if (conversationController.value.text.trim().isNotEmpty ||
        _selectedImageList.isNotEmpty ||
        objFile != null) {
      Response response = await messageServiceInterface.sendMessage(
          conversationController.value.text,
          channelId,
          tripId,
          _selectedImageList,
          objFile,
          null); // No voice for this call

      if (response.statusCode != 200) {
        isSending = false;
        if (response.statusCode == 400) {
          String message = response.body['errors'][0]['message'];
          if (message.contains("png  jpg  jpeg  csv  txt  xlx  xls  pdf")) {
            message = "the_files_types_must_be";
          }
          if (message.contains("failed to upload")) {
            message = "failed_to_upload";
          }
          showCustomSnackBar(message.tr);
        } else {
          ApiChecker.checkApi(response);
        }
        _clearAllInputData();
        update();
        return;
      }
    }

    // Success - reload conversation and clean up
    isSending = false;
    getConversation(channelId, 1);
    _clearAllInputData();
    update();
  }

  void _clearAllInputData() {
    conversationController.text = '';
    _pickedImageFiles = [];
    _selectedImageList = [];
    _otherFile = null;
    objFile = null;
    _file = null;
    clearAllVoiceRecordings();
  }

  late PrivateChannel channel;
  String id = "";

  void subscribeMessageChannel(String tripId) {
    id = "";
    if (id == "") {
      id = tripId;
    }

    if (Get.find<ConfigController>().pusherConnectionStatus != null ||
        Get.find<ConfigController>().pusherConnectionStatus == 'Connected') {
      channel = PusherHelper.pusherClient!.privateChannel(
          "private-customer-ride-chat.$id",
          authorizationDelegate:
              EndpointAuthorizableChannelTokenAuthorizationDelegate
                  .forPrivateChannel(
            authorizationEndpoint: Uri.parse(
                'https://${Get.find<ConfigController>().config!.webSocketUrl}/broadcasting/auth'),
            headers: {
              "Accept": "application/json",
              "Authorization":
                  "Bearer ${Get.find<AuthController>().getUserToken()}",
              "Access-Control-Allow-Origin": "*",
              'Access-Control-Allow-Methods': "PUT, GET, POST, DELETE, OPTIONS"
            },
          ));

      if (channel.currentStatus == null) {
        channel.subscribe();
        channel.bind("customer-ride-chat.$id").listen((event) {
          if (id ==
              jsonDecode(event.data!)['channel_conversation']['channel']
                  ['trip_id']) {
            messageModel!.data!.insert(
                0,
                Message.fromJson(
                    jsonDecode(event.data!)['channel_conversation']));
            update();
          }
        });
      }
    }
  }

  bool _channelRideStatus = true;
  bool get channelRideStatus => _channelRideStatus;
  void findChannelRideStatus(String channelId) async {
    Response response =
        await messageServiceInterface.findChannelRideStatus(channelId);
    if (response.body['data'] == "cancelled" ||
        response.body['data'] == 'completed') {
      _channelRideStatus = false;
    } else {
      _channelRideStatus = true;
    }
    update();
  }

  // Initialize recorder
  void _initializeRecorder() async {
    await recorderController.checkPermission();
    recorderController.updateFrequency = const Duration(milliseconds: 100);
  }

  // Voice recording methods with audio_waveforms
  Future<void> startRecording() async {
    if (await recorderController.checkPermission()) {
      _isRecording = true;
      _recordingDuration = Duration.zero;
      _startRecordingTimer();

      // Generate unique filename
      String fileName = 'voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      String appDocPath = Directory.systemTemp.path;
      String filePath = '$appDocPath/$fileName';

      await recorderController.record(path: filePath);
      update();
    }
  }

  Future<void> stopRecording(
      {String? channelId, String? tripId, bool autoSend = false}) async {
    if (_isRecording) {
      _isRecording = false;
      _isRecordingLocked = false;
      _showLockIcon = false;
      _stopRecordingTimer();

      String? filePath = await recorderController.stop();
      if (filePath != null) {
        await _addVoiceRecording(filePath);

        // Auto-send if parameters are provided
        if (autoSend && channelId != null && tripId != null) {
          await autoSendVoiceRecording(channelId, tripId);
        }
      }
      update();
    }
  }

  Future<void> pauseRecording() async {
    if (_isRecording) {
      await recorderController.pause();
      update();
    }
  }

  Future<void> resumeRecording() async {
    if (_isRecording) {
      await recorderController.record();
      update();
    }
  }

  void cancelRecording() async {
    if (_isRecording) {
      _isRecording = false;
      _isRecordingLocked = false;
      _showLockIcon = false;
      _stopRecordingTimer();
      recorderController.reset();
      showCustomSnackBar('recording_cancelled'.tr);
      update();
    }
  }

  void lockRecording() {
    _isRecordingLocked = true;
    _showLockIcon = false;
    update();
  }

  // Add voice recording to list
  Future<void> _addVoiceRecording(String filePath) async {
    try {
      File voiceFile = File(filePath);
      if (voiceFile.existsSync()) {
        _voiceFiles.add(voiceFile);

        PlatformFile platformFile = PlatformFile(
          name: path.basename(filePath),
          path: filePath,
          size: voiceFile.lengthSync(),
          readStream: voiceFile.openRead(),
        );
        _voicePlatformFiles.add(platformFile);

        // Add to selected voice list for sending
        _selectedVoiceList.add(MultipartBody(
            'voice_files[${_voiceFiles.length - 1}]', XFile(filePath)));

        // Create player controller for playback
        PlayerController playerController = PlayerController();
        await playerController.preparePlayer(path: filePath);
        _playerControllers.add(playerController);

        print('📱 Voice recording added: $filePath');
        showCustomSnackBar('voice_message_recorded'.tr);
      }
    } catch (e) {
      print('❌ Error adding voice recording: $e');
      showCustomSnackBar('recording_error'.tr + ': ${e.toString()}');
    }
  }

  // Voice playback methods
  Future<void> playVoiceRecording(int index) async {
    if (index >= 0 && index < _playerControllers.length) {
      // Stop any currently playing audio
      if (_playingVoiceIndex != -1 &&
          _playingVoiceIndex < _playerControllers.length) {
        await _playerControllers[_playingVoiceIndex].stopPlayer();
      }

      _isPlayingVoice = true;
      _playingVoiceIndex = index;
      await _playerControllers[index].startPlayer();
      update();
    }
  }

  Future<void> stopVoicePlayback() async {
    if (_playingVoiceIndex != -1 &&
        _playingVoiceIndex < _playerControllers.length) {
      await _playerControllers[_playingVoiceIndex].stopPlayer();
      _isPlayingVoice = false;
      _playingVoiceIndex = -1;
      update();
    }
  }

  Future<void> pauseVoicePlayback() async {
    if (_playingVoiceIndex != -1 &&
        _playingVoiceIndex < _playerControllers.length) {
      await _playerControllers[_playingVoiceIndex].pausePlayer();
      _isPlayingVoice = false;
      update();
    }
  }

  // Remove voice recording
  void removeVoiceFile(int index) async {
    try {
      if (_voiceFiles.isNotEmpty && index >= 0 && index < _voiceFiles.length) {
        // Dispose player controller
        if (index < _playerControllers.length) {
          _playerControllers[index].dispose();
          _playerControllers.removeAt(index);
        }

        // Delete file
        await _voiceFiles[index].delete();
        _voiceFiles.removeAt(index);
        _voicePlatformFiles.removeAt(index);

        if (index < _selectedVoiceList.length) {
          _selectedVoiceList.removeAt(index);
        }
      }
    } catch (e) {
      print('Error deleting voice file: $e');
    }
    update();
  }

  // Clear all voice recordings
  void clearAllVoiceRecordings() async {
    try {
      // Dispose all player controllers
      for (var player in _playerControllers) {
        player.dispose();
      }

      // Delete all files
      for (var file in _voiceFiles) {
        if (file.existsSync()) {
          await file.delete();
        }
      }
    } catch (e) {
      print('Error clearing voice files: $e');
    }

    _voiceFiles.clear();
    _voicePlatformFiles.clear();
    _selectedVoiceList.clear();
    _playerControllers.clear();
    _isPlayingVoice = false;
    _playingVoiceIndex = -1;
    update();
  }

  // Auto-send voice recording
  Future<void> autoSendVoiceRecording(String channelId, String tripId) async {
    if (_voicePlatformFiles.isNotEmpty) {
      await sendMessage(channelId, tripId);
    }
  }

  // Get voice recording duration
  String getVoiceRecordingDuration(int index) {
    if (index >= 0 && index < _playerControllers.length) {
      // This is a placeholder - you can get actual duration from the player
      return "0:30"; // Replace with actual duration from playerController
    }
    return "0:00";
  }

  // Check if there are any voice recordings
  bool get hasVoiceRecordings => _voiceFiles.isNotEmpty;

  void _startRecordingTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      _recordingDuration = Duration(seconds: timer.tick);
      update();
    });
  }

  void _stopRecordingTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = null;
  }

  String get formattedRecordingDuration {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes =
        twoDigits(_recordingDuration.inMinutes.remainder(60));
    String twoDigitSeconds =
        twoDigits(_recordingDuration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}
