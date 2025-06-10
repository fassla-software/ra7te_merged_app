import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ride_sharing_user_app/common_widgets/popup_banner/popup_banner.dart';
import 'package:ride_sharing_user_app/features/message/domain/models/message_model.dart';
import 'package:ride_sharing_user_app/helper/date_converter.dart';
import 'package:ride_sharing_user_app/localization/localization_controller.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/profile/controllers/profile_controller.dart';
import 'package:ride_sharing_user_app/features/splash/controllers/config_controller.dart';
import 'package:ride_sharing_user_app/common_widgets/image_widget.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:http/http.dart' as http;

class ConversationBubble extends StatefulWidget {
  final Message message;
  final Message? previousMessage;
  final int index;
  final int length;
  const ConversationBubble({
    super.key,
    required this.message,
    this.previousMessage,
    required this.index,
    required this.length,
  });

  @override
  State<ConversationBubble> createState() => _ConversationBubbleState();
}

class _ConversationBubbleState extends State<ConversationBubble> {
  List<String> images = [];

  // Voice message playback variables
  Map<int, PlayerController> voicePlayerControllers = {};
  Map<int, bool> voicePlayingStates = {};
  Map<int, bool> voiceLoadingStates = {};
  Map<int, String?> voiceLocalPaths = {}; // تخزين مسارات الملفات المحلية
  static int? currentlyPlayingIndex; // متغير global لتتبع الملف المُشغل حالياً

  @override
  void initState() {
    super.initState();
    _initializeVoicePlayers();
  }

