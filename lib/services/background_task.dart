import 'dart:isolate';

import 'package:audio_service/audio_service.dart';
import 'package:get/get.dart';
import 'package:harmonymusic/helper.dart';
import 'package:harmonymusic/services/music_service.dart';
import 'package:harmonymusic/services/utils.dart';
import 'package:hive_flutter/adapters.dart';

import '../models/media_Item_builder.dart';

Future<void> cacheQueueitemsUrl(List<MediaItem> mediaitems) async {
  final songsCacheBox = Hive.box(
    "SongsCache",
  );
  final songsUrlCacheBox = Hive.box('SongsUrlCache');
  final musicServices = Get.find<MusicServices>();
  for (MediaItem item in mediaitems) {
    await checkNPutUrl(item.id, songsCacheBox, songsUrlCacheBox, musicServices);
  }
  printINFO("All SteamUrls Cached in box");
}

Future<void> checkNPutUrl(String songId, dynamic songsCacheBox,
    dynamic songsUrlCacheBox, MusicServices musicServices) async {
  if (songsCacheBox.containsKey(songId)) {
    printINFO("StreamUrl has alredy been cached in box $songId", tag: "UrlCaching");
    return;
  } else {
    //check if song stream url is cached and allocate url accordingly
    if (songsUrlCacheBox.containsKey(songId)) {
      if (isExpired(url: songsUrlCacheBox.get(songId))) {
        final url = (await musicServices.getSongUri(songId)).toString();
        if (url.toString() != 'null') songsUrlCacheBox.put(songId, url);
      }
      return;
    } else {
      final url = (await musicServices.getSongUri(songId)).toString();
      if (url.toString() != 'null') songsUrlCacheBox.put(songId, url);
      printINFO("StreamUrl has cached $songId", tag: "Isolate");
    }
  }
}

Future<void> getUpNextSong(List args) async {
  SendPort sendPort = args[0] as SendPort;
  final res =
      await (args[1] as MusicServices).getWatchPlaylist(videoId: args[2]);
  List<MediaItem> upNextSongList = (res['tracks'])
      .map<MediaItem>((item) => MediaItemBuilder.fromJson(item))
      .toList();
  sendPort.send(upNextSongList);
  //return upNextSongList;
}