class CustomEvent {
  final String event;
  final Map<String, dynamic> data;
  CustomEvent({
    required this.event,
    required this.data,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'event': event,
      'data': data,
    };
  }
}
