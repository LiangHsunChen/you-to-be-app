import 'package:flutter/material.dart';
import '../models/todo_item.dart';
import '../models/milestone_item.dart';
import '../widgets/todo_list.dart';
import '../widgets/milestone_list.dart';


class TasksScreen extends StatefulWidget {
  final List<ToDoItem> toDoItems;
  final List<MilestoneItem> milestoneItems;
  final void Function(String) onAddToDo;
  final void Function(int, String) onEditToDo;
  final void Function(int) onRemoveToDo;
  final void Function(int, bool?) onToggleDone;
  final void Function(String, String) onAddMilestone;
  final void Function(int, String, String) onEditMilestone;
  final void Function(int) onRemoveMilestone;

  const TasksScreen({
    super.key,
    required this.toDoItems,
    required this.milestoneItems,
    required this.onAddToDo,
    required this.onEditToDo,
    required this.onRemoveToDo,
    required this.onToggleDone,
    required this.onAddMilestone,
    required this.onEditMilestone,
    required this.onRemoveMilestone,
  });

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  int _tabIndex = 0;

  void _showAddToDoDialog() {
    String newTitle = '';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add To-Do'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(hintText: 'Enter to-do title'),
            onChanged: (value) => newTitle = value,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (newTitle.trim().isNotEmpty) {
                  widget.onAddToDo(newTitle.trim());
                }
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showAddMilestoneDialog() {
    String title = '';
    String description = '';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Milestone'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                autofocus: true,
                decoration: const InputDecoration(hintText: 'Title'),
                onChanged: (value) => title = value,
              ),
              TextField(
                decoration: const InputDecoration(hintText: 'Description'),
                onChanged: (value) => description = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (title.trim().isNotEmpty) {
                  widget.onAddMilestone(title.trim(), description.trim());
                }
                Navigator.of(context).pop();
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Builder(
        builder: (context) {
          final TabController tabController = DefaultTabController.of(context);
          tabController.addListener(() {
            if (_tabIndex != tabController.index) {
              setState(() {
                _tabIndex = tabController.index;
              });
            }
          });
          return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              toolbarHeight: 0,
              bottom: const TabBar(
                tabs: [
                  Tab(text: 'To-Do'),
                  Tab(text: 'Milestones'),
                ],
                indicatorColor: Colors.deepPurpleAccent,
                labelColor: Colors.white,
              ),
            ),
            body: TabBarView(
              children: [
                ToDoList(
                  items: widget.toDoItems,
                  onAdd: widget.onAddToDo,
                  onEdit: widget.onEditToDo,
                  onRemove: widget.onRemoveToDo,
                  onToggleDone: widget.onToggleDone,
                ),
                MilestoneList(
                  items: widget.milestoneItems,
                  onAdd: widget.onAddMilestone,
                  onEdit: widget.onEditMilestone,
                  onRemove: widget.onRemoveMilestone,
                ),
              ],
            ),
            floatingActionButton: _tabIndex == 0
                ? FloatingActionButton(
                    onPressed: _showAddToDoDialog,
                    child: const Icon(Icons.add),
                  )
                : FloatingActionButton(
                    onPressed: _showAddMilestoneDialog,
                    child: const Icon(Icons.add),
                  ),
          );
        },
      ),
    );
  }
}
