import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String email;
  final String displayName;
  final String? pairId;
  final DateTime createdAt;

  const AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    this.pairId,
    required this.createdAt,
  });

  factory AppUser.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? {};
    return AppUser(
      uid: snapshot.id,
      email: data['email'] as String? ?? '',
      displayName: data['displayName'] as String? ?? 'Partner',
      pairId: data['pairId'] as String?,
      createdAt: (data['createdAt'] is Timestamp)
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'email': email,
    'displayName': displayName,
    'pairId': pairId,
    'createdAt': Timestamp.fromDate(createdAt),
  };
}

class ReadState {
  final String? fileUrl;
  final String? fileName;
  final String? fileType;
  final int page;
  final int totalPages;
  final String? updatedBy;
  final DateTime? updatedAt;

  const ReadState({
    this.fileUrl,
    this.fileName,
    this.fileType,
    this.page = 1,
    this.totalPages = 1,
    this.updatedBy,
    this.updatedAt,
  });

  factory ReadState.fromMap(Map<String, dynamic>? data) {
    if (data == null) return const ReadState();
    return ReadState(
      fileUrl: data['fileUrl'] as String?,
      fileName: data['fileName'] as String?,
      fileType: data['fileType'] as String?,
      page: (data['page'] as num?)?.toInt() ?? 1,
      totalPages: (data['totalPages'] as num?)?.toInt() ?? 1,
      updatedBy: data['updatedBy'] as String?,
      updatedAt: data['updatedAt'] is Timestamp ? (data['updatedAt'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toMap() => {
    'fileUrl': fileUrl,
    'fileName': fileName,
    'fileType': fileType,
    'page': page,
    'totalPages': totalPages,
    'updatedBy': updatedBy,
    'updatedAt': FieldValue.serverTimestamp(),
  };
}

class WatchState {
  final String? videoUrl;
  final String? youtubeId;
  final double positionSec;
  final bool playing;
  final String? updatedBy;
  final DateTime? updatedAt;

  const WatchState({
    this.videoUrl,
    this.youtubeId,
    this.positionSec = 0.0,
    this.playing = false,
    this.updatedBy,
    this.updatedAt,
  });

  factory WatchState.fromMap(Map<String, dynamic>? data) {
    if (data == null) return const WatchState();
    return WatchState(
      videoUrl: data['videoUrl'] as String?,
      youtubeId: data['youtubeId'] as String?,
      positionSec: (data['positionSec'] as num?)?.toDouble() ?? 0.0,
      playing: data['playing'] as bool? ?? false,
      updatedBy: data['updatedBy'] as String?,
      updatedAt: data['updatedAt'] is Timestamp ? (data['updatedAt'] as Timestamp).toDate() : null,
    );
  }

  Map<String, dynamic> toMap() => {
    'videoUrl': videoUrl,
    'youtubeId': youtubeId,
    'positionSec': positionSec,
    'playing': playing,
    'updatedBy': updatedBy,
    'updatedAt': FieldValue.serverTimestamp(),
  };
}

class Pair {
  final String code;
  final List<String> memberIds;
  final Map<String, String> memberNames;
  final DateTime createdAt;
  final ReadState readState;
  final WatchState watchState;

  const Pair({
    required this.code,
    required this.memberIds,
    required this.memberNames,
    required this.createdAt,
    this.readState = const ReadState(),
    this.watchState = const WatchState(),
  });

  factory Pair.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? {};
    final rawMembers = data['memberIds'] as List<dynamic>? ?? [];
    final rawNames = data['memberNames'] as Map<String, dynamic>? ?? {};

    return Pair(
      code: snapshot.id,
      memberIds: rawMembers.map((e) => e.toString()).toList(),
      memberNames: rawNames.map((k, v) => MapEntry(k, v.toString())),
      createdAt: data['createdAt'] is Timestamp ? (data['createdAt'] as Timestamp).toDate() : DateTime.now(),
      readState: ReadState.fromMap(data['readState'] as Map<String, dynamic>?),
      watchState: WatchState.fromMap(data['watchState'] as Map<String, dynamic>?),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'code': code,
    'memberIds': memberIds,
    'memberNames': memberNames,
    'createdAt': Timestamp.fromDate(createdAt),
    'readState': readState.toMap(),
    'watchState': watchState.toMap(),
  };

  String getPartnerName(String myUid) {
    for (final entry in memberNames.entries) {
      if (entry.key != myUid) return entry.value;
    }
    return 'Partner';
  }

  bool get isFull => memberIds.length >= 2;
}

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime createdAt;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.createdAt,
  });

  factory ChatMessage.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? {};
    return ChatMessage(
      id: snapshot.id,
      senderId: data['senderId'] as String? ?? '',
      senderName: data['senderName'] as String? ?? 'Anonymous',
      text: data['text'] as String? ?? '',
      createdAt: data['createdAt'] is Timestamp ? (data['createdAt'] as Timestamp).toDate() : DateTime.now(),
    );
  }
}

class NoteEntry {
  final String id;
  final String authorId;
  final String authorName;
  final String text;
  final DateTime createdAt;

  const NoteEntry({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.text,
    required this.createdAt,
  });

  factory NoteEntry.fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data() ?? {};
    return NoteEntry(
      id: snapshot.id,
      authorId: data['authorId'] as String? ?? '',
      authorName: data['authorName'] as String? ?? 'Anonymous',
      text: data['text'] as String? ?? '',
      createdAt: data['createdAt'] is Timestamp ? (data['createdAt'] as Timestamp).toDate() : DateTime.now(),
    );
  }
}