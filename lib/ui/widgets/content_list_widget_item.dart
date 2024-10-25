import 'package:flutter/material.dart';
import 'package:flutter_tailwind/flutter_tailwind.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/ui/navigator.dart';
import 'package:harmonymusic/ui/widgets/image_widget.dart';

class ContentListItem extends StatelessWidget {
  const ContentListItem({
    required this.content,
    super.key,
    this.isLibraryItem = false,
  });

  ///content will be of Type class Album or Playlist
  final dynamic content;
  final bool isLibraryItem;

  @override
  Widget build(BuildContext context) {
    final isAlbum = content.runtimeType.toString() == 'Album';
    return InkWell(
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: () {
        Get.toNamed(ScreenNavigationSetup.playlistNAlbumScreen,
            id: ScreenNavigationSetup.id, arguments: [isAlbum, content, false]);
      },
      child: container.w240.h360.ph6.child(
        column.crossStart.children([
          if (isAlbum)
            ImageWidget(
              size: 120,
              album: content,
            )
          else
            // isCloudPlaylist not found | should delete
            content.isCloudPlaylist
                ? SizedBox.square(
                    dimension: 120,
                    child: Stack(
                      children: [
                        ImageWidget(
                          size: 120,
                          playlist: content,
                        ),
                        if (content.isPipedPlaylist)
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Container(
                                height: 18,
                                width: 18,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                                child: Center(
                                    child: Text(
                                  'P',
                                  style: Theme.of(context).textTheme.titleMedium!.copyWith(fontSize: 14),
                                )),
                              ),
                            ),
                          )
                      ],
                    ),
                  )
                : Container(
                    height: 120,
                    width: 120,
                    decoration: BoxDecoration(
                        color: Theme.of(context).primaryColorLight, borderRadius: BorderRadius.circular(10)),
                    child: Center(
                        child: Icon(
                      content.playlistId == 'LIBRP'
                          ? Icons.history_rounded
                          : content.playlistId == 'LIBFAV'
                              ? Icons.favorite_rounded
                              : content.playlistId == 'SongsCache'
                                  ? Icons.flight_rounded
                                  : content.playlistId == 'SongDownloads'
                                      ? Icons.download
                                      : Icons.playlist_play_rounded,
                      color: Colors.white,
                      size: 40,
                    ))),
          const SizedBox(height: 5),
          Expanded(
            child: column.crossStart.children([
              Text(
                content.title,
                // overflow: TextOverflow.ellipsis,
                maxLines: 2,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                isAlbum
                    ? isLibraryItem
                        ? ''
                        : "${content.artists[0]['name'] ?? ""} | ${content.year ?? ""}"
                    : isLibraryItem
                        ? ''
                        : content.description ?? '',
                maxLines: 1,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ]),
          )
        ]),
      ),
    );
  }
}
