import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ride_sharing_user_app/lib2/common_widgets/popup_banner/popup_banner.dart';
import 'package:ride_sharing_user_app/lib2/helper/date_converter.dart';
import 'package:ride_sharing_user_app/lib2/localization/localization_controller.dart';
import 'package:ride_sharing_user_app/lib2/util/dimensions.dart';
import 'package:ride_sharing_user_app/lib2/util/images.dart';
import 'package:ride_sharing_user_app/lib2/util/styles.dart';
import 'package:ride_sharing_user_app/lib2/features/chat/domain/models/message_model.dart';
import 'package:ride_sharing_user_app/lib2/features/profile/controllers/profile_controller.dart';
import 'package:ride_sharing_user_app/lib2/features/splash/controllers/splash_controller.dart';
import 'package:ride_sharing_user_app/lib2/common_widgets/image_widget.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:http/http.dart' as http;

class ConversationBubbleWidget extends StatefulWidget {
  final Message message;
  final Message? previousMessage;
  final int index;
  final int length;
  const ConversationBubbleWidget(
      {super.key,
      required this.message,
      this.previousMessage,
      required this.index,
      required this.length});
  @override
  State<ConversationBubbleWidget> createState() =>
      _ConversationBubbleWidgetState();
}

class _ConversationBubbleWidgetState extends State<ConversationBubbleWidget> {
  List<String> images = [];

  // Voice message playback variables
  Map<int, PlayerController> voicePlayerControllers = {};
  Map<int, bool> voicePlayingStates = {};
  Map<int, bool> voiceLoadingStates = {};
  Map<int, String?> voiceLocalPaths = {};
  static int? currentlyPlayingIndex;

  @override
  void initState() {
    super.initState();
    _initializeVoicePlayers();
  }

