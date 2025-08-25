import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/todo_item.dart';
import '../models/milestone_item.dart';
import 'tasks_screen.dart';
import 'inspiration_screen.dart';
import '../api_keys.dart';


class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  List<ToDoItem> _toDoItems = [];
  List<MilestoneItem> _milestoneItems = [];
  bool _isLoading = true;

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? todoJsonString = prefs.getString('todo_list');
    final String? milestoneJsonString = prefs.getString('milestone_list');
    setState(() {
      if (todoJsonString != null) {
        final List<dynamic> jsonList = json.decode(todoJsonString);
        _toDoItems = jsonList.map((e) => ToDoItem.fromJson(e)).toList();
      } else {
        _toDoItems = [];
      }
      if (milestoneJsonString != null) {
        final List<dynamic> jsonList = json.decode(milestoneJsonString);
        _milestoneItems = jsonList.map((e) => MilestoneItem.fromJson(e)).toList();
      } else {
        _milestoneItems = [];
      }
      _isLoading = false;
    });
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    final String todoJsonString = json.encode(_toDoItems.map((e) => e.toJson()).toList());
    await prefs.setString('todo_list', todoJsonString);
    final String milestoneJsonString = json.encode(_milestoneItems.map((e) => e.toJson()).toList());
    await prefs.setString('milestone_list', milestoneJsonString);
  }

  void _addMilestone(String title, String description) {
    setState(() {
      _milestoneItems.add(MilestoneItem(title: title, description: description));
    });
    _saveData();
  }

  void _editMilestone(int index, String newTitle, String newDescription) {
    setState(() {
      _milestoneItems[index].title = newTitle;
      _milestoneItems[index].description = newDescription;
    });
    _saveData();
  }

  void _removeMilestone(int index) {
    setState(() {
      _milestoneItems.removeAt(index);
    });
    _saveData();
  }

  void _addToDo(String title) {
    setState(() {
      _toDoItems.add(ToDoItem(title: title));
    });
    _saveData();
  }

  void _editToDo(int index, String newTitle) {
    setState(() {
      _toDoItems[index].title = newTitle;
    });
    _saveData();
  }

  void _removeToDo(int index) {
    setState(() {
      _toDoItems.removeAt(index);
    });
    _saveData();
  }

  void _toggleDone(int index, bool? value) {
    setState(() {
      _toDoItems[index].isDone = value ?? false;
    });
    _saveData();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }



  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final List<Widget> _widgetOptions = <Widget>[
      TasksScreen(
        toDoItems: _toDoItems,
        milestoneItems: _milestoneItems,
        onAddToDo: _addToDo,
        onEditToDo: _editToDo,
        onRemoveToDo: _removeToDo,
        onToggleDone: _toggleDone,
        onAddMilestone: _addMilestone,
        onEditMilestone: _editMilestone,
        onRemoveMilestone: _removeMilestone,
      ),
      InspirationScreen(
        milestoneItems: _milestoneItems,
        apiKey: youtubeApiKey,
      ),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('You ToBe'),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle_outline),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lightbulb_outline),
            label: 'Inspiration',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
