import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/models/playlist.dart';
import 'package:harmonymusic/ui/screens/PlaylistNAlbum/playlistnalbum_screen_controller.dart';
import 'package:harmonymusic/ui/widgets/list_widget.dart';
import 'package:harmonymusic/ui/widgets/modification_list.dart';
import 'package:harmonymusic/ui/widgets/shimmer_widgets/song_list_shimmer.dart';
import 'package:harmonymusic/ui/widgets/sort_widget.dart';

class PlaylistContentSection extends StatelessWidget {
  const PlaylistContentSection({
    required this.content,
    required this.tag,
    super.key,
  });

  final dynamic content;
  final String tag;

  @override
  Widget build(BuildContext context) {
    final playListNAlbumScreenController = Get.find<PlayListNAlbumScreenController>(tag: tag);
    return Expanded(
      child: Column(
        children: [
          Obx(
            () => SortWidget(
              tag: playListNAlbumScreenController.isAlbum ? content.browseId : content.playlistId,
              isSearchFeatureRequired: true,
              isPlaylistRearrangeFeatureRequired: !playListNAlbumScreenController.isAlbum &&
                  !content.isCloudPlaylist &&
                  content.playlistId != 'LIBRP' &&
                  content.playlistId != 'SongDownloads' &&
                  content.playlistId != 'SongsCache',
              isSongDeletionFeatureRequired: !playListNAlbumScreenController.isAlbum && !content.isCloudPlaylist,
              itemCountTitle: '${playListNAlbumScreenController.songList.length}',
              itemIcon: Icons.music_note_rounded,
              titleLeftPadding: 9,
              requiredSortTypes: buildSortTypeSet(false, true),
              onSort: (type, ascending) {
                playListNAlbumScreenController.onSort(type, ascending);
              },
              onSearch: playListNAlbumScreenController.onSearch,
              onSearchClose: playListNAlbumScreenController.onSearchClose,
              onSearchStart: playListNAlbumScreenController.onSearchStart,
              startAdditionalOperation: playListNAlbumScreenController.startAdditionalOperation,
              selectAll: playListNAlbumScreenController.selectAll,
              performAdditionalOperation: playListNAlbumScreenController.performAdditionalOperation,
              cancelAdditionalOperation: playListNAlbumScreenController.cancelAdditionalOperation,
            ),
          ),
          Obx(() => playListNAlbumScreenController.isContentFetched.value
              ? Obx(() => playListNAlbumScreenController.songList.isNotEmpty
                  ? (playListNAlbumScreenController.additionalOperationMode.value == OperationMode.none
                      ? ListWidget(
                          playListNAlbumScreenController.songList.toList(),
                          'Songs',
                          true,
                          isPlaylist: true,
                          playlist: !playListNAlbumScreenController.isAlbum ? content as Playlist : null,
                        )
                      : ModificationList(
                          mode: playListNAlbumScreenController.additionalOperationMode.value,
                          playListNAlbumScreenController: playListNAlbumScreenController,
                        ))
                  : Expanded(
                      child: Center(
                        child: Text('emptyPlaylist'.tr, style: Theme.of(context).textTheme.titleSmall),
                      ),
                    ))
              : const Expanded(child: SongListShimmer()))
        ],
      ),
    );
  }
}