  @override
  void dispose() {
    _stopAllVoicePlayers();
    for (var controller in voicePlayerControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _stopAllVoicePlayers() {
    for (int i = 0; i < voicePlayerControllers.length; i++) {
      if (voicePlayingStates[i] == true) {
        voicePlayerControllers[i]?.stopPlayer();
        voicePlayingStates[i] = false;
      }
    }
    currentlyPlayingIndex = null;
    if (mounted) setState(() {});
  }

  void _initializeVoicePlayers() {
    for (int i = 0; i < widget.message.conversationFiles!.length; i++) {
      String fileType =
          widget.message.conversationFiles![i].fileType?.toLowerCase() ?? '';
      if (_isVoiceFile(fileType)) {
        voicePlayerControllers[i] = PlayerController();
        voicePlayingStates[i] = false;
        voiceLoadingStates[i] = false;
        voiceLocalPaths[i] = null;
      }
    }
  }

  bool _isVoiceFile(String fileType) {
    List<String> audioTypes = ['mp3', 'wav', 'm4a', 'aac', 'ogg', 'webm'];
    return audioTypes.contains(fileType.toLowerCase());
  }

  Widget _buildVoiceMessage(int index, bool isMe) {
    String fileUrl =
        '${Get.find<SplashController>().config!.imageBaseUrl!.conversation}/${widget.message.conversationFiles![index].fileName ?? ''}';
    String fileName =
        widget.message.conversationFiles![index].fileName ?? 'voice_message';
    bool isPlaying = voicePlayingStates[index] ?? false;
    bool isLoading = voiceLoadingStates[index] ?? false;

    return Container(
      margin: EdgeInsets.only(
        left: isMe ? 50 : 0,
        right: isMe ? 0 : 50,
        top: 4,
        bottom: 4,
      ),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isMe
            ? Theme.of(context).hintColor.withOpacity(0.2)
            : Theme.of(context).hintColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Play/Pause button
          GestureDetector(
            onTap: () => _toggleVoicePlayback(index, fileUrl),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isPlaying ? Colors.red : Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(18),
              ),
              child: isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Icon(
                      isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 18,
                    ),
            ),
          ),
          SizedBox(width: 8),

          // Voice waveform or duration
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Voice message label
                Row(
                  children: [
                    Icon(
                      Icons.audiotrack,
                      size: 14,
                      color: Theme.of(context).primaryColor,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'voice_message'.tr,
                      style: textMedium.copyWith(
                        fontSize: 12,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),

                // Waveform placeholder
                Container(
                  height: 20,
                  child: voicePlayerControllers[index] != null
                      ? AudioFileWaveforms(
                          size: Size(double.infinity, 20),
                          playerController: voicePlayerControllers[index]!,
                          playerWaveStyle: PlayerWaveStyle(
                            fixedWaveColor:
                                Theme.of(context).hintColor.withOpacity(0.3),
                            liveWaveColor: Theme.of(context).primaryColor,
                            spacing: 4,
                            showBottom: false,
                            showTop: true,
                          ),
                        )
                      : Row(
                          children: List.generate(
                              20,
                              (index) => Container(
                                    width: 2,
                                    height: (index % 3 + 1) * 4.0,
                                    margin: EdgeInsets.only(right: 2),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .hintColor
                                          .withOpacity(0.5),
                                      borderRadius: BorderRadius.circular(1),
                                    ),
                                  )),
                        ),
                ),
              ],
            ),
          ),

          SizedBox(width: 8),

          // Download button
          GestureDetector(
            onTap: () => _downloadVoiceFile(fileUrl, fileName),
            child: Icon(
              Icons.download,
              size: 18,
              color: Theme.of(context).primaryColor.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleVoicePlayback(int index, String fileUrl) async {
    if (voiceLoadingStates[index] == true) return;

    setState(() {
      voiceLoadingStates[index] = true;
    });

    try {
      PlayerController? controller = voicePlayerControllers[index];
      if (controller == null) return;

      // إذا كان هذا الملف يُشغل حالياً، قم بإيقافه
      if (currentlyPlayingIndex == index && voicePlayingStates[index] == true) {
        await controller.stopPlayer();
        setState(() {
          voicePlayingStates[index] = false;
          currentlyPlayingIndex = null;
        });
        return;
      }

      // إيقاف أي ملف آخر يُشغل حالياً
      if (currentlyPlayingIndex != null && currentlyPlayingIndex != index) {
        await voicePlayerControllers[currentlyPlayingIndex]?.stopPlayer();
        setState(() {
          voicePlayingStates[currentlyPlayingIndex!] = false;
        });
      }

      // تحضير الملف للتشغيل
      String? localFilePath = voiceLocalPaths[index];

      // إذا لم يكن الملف محملاً محلياً، قم بتحميله
      if (localFilePath == null || !File(localFilePath).existsSync()) {
        localFilePath = await _downloadAndCacheVoiceFile(fileUrl, index);
        if (localFilePath != null) {
          voiceLocalPaths[index] = localFilePath;
        }
      }

      if (localFilePath != null && File(localFilePath).existsSync()) {
        // إعادة تهيئة PlayerController للتأكد من عمله
        await controller.stopPlayer(); // تنظيف أي حالة سابقة
        await controller.preparePlayer(path: localFilePath);

        // بدء التشغيل
        await controller.startPlayer();
        setState(() {
          voicePlayingStates[index] = true;
          currentlyPlayingIndex = index;
        });

        // الاستماع لانتهاء التشغيل
        controller.onCompletion.listen((_) {
          if (mounted) {
            setState(() {
              voicePlayingStates[index] = false;
              if (currentlyPlayingIndex == index) {
                currentlyPlayingIndex = null;
              }
            });
          }
        });
      } else {
        print('❌ فشل في تحضير الملف المحلي: $localFilePath');
      }
    } catch (e) {
      print('❌ خطأ في تشغيل الرسالة الصوتية: $e');
    } finally {
      if (mounted) {
        setState(() {
          voiceLoadingStates[index] = false;
        });
      }
    }
  }

  Future<void> _downloadVoiceFile(String fileUrl, String fileName) async {
    try {
      final status = await Permission.storage.request();
      if (status.isGranted) {
        Directory? directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = Platform.isAndroid
              ? await getExternalStorageDirectory()
              : await getApplicationSupportDirectory();
        }
        // Implement actual download logic here
        print('Downloading voice file: $fileUrl');
      }
    } catch (e) {
      print('Error downloading voice file: $e');
    }
  }

  // دالة جديدة لتحميل الملف الصوتي وحفظه مؤقتاً (نفس الطريقة في تطبيق المستخدم)
  Future<String?> _downloadAndCacheVoiceFile(String fileUrl, int index) async {
    try {
      // الحصول على مجلد التخزين المؤقت
      Directory tempDir = await getTemporaryDirectory();
      String fileName =
          'voice_${index}_${DateTime.now().millisecondsSinceEpoch}.m4a';
      String localPath = '${tempDir.path}/$fileName';

      // تحميل الملف من الانترنت
      var response = await http.get(Uri.parse(fileUrl));
      var downloadData = response.bodyBytes;

      // حفظ الملف محلياً
      File localFile = File(localPath);
      await localFile.writeAsBytes(downloadData);

      print('✅ تم تحميل الملف الصوتي: $localPath');
      return localPath;
    } catch (e) {
      print('❌ خطأ في تحميل الملف الصوتي: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    images = [];
    for (var element in widget.message.conversationFiles!) {
      images.add(
          '${Get.find<SplashController>().config!.imageBaseUrl!.conversation}/${element.fileName ?? ''}');
    }
    return Column(
      crossAxisAlignment:
          (widget.message.user!.id! == Get.find<ProfileController>().driverId)
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
      children: [
        Padding(
          padding: (widget.message.user!.id! ==
                  Get.find<ProfileController>().driverId)
              ? const EdgeInsets.fromLTRB(20, 5, 5, 5)
              : const EdgeInsets.fromLTRB(5, 5, 20, 5),
          child: Column(
            crossAxisAlignment: (widget.message.user!.id! ==
                    Get.find<ProfileController>().driverId)
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.end,
            children: [
              SizedBox(height: Dimensions.fontSizeExtraSmall),
              if ((widget.length - 1 == widget.index)) ...[
                Center(
                    child: Text(
                  "${DateConverter.stringToLocalDateOnly(widget.message.createdAt ?? DateTime.now().toString())}, ${'trip'.tr}# ${widget.index == 0 ? widget.message.tripId : widget.previousMessage?.tripId}",
                  style:
                      textRegular.copyWith(color: Theme.of(context).hintColor),
                )),
                const SizedBox(
                  height: Dimensions.paddingSizeDefault,
                )
              ],
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: (widget.message.user!.id! ==
                        Get.find<ProfileController>().driverId)
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
                children: [
                  (widget.message.user!.id! ==
                          Get.find<ProfileController>().driverId)
                      ? const SizedBox()
                      : Column(children: [
                          ClipRRect(
                              borderRadius: BorderRadius.circular(50),
                              child: ImageWidget(
                                height: 30,
                                width: 30,
                                image:
                                    '${Get.find<SplashController>().config!.imageBaseUrl!.profileImageCustomer}/${widget.message.user!.profileImage}',
                                placeholder: Images.personPlaceholder,
                              ))
                        ]),
                  const SizedBox(
                    width: Dimensions.paddingSizeSmall,
                  ),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: (widget.message.user!.id! ==
                              Get.find<ProfileController>().driverId)
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.message.message != null)
                          Flexible(
                              child: Padding(
                            padding: (widget.message.user!.id! ==
                                    Get.find<ProfileController>().driverId)
                                ? EdgeInsets.only(left: Get.width * 0.15)
                                : EdgeInsets.only(right: Get.width * 0.1),
                            child: Container(
                                decoration: BoxDecoration(
                                    color: (widget.message.user!.id! ==
                                            Get.find<ProfileController>()
                                                .driverId)
                                        ? Theme.of(context)
                                            .hintColor
                                            .withOpacity(0.20)
                                        : Theme.of(context)
                                            .hintColor
                                            .withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(10)),
                                child: Padding(
                                    padding: const EdgeInsets.all(
                                        Dimensions.paddingSizeDefault),
                                    child: Text(
                                      widget.message.message ?? '',
                                      style: textRegular.copyWith(),
                                    ))),
                          )),
                        if (widget.message.message != null)
                          const SizedBox(
                              height: Dimensions.paddingSizeExtraSmall),
                        widget.message.conversationFiles!.isNotEmpty
                            ? Column(
                                children: [
                                  // Voice messages (displayed separately)
                                  ...widget.message.conversationFiles!
                                      .asMap()
                                      .entries
                                      .where((entry) => _isVoiceFile(
                                          entry.value.fileType?.toLowerCase() ??
                                              ''))
                                      .map((entry) => Padding(
                                            padding: EdgeInsets.only(bottom: 8),
                                            child: _buildVoiceMessage(
                                                entry.key,
                                                widget.message.user!.id! ==
                                                    Get.find<
                                                            ProfileController>()
                                                        .driverId),
                                          ))
                                      .toList(),

                                  // Images and other files (in grid)
                                  widget.message.conversationFiles!.any(
                                          (file) => !_isVoiceFile(
                                              file.fileType?.toLowerCase() ??
                                                  ''))
                                      ? SizedBox(
                                          width: widget.message
                                                      .conversationFiles!
                                                      .where((file) =>
                                                          !_isVoiceFile(file
                                                                  .fileType
                                                                  ?.toLowerCase() ??
                                                              ''))
                                                      .length <
                                                  4
                                              ? context.width
                                              : context.width * 0.53,
                                          child: Directionality(
                                            textDirection: Get.find<
                                                        LocalizationController>()
                                                    .isLtr
                                                ? (widget.message.user!.id! ==
                                                        Get.find<
                                                                ProfileController>()
                                                            .driverId)
                                                    ? TextDirection.rtl
                                                    : TextDirection.ltr
                                                : (widget.message.user!.id! ==
                                                        Get.find<
                                                                ProfileController>()
                                                            .driverId)
                                                    ? TextDirection.ltr
                                                    : TextDirection.rtl,
                                            child: GridView.builder(
                                              padding: EdgeInsets.zero,
                                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                  childAspectRatio: 1,
                                                  crossAxisCount: widget.message
                                                              .conversationFiles!
                                                              .where((file) =>
                                                                  !_isVoiceFile(file
                                                                          .fileType
                                                                          ?.toLowerCase() ??
                                                                      ''))
                                                              .length <
                                                          4
                                                      ? 3
                                                      : 2,
                                                  mainAxisSpacing: Dimensions
                                                      .paddingSizeSmall,
                                                  crossAxisSpacing: Dimensions
                                                      .paddingSizeSmall),
                                              shrinkWrap: true,
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              itemCount: widget.message
                                                          .conversationFiles!
                                                          .where((file) =>
                                                              !_isVoiceFile(file
                                                                      .fileType
                                                                      ?.toLowerCase() ??
                                                                  ''))
                                                          .length <
                                                      4
                                                  ? widget.message
                                                      .conversationFiles!
                                                      .where((file) =>
                                                          !_isVoiceFile(file
                                                                  .fileType
                                                                  ?.toLowerCase() ??
                                                              ''))
                                                      .length
                                                  : 4,
                                              itemBuilder:
                                                  (BuildContext context,
                                                      gridIndex) {
                                                // Get non-voice files
                                                var nonVoiceFiles = widget
                                                    .message.conversationFiles!
                                                    .where((file) =>
                                                        !_isVoiceFile(file
                                                                .fileType
                                                                ?.toLowerCase() ??
                                                            ''))
                                                    .toList();

                                                if (gridIndex >=
                                                    nonVoiceFiles.length)
                                                  return SizedBox.shrink();

                                                var file =
                                                    nonVoiceFiles[gridIndex];
                                                bool isImage = file.fileType
                                                            ?.toLowerCase() ==
                                                        'png' ||
                                                    file.fileType
                                                            ?.toLowerCase() ==
                                                        'jpg' ||
                                                    file.fileType
                                                            ?.toLowerCase() ==
                                                        'jpeg';

                                                if (isImage) {
                                                  return Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 5,
                                                              top: 0,
                                                              bottom: 5),
                                                      child: InkWell(
                                                        onTap: () => PopupBanner(
                                                                context:
                                                                    context,
                                                                images: images,
                                                                initIndex:
                                                                    gridIndex,
                                                                dotsAlignment:
                                                                    Alignment
                                                                        .bottomCenter,
                                                                onClick:
                                                                    (index) {},
                                                                autoSlide:
                                                                    false,
                                                                fit: BoxFit
                                                                    .contain,
                                                                showDownloadButton:
                                                                    false)
                                                            .show(),
                                                        child: Stack(children: [
                                                          ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5),
                                                              child: ImageWidget(
                                                                  height: 100,
                                                                  width: 100,
                                                                  fit: BoxFit
                                                                      .cover,
                                                                  image:
                                                                      '${Get.find<SplashController>().config!.imageBaseUrl!.conversation!}/${file.fileName ?? ''}')),
                                                          (nonVoiceFiles.length >
                                                                      4 &&
                                                                  gridIndex ==
                                                                      3)
                                                              ? Container(
                                                                  height: 100,
                                                                  width: 100,
                                                                  color: Colors
                                                                      .transparent
                                                                      .withOpacity(
                                                                    0.5,
                                                                  ),
                                                                  child: Center(
                                                                      child:
                                                                          Text(
                                                                    '+${nonVoiceFiles.length - 4}',
                                                                    style: textRegular.copyWith(
                                                                        color: Theme.of(context)
                                                                            .cardColor,
                                                                        fontSize:
                                                                            16),
                                                                  )),
                                                                )
                                                              : const SizedBox()
                                                        ]),
                                                      ));
                                                } else {
                                                  return InkWell(
                                                      onTap: () async {
                                                        final status =
                                                            await Permission
                                                                .storage
                                                                .request();
                                                        if (status.isGranted) {
                                                          Directory? directory =
                                                              Directory(
                                                                  '/storage/emulated/0/Download');
                                                          if (!await directory
                                                              .exists()) {
                                                            directory = Platform
                                                                    .isAndroid
                                                                ? await getExternalStorageDirectory() //FOR ANDROID
                                                                : await getApplicationSupportDirectory();
                                                          }
                                                        }
                                                      },
                                                      child: Container(
                                                          height: 50,
                                                          width: 50,
                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              color: Theme.of(
                                                                      context)
                                                                  .hoverColor),
                                                          child: Stack(
                                                              children: [
                                                                Center(
                                                                    child: SizedBox(
                                                                        width:
                                                                            50,
                                                                        child: Image.asset(
                                                                            Images.folder))),
                                                                Center(
                                                                    child: Text(
                                                                        '${file.fileName}'.substring(
                                                                            file.fileName!.length -
                                                                                7),
                                                                        maxLines:
                                                                            5,
                                                                        overflow:
                                                                            TextOverflow.clip)),
                                                              ])));
                                                }
                                              },
                                            ),
                                          ),
                                        )
                                      : SizedBox.shrink(),
                                ],
                              )
                            : const SizedBox.shrink(),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: Dimensions.paddingSizeSmall,
                  ),
                  (widget.message.user!.id! ==
                          Get.find<ProfileController>().driverId)
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: ImageWidget(
                            height: 30,
                            width: 30,
                            image:
                                '${Get.find<SplashController>().config!.imageBaseUrl!.profileImage!}/${widget.message.user!.profileImage}',
                            placeholder: Images.personPlaceholder,
                          ))
                      : const SizedBox(),
                ],
              ),
            ],
          ),
        ),
        Padding(
            padding: (widget.message.user!.id! ==
                    Get.find<ProfileController>().driverId)
                ? const EdgeInsets.fromLTRB(5, 0, 50, 15)
                : const EdgeInsets.fromLTRB(50, 0, 5, 15),
            child: Text(
                DateConverter.isoDateTimeStringToDifferentWithCurrentTime(
                    widget.message.createdAt!),
                textDirection: TextDirection.ltr,
                style: textRegular.copyWith(
                    fontSize: Dimensions.fontSizeExtraSmall,
                    color: Theme.of(context).hintColor))),
        if ((widget.message.tripId != widget.previousMessage?.tripId! &&
            widget.previousMessage != null))
          Center(
              child: Text(
            "${DateConverter.stringToLocalDateOnly(widget.previousMessage?.createdAt ?? DateTime.now().toString())}, ${'trip'.tr}# ${widget.index == 0 ? widget.message.tripId : widget.previousMessage?.tripId}",
            style: textRegular.copyWith(color: Theme.of(context).hintColor),
          )),
      ],
    );
  }
}
