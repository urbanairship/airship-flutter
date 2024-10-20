/// Live Update info.
class LiveUpdate {
  final String name;
  final String type;
  final dynamic content;
  final String lastContentUpdateTimestamp;
  final String lastStateChangeTimestamp;
  final String? dismissTimestamp;

  LiveUpdate({
    required this.name,
    required this.type,
    required this.content,
    required this.lastContentUpdateTimestamp,
    required this.lastStateChangeTimestamp,
    this.dismissTimestamp,
  });

  factory LiveUpdate.fromJson(dynamic json) {
    return LiveUpdate(
      name: json['name'] as String,
      type: json['type'] as String,
      content: json['content'] as dynamic,
      lastContentUpdateTimestamp: json['lastContentUpdateTimestamp'] as String,
      lastStateChangeTimestamp: json['lastStateChangeTimestamp'] as String,
      dismissTimestamp: json['dismissTimestamp'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'type': type,
        'content': content,
        'lastContentUpdateTimestamp': lastContentUpdateTimestamp,
        'lastStateChangeTimestamp': lastStateChangeTimestamp,
        'dismissTimestamp': dismissTimestamp,
      };
}

/// Live Update list request.
class LiveUpdateListRequest {
  final String type;

  const LiveUpdateListRequest({required this.type});

  Map<String, dynamic> toJson() => {'type': type};
}

/// Live Update update request.
class LiveUpdateUpdateRequest {
  final String name;
  final Map<String, dynamic> content;
  final String? timestamp;
  final String? dismissTimestamp;

  const LiveUpdateUpdateRequest({
    required this.name,
    required this.content,
    this.timestamp,
    this.dismissTimestamp,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'content': content,
        if (timestamp != null) 'timestamp': timestamp,
        if (dismissTimestamp != null) 'dismissTimestamp': dismissTimestamp,
      };
}

/// Live Update end request.
class LiveUpdateEndRequest {
  final String name;
  final Map<String, dynamic>? content;
  final String? timestamp;
  final String? dismissTimestamp;

  const LiveUpdateEndRequest({
    required this.name,
    this.content,
    this.timestamp,
    this.dismissTimestamp,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        if (content != null) 'content': content,
        if (timestamp != null) 'timestamp': timestamp,
        if (dismissTimestamp != null) 'dismissTimestamp': dismissTimestamp,
      };
}

/// Live Update start request.
class LiveUpdateStartRequest {
  final String name;
  final String type;
  final Map<String, dynamic> content;
  final String? timestamp;
  final String? dismissalTimestamp;

  const LiveUpdateStartRequest({
    required this.name,
    required this.type,
    required this.content,
    this.timestamp,
    this.dismissalTimestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'content': content,
      if (timestamp != null) 'timestamp': timestamp,
      if (dismissalTimestamp != null) 'dismissalTimestamp': dismissalTimestamp,
    };
  }
}
