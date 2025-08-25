class MilestoneItem {
  String title;
  String description;
  List<String> relatedVideoIds;

  MilestoneItem({
    required this.title,
    required this.description,
    this.relatedVideoIds = const [],
  });

  factory MilestoneItem.fromJson(Map<String, dynamic> json) {
    return MilestoneItem(
      title: json['title'] as String,
      description: json['description'] as String,
      relatedVideoIds: (json['relatedVideoIds'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'relatedVideoIds': relatedVideoIds,
      };
}
