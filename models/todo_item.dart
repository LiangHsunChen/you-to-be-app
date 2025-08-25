
class ToDoItem {
  String title;
  bool isDone;

  ToDoItem({required this.title, this.isDone = false});

  factory ToDoItem.fromJson(Map<String, dynamic> json) {
    return ToDoItem(
      title: json['title'] as String,
      isDone: json['isDone'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'isDone': isDone,
      };
}