  @override
  void dispose() {
    // إيقاف جميع التشغيلات وتنظيف الذاكرة
    _stopAllVoicePlayers();
    // Dispose all voice player controllers
    for (var controller in voicePlayerControllers.values) {
      controller.dispose();
    }
    super.dispose();
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
        '${Get.find<ConfigController>().config!.imageBaseUrl!.conversation}/${widget.message.conversationFiles![index].fileName ?? ''}';
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
            ? Theme.of(context).primaryColor.withOpacity(0.1)
            : Theme.of(context).hintColor.withOpacity(0.1),
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

                // Waveform placeholder (you can replace with actual waveforms later)
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

  // دالة جديدة لتحميل الملف الصوتي وحفظه مؤقتاً
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

        // تحميل الملف للجهاز (للحفظ الدائم)
        if (directory != null) {
          String filePath = '${directory.path}/$fileName';
          var response = await http.get(Uri.parse(fileUrl));
          File downloadFile = File(filePath);
          await downloadFile.writeAsBytes(response.bodyBytes);

          print('✅ تم تحميل الملف إلى: $filePath');
          // يمكنك إضافة رسالة نجاح هنا
        }
      }
    } catch (e) {
      print('❌ خطأ في تحميل الملف: $e');
    }
  }

  // دالة لإيقاف جميع الملفات الصوتية
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

  @override
  Widget build(BuildContext context) {
    images = [];
    bool isMe = widget.message.user?.id ==
        Get.find<ProfileController>().profileModel?.data?.id;
    for (var element in widget.message.conversationFiles!) {
      images.add(
          '${Get.find<ConfigController>().config!.imageBaseUrl!.conversation}/${element.fileName ?? ''}');
    }
    return Column(
      crossAxisAlignment:
          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Padding(
          padding: isMe
              ? const EdgeInsets.fromLTRB(20, 5, 10, 4)
              : const EdgeInsets.fromLTRB(10, 5, 20, 4),
          child: Column(
            crossAxisAlignment:
                isMe ? CrossAxisAlignment.start : CrossAxisAlignment.end,
            children: [
              const SizedBox(height: Dimensions.paddingSizeDefault),
              if ((widget.length - 1 == widget.index)) ...[
                Center(
                    child: Text(
                  "${DateConverter.stringToLocalDateOnly(widget.message.createdAt ?? DateTime.now().toString())}, "
                  "${'trip'.tr}# ${widget.index == 0 ? widget.message.tripId : widget.previousMessage?.tripId}",
                  style: TextStyle(color: Theme.of(context).hintColor),
                )),
                const SizedBox(height: Dimensions.paddingSizeDefault)
              ],
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment:
                    isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                children: [
                  isMe
                      ? const SizedBox()
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: ImageWidget(
                            height: 30,
                            width: 30,
                            image:
                                '${Get.find<ConfigController>().config?.imageBaseUrl!.profileImageDriver}/'
                                '${widget.message.user?.profileImage ?? ''}',
                          ),
                        ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Flexible(
                      child: Column(
                    crossAxisAlignment: isMe
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.message.message != null)
                        Flexible(
                            child: Padding(
                          padding: isMe
                              ? EdgeInsets.only(left: Get.width * 0.15)
                              : EdgeInsets.only(right: Get.width * 0.1),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isMe
                                  ? Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.10)
                                  : Theme.of(context)
                                      .hintColor
                                      .withOpacity(0.10),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(
                                  Dimensions.paddingSizeSmall),
                              child: Text(widget.message.message ?? ''),
                            ),
                          ),
                        )),
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
                                              entry.key, isMe),
                                        ))
                                    .toList(),

                                // Images and other files (in grid)
                                widget.message.conversationFiles!.any((file) =>
                                        !_isVoiceFile(
                                            file.fileType?.toLowerCase() ?? ''))
                                    ? SizedBox(
                                        width: widget.message.conversationFiles!
                                                    .where((file) =>
                                                        !_isVoiceFile(file
                                                                .fileType
                                                                ?.toLowerCase() ??
                                                            ''))
                                                    .length <
                                                4
                                            ? context.width
                                            : context.width * 0.6,
                                        child: Directionality(
                                          textDirection:
                                              Get.find<LocalizationController>()
                                                      .isLtr
                                                  ? isMe
                                                      ? TextDirection.rtl
                                                      : TextDirection.ltr
                                                  : isMe
                                                      ? TextDirection.ltr
                                                      : TextDirection.rtl,
                                          child: GridView.builder(
                                            gridDelegate:
                                                SliverGridDelegateWithFixedCrossAxisCount(
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
                                              mainAxisSpacing:
                                                  Dimensions.paddingSizeSmall,
                                              crossAxisSpacing:
                                                  Dimensions.paddingSizeSmall,
                                            ),
                                            padding: const EdgeInsets.only(
                                                top: Dimensions
                                                    .paddingSizeExtraSmall),
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemCount: widget
                                                .message.conversationFiles!
                                                .where((file) => !_isVoiceFile(
                                                    file.fileType
                                                            ?.toLowerCase() ??
                                                        ''))
                                                .length,
                                            itemBuilder: (BuildContext context,
                                                gridIndex) {
                                              // Get only non-voice files for the grid
                                              var nonVoiceFiles = widget
                                                  .message.conversationFiles!
                                                  .where((file) =>
                                                      !_isVoiceFile(file
                                                              .fileType
                                                              ?.toLowerCase() ??
                                                          ''))
                                                  .toList();
                                              int originalIndex = widget
                                                  .message.conversationFiles!
                                                  .indexOf(
                                                      nonVoiceFiles[gridIndex]);

                                              bool isImage = widget
                                                          .message
                                                          .conversationFiles![
                                                              originalIndex]
                                                          .fileType!
                                                          .toLowerCase() ==
                                                      'png' ||
                                                  widget
                                                          .message
                                                          .conversationFiles![
                                                              originalIndex]
                                                          .fileType!
                                                          .toLowerCase() ==
                                                      'jpg' ||
                                                  widget
                                                          .message
                                                          .conversationFiles![
                                                              originalIndex]
                                                          .fileType!
                                                          .toLowerCase() ==
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
                                                      context: context,
                                                      images: images,
                                                      initIndex: originalIndex,
                                                      dotsAlignment: Alignment
                                                          .bottomCenter,
                                                      onClick: (index) {},
                                                      autoSlide: false,
                                                      fit: BoxFit.contain,
                                                    ).show(),
                                                    child: Stack(children: [
                                                      ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(5),
                                                        child: ImageWidget(
                                                          height: 100,
                                                          width: 100,
                                                          fit: BoxFit.cover,
                                                          image:
                                                              '${Get.find<ConfigController>().config!.imageBaseUrl!.conversation!}/'
                                                              '${widget.message.conversationFiles![originalIndex].fileName ?? ''}',
                                                        ),
                                                      ),
                                                      (nonVoiceFiles.length >
                                                                  4 &&
                                                              gridIndex == 3)
                                                          ? Container(
                                                              height: 100,
                                                              width: 100,
                                                              color: Colors
                                                                  .transparent
                                                                  .withOpacity(
                                                                0.5,
                                                              ),
                                                              child: Center(
                                                                  child: Text(
                                                                '+${nonVoiceFiles.length - 4}',
                                                                style: textRegular
                                                                    .copyWith(
                                                                  color: Theme.of(
                                                                          context)
                                                                      .cardColor,
                                                                  fontSize: 16,
                                                                ),
                                                              )),
                                                            )
                                                          : const SizedBox()
                                                    ]),
                                                  ),
                                                );
                                              } else {
                                                return InkWell(
                                                  onTap: () async {
                                                    final status =
                                                        await Permission.storage
                                                            .request();
                                                    if (status.isGranted) {
                                                      Directory? directory =
                                                          Directory(
                                                              '/storage/emulated/0/Download');
                                                      if (!await directory
                                                          .exists()) {
                                                        directory = Platform
                                                                .isAndroid
                                                            ? await getExternalStorageDirectory()
                                                            : await getApplicationSupportDirectory();
                                                      }
                                                    }
                                                  },
                                                  child: Container(
                                                    height: 50,
                                                    width: 50,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      color: Theme.of(context)
                                                          .hoverColor,
                                                    ),
                                                    child: Stack(children: [
                                                      Center(
                                                          child: SizedBox(
                                                              width: 50,
                                                              child: Image
                                                                  .asset(Images
                                                                      .folder))),
                                                      Center(
                                                          child: Text(
                                                        '${widget.message.conversationFiles![originalIndex].fileName}'
                                                            .substring(
                                                          widget
                                                                  .message
                                                                  .conversationFiles![
                                                                      originalIndex]
                                                                  .fileName!
                                                                  .length -
                                                              7,
                                                        ),
                                                        maxLines: 5,
                                                        overflow:
                                                            TextOverflow.clip,
                                                      )),
                                                    ]),
                                                  ),
                                                );
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
                  )),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: isMe
              ? const EdgeInsets.fromLTRB(5, 0, 10, 5)
              : const EdgeInsets.fromLTRB(50, 0, 5, 5),
          child: Text(
            DateConverter.isoDateTimeStringToDifferentWithCurrentTime(
              widget.message.createdAt ?? DateTime.now().toString(),
            ),
            textDirection: TextDirection.ltr,
            style: textRegular.copyWith(
              fontSize: Dimensions.fontSizeExtraSmall,
              color: Theme.of(context).hintColor,
            ),
          ),
        ),
        if ((widget.message.tripId != widget.previousMessage?.tripId! &&
            widget.previousMessage != null))
          Center(
              child: Text(
            "${DateConverter.stringToLocalDateOnly(widget.previousMessage?.createdAt ?? DateTime.now().toString())}, "
            "${'trip'.tr}# ${widget.index == 0 ? widget.message.tripId : widget.previousMessage?.tripId}",
            style: TextStyle(color: Theme.of(context).hintColor),
          )),
      ],
    );
  }
}
