abstract class MediaType {
  String type;
  Map<String, dynamic> toMap();
}


class Track extends MediaType {
  String trackName;
  String albumName;
  int trackNumber;
  int year;
  String albumArtistName;
  List<dynamic> trackArtistNames;
  String filePath;
  /* Made albumArtId mutable to deal with file intents. */
  int albumArtId;
  String albumArtHigh;
  String albumArtMedium;
  String albumArtLow;
  int trackDuration;
  String trackId;
  String albumId;
  String type = 'Track';

  @override
  Map<String, dynamic> toMap() {
    return {
      'trackName': this.trackName,
      'albumName': this.albumName,
      'trackNumber': this.trackNumber,
      'year': this.year,
      'albumArtistName': this.albumArtistName,
      'trackArtistNames': this.trackArtistNames ?? <dynamic>['Unknown Artist'],
      'filePath' : this.filePath,
      'albumArtId': this.albumArtId,
      'albumArtHigh': this.albumArtHigh,
      'albumArtMedium': this.albumArtHigh,
      'albumArtLow': this.albumArtHigh,
      'trackDuration': this.trackDuration,
      'trackId': this.trackId,
      'albumId': this.albumId,
      'type': this.type,
    };
  }
  
  static Track fromMap(Map<String, dynamic> trackMap) {
    return new Track(
      trackName: trackMap['trackName'] ?? 'Unknown Track',
      albumName: trackMap['albumName'] ?? 'Unknown Album',
      trackNumber: trackMap['trackNumber'],
      year: trackMap['year'],
      albumArtistName: trackMap['albumArtistName'] ?? 'Unknown Artist',
      trackArtistNames: trackMap['trackArtistNames'] ?? <dynamic>['Unknown Artist'],
      filePath: trackMap['filePath'],
      albumArtId: trackMap['albumArtId'],
      albumArtHigh: trackMap['albumArtHigh'],
      albumArtMedium: trackMap['albumArtMedium'],
      albumArtLow: trackMap['albumArtLow'],
      trackDuration: trackMap['trackDuration'],
      trackId: trackMap['trackId'],
      albumId: trackMap['albumId'],
    );
  }

  Track({this.trackName, this.albumName, this.trackNumber, this.year, this.albumArtistName, this.trackArtistNames, this.albumArtId, this.filePath, this.albumArtHigh, this.albumArtMedium, this.albumArtLow, this.trackDuration, this.trackId, this.albumId});
}


class Album extends MediaType {
  String albumName;
  int year;
  String albumArtistName;
  int albumArtId;
  List<Track> tracks = <Track>[];
  String albumArtHigh;
  String albumArtMedium;
  String albumArtLow;
  String albumId;
  String type = 'Album';

  @override
  Map<String, dynamic> toMap() {
    List<dynamic> tracks = <dynamic>[];    
    for (Track track in this.tracks) {
      tracks.add(track.toMap());
    }
    return {
      'albumName': this.albumName,
      'year': this.year,
      'albumArtistName': this.albumArtistName,
      'albumArtId': this.albumArtId,
      'tracks': this.tracks,
      'albumArtHigh': this.albumArtHigh,
      'albumArtMedium': this.albumArtHigh,
      'albumArtLow': this.albumArtHigh,
      'albumId': this.albumId,
      'type': this.type,
    };
  }

  static Album fromMap(Map<String, dynamic> albumMap) {
    return new Album(
      albumName: albumMap['albumName'] ?? 'Unknown Album',
      year: albumMap['year'],
      albumArtistName: albumMap['albumArtistName'] ?? 'Unknown Artist',
      albumArtId: albumMap['albumArtId'],
      albumArtHigh: albumMap['albumArtHigh'],
      albumArtMedium: albumMap['albumArtMedium'],
      albumArtLow: albumMap['albumArtLow'],
      albumId: albumMap['albumId']
    );
  }

  Album({this.albumName, this.year, this.albumArtistName, this.albumArtId, this.albumArtHigh, this.albumArtMedium, this.albumArtLow, this.albumId});
}

/* TODO: Update Artist according to new specs. */
class Artist extends MediaType {
  String artistName;
  List<Album> albums = <Album>[];
  List<Track> tracks = <Track>[];
  String type = 'Artist';

  @override
  Map<String, dynamic> toMap() {
    List<dynamic> tracks = <dynamic>[];    
    for (Track track in this.tracks) {
      tracks.add(track.toMap());
    }
    List<dynamic> albums = <dynamic>[];    
    for (Album album in this.albums) {
      albums.add(album.toMap());
    }
    return {
      'trackArtistNames': this.artistName,
      'albums': albums,
      'tracks': tracks,
      'type': this.type,
    };
  }

  static Artist fromMap(Map<String, dynamic> artistMap) {
    return new Artist(
      artistName: artistMap['artistName'],
    );
  }

  Artist({this.artistName});
}


class Playlist extends MediaType {
  String playlistName;
  int playlistId;
  List<Track> tracks = <Track>[];
  String type = 'Playlist';

  @override
  Map<String, dynamic> toMap() {
    List<dynamic> tracks = <dynamic>[];
    for (Track track in this.tracks) {
      tracks.add(track.toMap());
    }
    return {
      'playlistName': this.playlistName,
      'playlistId': this.playlistId,
      'tracks': tracks,
      'type': this.type,
    };
  }

  Playlist({this.playlistName, this.playlistId});
}


List<MediaType> mediaTypes = <MediaType>[
  new Album(),
  new Track(),
  new Artist(),
];

