import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:ride_sharing_user_app/common_widgets/custom_pop_scope_widget.dart';
import 'package:ride_sharing_user_app/features/message/widget/message_bubble.dart';
import 'package:ride_sharing_user_app/features/profile/controllers/profile_controller.dart';
import 'package:ride_sharing_user_app/helper/display_helper.dart';
import 'package:ride_sharing_user_app/localization/localization_controller.dart';
import 'package:ride_sharing_user_app/util/dimensions.dart';
import 'package:ride_sharing_user_app/util/images.dart';
import 'package:ride_sharing_user_app/util/styles.dart';
import 'package:ride_sharing_user_app/features/message/controllers/message_controller.dart';
import 'package:ride_sharing_user_app/features/notification/widgets/notification_shimmer.dart';
import 'package:ride_sharing_user_app/common_widgets/app_bar_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/body_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/no_data_widget.dart';
import 'package:ride_sharing_user_app/common_widgets/paginated_list_widget.dart';
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
  @override
  void initState() {
    _loadData();
    super.initState();
  }

  Future _loadData() async {
    ///make sure to call before getConversation to show loading
    if (Get.find<ProfileController>().profileModel?.data?.id == null) {
      await Get.find<ProfileController>().getProfileInfo();
    }
    Get.find<MessageController>().findChannelRideStatus(widget.channelId);
    Get.find<MessageController>().getConversation(widget.channelId, 1);
    Get.find<MessageController>().subscribeMessageChannel(widget.tripId);
  }

  ScrollController scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return CustomPopScopeWidget(
      child: Scaffold(
        body: BodyWidget(
          appBar: AppBarWidget(
            title: "${'chat_with'.tr} ${widget.userName}",
            showBackButton: true,
            centerTitle: true,
          ),
          body: GetBuilder<MessageController>(builder: (messageController) {
            return Column(children: [
              messageController.messageModel?.data != null
                  ? messageController.messageModel!.data!.isNotEmpty
                      ? Expanded(
                          child: SingleChildScrollView(
                          controller: scrollController,
                          reverse: true,
                          child: PaginatedListWidget(
                            reverse: true,
                            scrollController: scrollController,
                            totalSize:
                                messageController.messageModel?.totalSize,
                            offset: (messageController.messageModel != null &&
                                    messageController.messageModel?.offset !=
                                        null)
                                ? int.parse(messageController
                                    .messageModel!.offset
                                    .toString())
                                : null,
                            onPaginate: (int? offset) async {
                              await messageController.getConversation(
                                  widget.channelId, offset!);
                            },
                            itemView: ListView.builder(
                              reverse: true,
                              itemCount:
                                  messageController.messageModel?.data?.length,
                              padding: const EdgeInsets.all(0),
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemBuilder: (BuildContext context, int index) {
                                if (index != 0) {
                                  return ConversationBubble(
                                    message: messageController
                                        .messageModel!.data![index],
                                    previousMessage: messageController
                                        .messageModel!.data![index - 1],
                                    index: index,
                                    length: messageController
                                        .messageModel!.data!.length,
                                  );
                                } else {
                                  return ConversationBubble(
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
                        ))
                      : const Expanded(
                          child: NoDataWidget(title: 'no_message_found'))
                  : const Expanded(child: NotificationShimmer()),

              // Images preview
              if (messageController.pickedImageFile != null &&
                  messageController.pickedImageFile!.isNotEmpty)
                Container(
                  height: 90,
                  width: Get.width,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: messageController.pickedImageFile!.length,
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
                                )),
                          ),
                        ),
                        Positioned(
                            right: 5,
                            child: InkWell(
                              onTap: () => messageController
                                  .pickMultipleImage(true, index: index),
                              child: const Icon(Icons.cancel_outlined,
                                  color: Colors.red),
                            )),
                      ]);
                    },
                  ),
                ),

              // Other file preview
              if (messageController.otherFile != null)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 25),
                  child: Stack(children: [
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
                        onTap: () => messageController.pickOtherFile(true),
                        child: const Icon(Icons.cancel_outlined,
                            color: Colors.red),
                      ),
                    ),
                  ]),
                ),

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
                                        isPlaying
                                            ? Icons.stop
                                            : Icons.play_arrow,
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
                                              liveWaveColor: Theme.of(context)
                                                  .primaryColor,
                                              spacing: 6,
                                              showBottom: false,
                                              showTop: true,
                                            ),
                                          )
                                        : Container(
                                            height: 40,
                                            child: Row(
                                              children: List.generate(15,
                                                  (waveIndex) {
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
                                    onTap: () => messageController
                                        .removeVoiceFile(index),
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

              // Chat input area
              const SizedBox(height: 20),
              if (messageController.channelRideStatus)
                Form(
                  key: messageController.conversationKey,
                  child: GetBuilder<MessageController>(
                    builder: (messageController) {
                      return _buildWhatsAppStyleChatBar(messageController);
                    },
                  ),
                )
              else
                SizedBox(
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
                    )),
            ]);
          }),
        ),
      ),
    );
  }

  Widget _buildWhatsAppStyleChatBar(MessageController messageController) {
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
                  // Recording dot animation or lock icon
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: messageController.isRecordingLocked
                          ? Colors.green
                          : Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: messageController.isRecordingLocked
                        ? Icon(
                            Icons.lock,
                            color: Colors.white,
                            size: 8,
                          )
                        : null,
                  ),
                  const SizedBox(width: 8),

                  // Recording text and timer
                  Text(
                    messageController.isRecordingLocked
                        ? 'recording_locked'.tr
                        : 'recording_in_progress'.tr,
                    style: textRegular.copyWith(
                      color: messageController.isRecordingLocked
                          ? Colors.green
                          : Colors.red,
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

                  // Instructions based on lock state
                  if (!messageController.isRecordingLocked)
                    Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [],
                      ),
                    )
                  else
                    Text(
                      'hands_free_mode'.tr,
                      style: textRegular.copyWith(
                        color: Colors.green,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),

            // Lock button (for hands-free recording)
            if (!messageController.isRecordingLocked)
              GestureDetector(
                onTap: () => messageController.lockRecording(),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.lock_outline,
                    color: Theme.of(context).primaryColor,
                    size: 20,
                  ),
                ),
              ),

            // Send button (when recording is locked or finished)
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

  Widget _buildSendButton(MessageController messageController) {
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

  Widget _buildVoiceRecorderButton(MessageController messageController) {
    return GestureDetector(
      onTap: () async {
        if (messageController.isRecording) {
          await messageController.stopRecording(
            channelId: widget.channelId,
            tripId: widget.tripId,
            autoSend: true,
          );
        } else {
          await messageController.startRecording();
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
