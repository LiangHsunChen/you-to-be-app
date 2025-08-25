import 'package:flutter/material.dart';
import '../models/todo_item.dart';


class ToDoList extends StatelessWidget {
  final List<ToDoItem> items;
  final void Function(String) onAdd;
  final void Function(int, String) onEdit;
  final void Function(int) onRemove;
  final void Function(int, bool?) onToggleDone;

  const ToDoList({
    super.key,
    required this.items,
    required this.onAdd,
    required this.onEdit,
    required this.onRemove,
    required this.onToggleDone,
  });

  void _showEditDialog(BuildContext context, int index, String currentTitle) {
    String newTitle = currentTitle;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit To-Do'),
          content: TextField(
            autofocus: true,
            controller: TextEditingController(text: currentTitle),
            onChanged: (value) => newTitle = value,
            decoration: const InputDecoration(hintText: 'Enter to-do title'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (newTitle.trim().isNotEmpty) {
                  onEdit(index, newTitle.trim());
                }
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Dismissible(
          key: ValueKey(item.title + index.toString()),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (_) => onRemove(index),
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            child: ListTile(
              title: Text(
                item.title,
                style: TextStyle(
                  decoration: item.isDone ? TextDecoration.lineThrough : null,
                  color: item.isDone ? Colors.white54 : Colors.white,
                ),
              ),
              leading: Checkbox(
                value: item.isDone,
                onChanged: (bool? value) => onToggleDone(index, value),
                activeColor: Colors.deepPurpleAccent,
              ),
              trailing: IconButton(
                icon: const Icon(Icons.edit, color: Colors.white70),
                onPressed: () => _showEditDialog(context, index, item.title),
              ),
            ),
          ),
        );
      },
    );
  }
}
