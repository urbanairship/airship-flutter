/// Live Activity info.
class LiveActivity {
  final String id;
  final String attributeTypes;
  final LiveActivityContent content;
  final Map<String, dynamic> attributes;
  final String state;

  LiveActivity({
    required this.id,
    required this.attributeTypes,
    required this.content,
    required this.attributes,
    required this.state,
  });

  static Map<String, dynamic> _ensureStringDynamicMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    } else if (data is Map) {
      return data.map((key, value) => MapEntry(key.toString(),
          value is Map ? _ensureStringDynamicMap(value) : value));
    }
    throw FormatException(
        'Invalid data format: expected a Map, got ${data.runtimeType}');
  }

  factory LiveActivity.fromJson(dynamic json) {
    final Map<String, dynamic> data = _ensureStringDynamicMap(json);

    return LiveActivity(
      id: data['id'] as String? ?? '',
      attributeTypes: data['attributeTypes'] as String? ?? '',
      content: LiveActivityContent.fromJson(data['content']),
      attributes: _ensureStringDynamicMap(data['attributes'] ?? {}),
      state: data['state'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'attributeTypes': attributeTypes,
        'content': content.toJson(),
        'attributes': attributes,
        'state': state,
      };
}

class LiveActivityContent {
  final Map<String, dynamic> state;
  final String? staleDate;
  final double relevanceScore;

  LiveActivityContent({
    required this.state,
    this.staleDate,
    required this.relevanceScore,
  });

  factory LiveActivityContent.fromJson(dynamic json) {
    final Map<String, dynamic> data =
        LiveActivity._ensureStringDynamicMap(json);

    return LiveActivityContent(
      state: LiveActivity._ensureStringDynamicMap(data['state'] ?? {}),
      staleDate: data['staleDate'] as String?,
      relevanceScore: (data['relevanceScore'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'state': state,
        'staleDate': staleDate,
        'relevanceScore': relevanceScore,
      };
}

/// Base Live Activity request.
abstract class LiveActivityRequest {
  final String attributesType;

  const LiveActivityRequest({required this.attributesType});

  Map<String, dynamic> toJson();
}

/// Live Activity list request.
class LiveActivityListRequest extends LiveActivityRequest {
  const LiveActivityListRequest({required String attributesType})
      : super(attributesType: attributesType);

  @override
  Map<String, dynamic> toJson() => {'attributesType': attributesType};
}

/// Live Activity start request.
class LiveActivityStartRequest extends LiveActivityRequest {
  final LiveActivityContent content;
  final Map<String, dynamic> attributes;

  const LiveActivityStartRequest({
    required String attributesType,
    required this.content,
    required this.attributes,
  }) : super(attributesType: attributesType);

  @override
  Map<String, dynamic> toJson() => {
        'attributesType': attributesType,
        'content': content.toJson(),
        'attributes': attributes,
      };
}

/// Live Activity update request.
class LiveActivityUpdateRequest extends LiveActivityRequest {
  final String activityId;
  final LiveActivityContent content;

  const LiveActivityUpdateRequest({
    required String attributesType,
    required this.activityId,
    required this.content,
  }) : super(attributesType: attributesType);

  @override
  Map<String, dynamic> toJson() => {
        'attributesType': attributesType,
        'activityId': activityId,
        'content': content.toJson(),
      };
}

/// Live Activity end request.
class LiveActivityStopRequest extends LiveActivityRequest {
  final String activityId;
  final LiveActivityContent? content;
  final LiveActivityDismissalPolicy dismissalPolicy;

  const LiveActivityStopRequest({
    required String attributesType,
    required this.activityId,
    this.content,
    this.dismissalPolicy = const LiveActivityDismissalPolicyDefault(),
  }) : super(attributesType: attributesType);

  @override
  Map<String, dynamic> toJson() => {
        'attributesType': attributesType,
        'activityId': activityId,
        if (content != null) 'content': content!.toJson(),
        'dismissalPolicy': dismissalPolicy.toJson(),
      };
}

/// Live Activity dismissal policy.
abstract class LiveActivityDismissalPolicy {
  const LiveActivityDismissalPolicy();

  Map<String, dynamic> toJson();
}

class LiveActivityDismissalPolicyImmediate extends LiveActivityDismissalPolicy {
  const LiveActivityDismissalPolicyImmediate();

  @override
  Map<String, dynamic> toJson() => const {'type': 'immediate'};
}

class LiveActivityDismissalPolicyDefault extends LiveActivityDismissalPolicy {
  const LiveActivityDismissalPolicyDefault();

  @override
  Map<String, dynamic> toJson() => const {'type': 'default'};
}

class LiveActivityDismissalPolicyAfterDate extends LiveActivityDismissalPolicy {
  final String date;

  const LiveActivityDismissalPolicyAfterDate(this.date);

  @override
  Map<String, dynamic> toJson() => {
        'type': 'after',
        'date': date,
      };
}
