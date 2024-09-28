import 'dart:io';
import 'dart:ui';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'package:widget_marquee/widget_marquee.dart';

import '/models/thumbnail.dart';
import '../../screens/Settings/settings_screen_controller.dart';
import '../../utils/theme_controller.dart';
import '../player_controller.dart';

class GesturePlayer extends StatelessWidget {
  const GesturePlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final PlayerController playerController = Get.find<PlayerController>();
    final ThemeController themeController = Get.find<ThemeController>();
    return Stack(
      children: [
        GestureDetector(
          child: Obx(
            () => SizedBox.expand(
              child: playerController.currentSong.value != null
                  ? CachedNetworkImage(
                      errorWidget: (context, url, error) {
                        final imgFile = File(
                            "${Get.find<SettingsScreenController>().supportDirPath}/thumbnails/${playerController.currentSong.value!.id}.png");
                        if (imgFile.existsSync()) {
                          themeController.setTheme(FileImage(imgFile),
                              playerController.currentSong.value!.id);
                          return Image.file(imgFile);
                        }
                        return const SizedBox.shrink();
                      },
                      // memCacheHeight: 544,
                      imageBuilder: (context, imageProvider) {
                        Get.find<SettingsScreenController>()
                                    .themeModetype
                                    .value ==
                                ThemeType.dynamic
                            ? Future.delayed(
                                const Duration(milliseconds: 250),
                                () => themeController.setTheme(imageProvider,
                                    playerController.currentSong.value!.id))
                            : null;
                        return Image(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        );
                      },
                      imageUrl: Thumbnail(playerController
                              .currentSong.value!.artUri
                              .toString())
                          .sizewith(544),
                      cacheKey:
                          "${playerController.currentSong.value!.id}_pl_song",
                    )
                  : Container(),
            ),
          ),
          onHorizontalDragEnd: (DragEndDetails details) {
            if (details.primaryVelocity! < 0) {
              playerController.next();
            } else if (details.primaryVelocity! > 0) {
              playerController.prev();
            }
          },
          onDoubleTap: () {
            playerController.playPause();
          },
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.only(
                bottom: Get.mediaQuery.padding.bottom != 0
                    ? Get.mediaQuery.padding.bottom + 10
                    : 20,
                left: 20,
                right: 20),
            child: Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10)),
              constraints: const BoxConstraints(maxWidth: 500),
              height: 142,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 10),
                    child: Column(children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Obx(() {
                                    return Marquee(
                                      delay: const Duration(milliseconds: 300),
                                      duration: const Duration(seconds: 5),
                                      id: "Current Song",
                                      child: Text(
                                        playerController.currentSong.value !=
                                                null
                                            ? playerController
                                                .currentSong.value!.title
                                            : "NA",
                                        textAlign: TextAlign.start,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium!
                                            .copyWith(
                                                color: Theme.of(context)
                                                    .primaryColor
                                                    .complementaryColor),
                                      ),
                                    );
                                  }),
                                  const SizedBox(
                                    height: 7,
                                  ),
                                  GetX<PlayerController>(builder: (controller) {
                                    return Marquee(
                                      delay: const Duration(milliseconds: 300),
                                      duration: const Duration(seconds: 5),
                                      id: "Current Song artists",
                                      child: Text(
                                        playerController.currentSong.value !=
                                                null
                                            ? controller
                                                .currentSong.value!.artist!
                                            : "NA",
                                        textAlign: TextAlign.start,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall!
                                            .copyWith(
                                                color: Theme.of(context)
                                                    .primaryColor
                                                    .complementaryColor,
                                                fontWeight: FontWeight.normal),
                                      ),
                                    );
                                  }),
                                ]),
                          ),
                          SizedBox(
                            width: 75,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                IconButton(
                                    splashRadius: 10,
                                    iconSize: 20,
                                    visualDensity: const VisualDensity(
                                        horizontal: -4, vertical: -4),
                                    onPressed: playerController.toggleFavourite,
                                    icon: Obx(() => Icon(
                                          playerController
                                                  .isCurrentSongFav.isFalse
                                              ? Icons.favorite_border_rounded
                                              : Icons.favorite_rounded,
                                          color: Theme.of(context)
                                              .textTheme
                                              .titleMedium!
                                              .color,
                                        ))),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Obx(() {
                                      return IconButton(
                                          splashRadius: 10,
                                          visualDensity: const VisualDensity(
                                              horizontal: -4, vertical: -4),
                                          iconSize: 18,
                                          onPressed:
                                              playerController.toggleLoopMode,
                                          icon: Icon(
                                            Icons.all_inclusive,
                                            color: playerController
                                                    .isLoopModeEnabled.value
                                                ? Theme.of(context)
                                                    .textTheme
                                                    .titleLarge!
                                                    .color
                                                : Theme.of(context)
                                                    .textTheme
                                                    .titleLarge!
                                                    .color!
                                                    .withOpacity(0.2),
                                          ));
                                    }),
                                    IconButton(
                                      iconSize: 18,
                                      splashRadius: 10,
                                      visualDensity: const VisualDensity(
                                          horizontal: -4, vertical: -4),
                                      onPressed:
                                          playerController.toggleShuffleMode,
                                      icon: Obx(
                                        () => Icon(
                                          Ionicons.shuffle,
                                          color: playerController
                                                  .isShuffleModeEnabled.value
                                              ? Theme.of(context)
                                                  .textTheme
                                                  .titleLarge!
                                                  .color
                                              : Theme.of(context)
                                                  .textTheme
                                                  .titleLarge!
                                                  .color!
                                                  .withOpacity(0.2),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      GetX<PlayerController>(builder: (controller) {
                        return ProgressBar(
                          thumbRadius: 6,
                          baseBarColor:
                              Theme.of(context).sliderTheme.inactiveTrackColor,
                          bufferedBarColor:
                              Theme.of(context).sliderTheme.valueIndicatorColor,
                          progressBarColor:
                              Theme.of(context).sliderTheme.activeTrackColor,
                          thumbColor: Theme.of(context).sliderTheme.thumbColor,
                          timeLabelTextStyle: Theme.of(context)
                              .textTheme
                              .titleSmall!
                              .copyWith(
                                  color: Theme.of(context)
                                      .primaryColor
                                      .complementaryColor),
                          progress: controller.progressBarStatus.value.current,
                          total: controller.progressBarStatus.value.total,
                          buffered: controller.progressBarStatus.value.buffered,
                          onSeek: controller.seek,
                        );
                      }),
                    ]),
                  ),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }
}