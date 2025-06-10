import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/lib2/common_widgets/custom_pop_scope_widget.dart';
import 'package:ride_sharing_user_app/lib2/helper/display_helper.dart';
import 'package:ride_sharing_user_app/lib2/localization/localization_controller.dart';
import 'package:ride_sharing_user_app/lib2/util/dimensions.dart';
import 'package:ride_sharing_user_app/lib2/util/images.dart';
import 'package:ride_sharing_user_app/lib2/util/styles.dart';
import 'package:ride_sharing_user_app/lib2/features/chat/controllers/chat_controller.dart';
import 'package:ride_sharing_user_app/lib2/features/chat/widgets/message_bubble_widget.dart';
import 'package:ride_sharing_user_app/lib2/common_widgets/app_bar_widget.dart';
import 'package:ride_sharing_user_app/lib2/common_widgets/no_data_widget.dart';
import 'package:ride_sharing_user_app/lib2/common_widgets/paginated_list_view_widget.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'dart:math' as math;

class MessageScreen extends StatefulWidget {
  final String channelId;
  final String tripId;
  final String userName;
  const MessageScreen(
      {super.key,
      required this.channelId,
      required this.tripId,
      required this.userName});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  ScrollController scrollController = ScrollController();

  @override
  void initState() {
    Get.find<ChatController>().findChannelRideStatus(widget.channelId);
    Get.find<ChatController>().getConversation(widget.channelId, 1);
    Get.find<ChatController>().subscribeMessageChannel(widget.tripId);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPopScopeWidget(
      child: Scaffold(
        body: GetBuilder<ChatController>(builder: (messageController) {
          return Column(children: [
            AppBarWidget(
                title: '${'chat_with'.tr} ${widget.userName}',
                regularAppbar: true),

            (messageController.messageModel != null &&
                    messageController.messageModel!.data != null)
                ? messageController.messageModel!.data!.isNotEmpty
                    ? Expanded(
                        child: SingleChildScrollView(
                        controller: scrollController,
                        reverse: true,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: Dimensions.paddingSizeSmall),
                          child: PaginatedListViewWidget(
                            reverse: true,
                            scrollController: scrollController,
                            totalSize:
                                messageController.messageModel!.totalSize,
                            offset: (messageController.messageModel != null &&
                                    messageController.messageModel!.offset !=
                                        null)
                                ? int.parse(messageController
                                    .messageModel!.offset
                                    .toString())
                                : null,
                            onPaginate: (int? offset) async =>
                                await messageController.getConversation(
                                    widget.channelId, offset!),
                            itemView: ListView.builder(
                              reverse: true,
                              itemCount:
                                  messageController.messageModel!.data!.length,
                              padding: const EdgeInsets.all(0),
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemBuilder: (BuildContext context, int index) {
                                if (index != 0) {
                                  return ConversationBubbleWidget(
                                    message: messageController
                                        .messageModel!.data![index],
                                    previousMessage: messageController
                                        .messageModel!.data![index - 1],
                                    index: index,
                                    length: messageController
                                        .messageModel!.data!.length,
                                  );
                                } else {
                                  return ConversationBubbleWidget(
                                    message: messageController
                                        .messageModel!.data![index],
                                    index: index,
                                    length: messageController
                                        .messageModel!.data!.length,
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                      ))
                    : const Expanded(
                        child: NoDataWidget(
                        title: 'no_message_found',
                      ))
                : Expanded(
                    child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SpinKitCircle(
                          color: Theme.of(context).primaryColor, size: 40.0),
                    ],
                  )),

            messageController.pickedImageFile != null &&
                    messageController.pickedImageFile!.isNotEmpty
                ? Container(
                    height: 90,
                    width: Get.width,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        return Stack(children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: SizedBox(
                                height: 80,
                                width: 80,
                                child: Image.file(
                                  File(messageController
                                      .pickedImageFile![index].path),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 5,
                            child: InkWell(
                              child: const Icon(Icons.cancel_outlined,
                                  color: Colors.red),
                              onTap: () => messageController
                                  .pickMultipleImage(true, index: index),
                            ),
                          ),
                        ]);
                      },
                      itemCount: messageController.pickedImageFile!.length,
                    ),
                  )
                : const SizedBox(),

            messageController.otherFile != null
                ? Stack(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      height: 25,
                      child:
                          Text(messageController.otherFile!.names.toString()),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: InkWell(
                        child: const Icon(Icons.cancel_outlined,
                            color: Colors.red),
                        onTap: () => messageController.pickOtherFile(true),
                      ),
                    ),
                  ])
                : const SizedBox(),

            // Voice recordings preview list
            if (messageController.hasVoiceRecordings)
              Container(
                height: 120,
                width: Get.width,
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.audio_file,
                            color: Theme.of(context).primaryColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'voice_recordings'.tr +
                                ' (${messageController.voiceFiles.length})',
                            style: textMedium.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: () =>
                                messageController.clearAllVoiceRecordings(),
                            icon: Icon(Icons.clear_all,
                                size: 16, color: Colors.red),
                            label: Text('clear_all'.tr,
                                style: textRegular.copyWith(
                                    color: Colors.red, fontSize: 12)),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              minimumSize: Size(0, 0),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: messageController.voiceFiles.length,
                        itemBuilder: (context, index) {
                          bool isPlaying =
                              messageController.playingVoiceIndex == index &&
                                  messageController.isPlayingVoice;
                          return Container(
                            width: 280,
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.1),
                                  Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.05),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.3)),
                              boxShadow: [
                                BoxShadow(
                                  color: Theme.of(context)
                                      .primaryColor
                                      .withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // Play/Pause button
                                GestureDetector(
                                  onTap: () {
                                    if (isPlaying) {
                                      messageController.stopVoicePlayback();
                                    } else {
                                      messageController
                                          .playVoiceRecording(index);
                                    }
                                  },
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: isPlaying
                                          ? Colors.red
                                          : Theme.of(context).primaryColor,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: (isPlaying
                                                  ? Colors.red
                                                  : Theme.of(context)
                                                      .primaryColor)
                                              .withOpacity(0.3),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      isPlaying ? Icons.stop : Icons.play_arrow,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Waveform visualization with AudioWaveforms
                                Expanded(
                                  child: index <
                                          messageController
                                              .playerControllers.length
                                      ? AudioFileWaveforms(
                                          size: Size(double.infinity, 40),
                                          playerController: messageController
                                              .playerControllers[index],
                                          playerWaveStyle: PlayerWaveStyle(
                                            fixedWaveColor: Theme.of(context)
                                                .primaryColor
                                                .withOpacity(0.3),
                                            liveWaveColor:
                                                Theme.of(context).primaryColor,
                                            spacing: 6,
                                            showBottom: false,
                                            showTop: true,
                                          ),
                                        )
                                      : Container(
                                          height: 40,
                                          child: Row(
                                            children:
                                                List.generate(15, (waveIndex) {
                                              double height =
                                                  (waveIndex % 3 + 1) * 8.0;
                                              return Container(
                                                width: 3,
                                                height: height,
                                                margin: const EdgeInsets.only(
                                                    right: 2),
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context)
                                                      .primaryColor
                                                      .withOpacity(0.4),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          1.5),
                                                ),
                                              );
                                            }),
                                          ),
                                        ),
                                ),
                                const SizedBox(width: 8),
                                // Remove button
                                GestureDetector(
                                  onTap: () =>
                                      messageController.removeVoiceFile(index),
                                  child: Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                          color: Colors.red.withOpacity(0.2)),
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.red,
                                      size: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

            Padding(
              padding: const EdgeInsets.only(
                left: Dimensions.paddingSizeDefault,
                right: Dimensions.paddingSizeDefault,
                bottom: Dimensions.paddingSizeDefault,
              ),
              child:
                  Divider(color: Theme.of(context).hintColor.withOpacity(0.15)),
            ),

            /// Message Send field here.

            messageController.channelRideStatus
                ? _buildWhatsAppStyleChatBar(messageController)
                : SizedBox(
                    height: 50,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.75),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.block),
                            const SizedBox(width: 5),
                            Text("you_could't_replay_you_have_no_trip".tr),
                          ]),
                    ),
                  ),
          ]);
        }),
      ),
    );
  }

  Widget _buildWhatsAppStyleChatBar(ChatController messageController) {
    if (messageController.isRecording) {
      // WhatsApp-style recording mode
      return Container(
        width: Get.width,
        margin: const EdgeInsets.only(
          left: Dimensions.paddingSizeSmall,
          right: Dimensions.paddingSizeSmall,
          bottom: Dimensions.paddingSizeSmall,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Theme.of(context).primaryColor),
        ),
        child: Row(
          children: [
            // Cancel button
            GestureDetector(
              onTap: () => messageController.cancelRecording(),
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  Icons.close,
                  color: Colors.red,
                  size: 24,
                ),
              ),
            ),

            // Recording animation and timer
            Expanded(
              child: Row(
                children: [
                  // Recording dot animation
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Recording text and timer
                  Text(
                    'recording_in_progress'.tr,
                    style: textRegular.copyWith(
                      color: Colors.red,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    messageController.formattedRecordingDuration,
                    style: textMedium.copyWith(
                      color: Theme.of(context).primaryColor,
                      fontSize: 14,
                    ),
                  ),

                  const Spacer(),
                ],
              ),
            ),

            // Send button
            GestureDetector(
              onTap: () async {
                messageController.stopRecording();
                // Wait a moment for the recording to be processed
                await Future.delayed(Duration(milliseconds: 500));
                // Send the message if we have voice recordings
                if (messageController.hasVoiceRecordings) {
                  await messageController.sendMessage(
                      widget.channelId, widget.tripId);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.send,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Normal chat bar mode
    return Container(
      width: Get.width,
      margin: const EdgeInsets.only(
        left: Dimensions.paddingSizeSmall,
        right: Dimensions.paddingSizeSmall,
        bottom: Dimensions.paddingSizeSmall,
      ),
      child: Row(
        children: [
          // Chat input container
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).primaryColor),
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.all(Radius.circular(25)),
              ),
              child: Row(
                children: [
                  const SizedBox(width: Dimensions.paddingSizeDefault),

                  // Text input field
                  Expanded(
                    child: TextField(
                      minLines: 1,
                      maxLines: 4,
                      controller: messageController.conversationController,
                      textCapitalization: TextCapitalization.sentences,
                      style: textMedium.copyWith(
                        fontSize: Dimensions.fontSizeLarge,
                        color: Theme.of(context)
                            .textTheme
                            .bodyMedium!
                            .color!
                            .withOpacity(0.8),
                      ),
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "type_here".tr,
                        hintStyle: textRegular.copyWith(
                          color: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .color!
                              .withOpacity(0.8),
                          fontSize: 16,
                        ),
                      ),
                      onChanged: (String newText) {
                        messageController.update();
                      },
                    ),
                  ),

                  // Image picker button
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: Dimensions.paddingSizeSmall),
                    child: InkWell(
                      onTap: () => messageController.pickMultipleImage(false),
                      child: Image.asset(
                        Images.pickImage,
                        width: 24,
                        height: 24,
                        color: Get.isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  ),

                  // Voice recorder button
                  _buildVoiceRecorderButton(messageController),

                  const SizedBox(width: 4),
                ],
              ),
            ),
          ),

          // Send button (show when there's content)
          const SizedBox(width: 8),
          _buildSendButton(messageController),
        ],
      ),
    );
  }

  Widget _buildSendButton(ChatController messageController) {
    bool hasContent =
        messageController.conversationController.text.trim().isNotEmpty ||
            (messageController.pickedImageFile?.isNotEmpty ?? false) ||
            messageController.otherFile != null ||
            messageController.hasVoiceRecordings;

    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      width: hasContent ? 48 : 0,
      height: 48,
      decoration: BoxDecoration(
        color: hasContent ? Theme.of(context).primaryColor : Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: hasContent
          ? messageController.isSending
              ? Center(
                  child: SpinKitCircle(
                    color: Theme.of(context).cardColor,
                    size: 20,
                  ),
                )
              : InkWell(
                  onTap: () {
                    if (messageController.conversationKey.currentState!
                        .validate()) {
                      messageController
                          .sendMessage(widget.channelId, widget.tripId)
                          .then((value) {});
                    }
                    messageController.conversationController.clear();
                  },
                  child: Center(
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Get.find<LocalizationController>().isLtr
                          ? Matrix4.rotationY(0)
                          : Matrix4.rotationY(math.pi),
                      child: Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                )
          : SizedBox.shrink(),
    );
  }

  Widget _buildVoiceRecorderButton(ChatController messageController) {
    return GestureDetector(
      // Hold to record - start recording on long press
      onLongPressStart: (details) async {
        if (!messageController.isRecording) {
          // Haptic feedback when starting to record
          HapticFeedback.lightImpact();
          await messageController.startRecording();
        }
      },

      // Auto-send on release
      onLongPressEnd: (details) async {
        if (messageController.isRecording) {
          // Haptic feedback when releasing to send
          HapticFeedback.mediumImpact();
          await messageController.stopRecording(
            channelId: widget.channelId,
            tripId: widget.tripId,
            autoSend: true, // Auto-send when released
          );
        }
      },

      // Cancel recording if user drags away (optional)
      onLongPressCancel: () async {
        if (messageController.isRecording) {
          // Haptic feedback when canceling
          HapticFeedback.heavyImpact();
          messageController.cancelRecording();
        }
      },

      // Regular tap (for manual recording if needed)
      onTap: () async {
        if (messageController.isRecording) {
          await messageController.stopRecording(
            channelId: widget.channelId,
            tripId: widget.tripId,
            autoSend: false, // Don't auto-send on manual tap
          );
        }
      },

      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: messageController.isRecording
              ? Colors.red
              : Theme.of(context).primaryColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: messageController.isRecording
            ? AudioWaveforms(
                size: Size(40, 40),
                recorderController: messageController.recorderController,
                waveStyle: WaveStyle(
                  waveColor: Colors.white,
                  showDurationLabel: false,
                  spacing: 8.0,
                  showBottom: false,
                  extendWaveform: true,
                  showMiddleLine: false,
                ),
              )
            : Icon(
                Icons.mic,
                color: Theme.of(context).primaryColor,
                size: 20,
              ),
      ),
    );
  }
}
