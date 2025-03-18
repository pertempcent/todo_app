import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:todo_app/core/providers/task_provider.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class TasksScreen extends StatefulWidget {
  final String userName;

  TasksScreen({required this.userName});

  @override
  _TasksScreenState createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Welcome ${widget.userName}')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('My tasks (${taskProvider.tasks.length} items)', style: TextStyle(fontSize: 18)),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: taskProvider.tasks.length,
              itemBuilder: (context, index) {
                final task = taskProvider.tasks[index];
                final createdAt = DateTime.parse(task['createdAt']);
                final formattedDate = '${createdAt.day}-${createdAt.month}-${createdAt.year} ${createdAt.hour}:${createdAt.minute}';

                return GestureDetector(
                  onLongPressStart: (_) {
                    setState(() {
                      task['isSelected'] = !task['isSelected'];
                    });
                  },
                  child: Card(
                    margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListTile(
                      leading: Checkbox(
                        value: task['isSelected'] ?? false,
                        onChanged: (value) {
                          setState(() {
                            task['isSelected'] = value;
                          });
                        },
                      ),
                      title: Text(
                        task['name'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          decoration: task['isSelected'] == true ? TextDecoration.lineThrough : TextDecoration.none,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (task['isSelected'] != true)
                            Text('Created: $formattedDate', style: TextStyle(fontSize: 14)),
                          if (task['isSelected'] != true)
                            Text('Author: ${task['owner']}'),
                          if (task['isSelected'] != true)
                            Text('Description: ${task['description']}'),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  final nameController = TextEditingController(text: task['name']);
                                  final descriptionController = TextEditingController(text: task['description']);
                                  final assigneeController = TextEditingController(text: task['owner']);
                                  return AlertDialog(
                                    title: Text("Edit Task"),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextField(
                                          controller: nameController,
                                          decoration: InputDecoration(labelText: 'Task Name'),
                                        ),
                                        TextField(
                                          controller: descriptionController,
                                          decoration: InputDecoration(labelText: 'Task Description'),
                                        ),
                                        TextField(
                                          controller: assigneeController,
                                          decoration: InputDecoration(labelText: 'Assignee'),
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          taskProvider.updateTask(
                                            task,
                                            nameController.text,
                                            descriptionController.text,
                                            assigneeController.text,
                                          );
                                          Navigator.of(context).pop();
                                        },
                                        child: Text("Save"),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.share),
                            onPressed: () {
                              final formattedText = '''
Task Owner: ${task['owner']}
Task Name: ${task['name']}
Task Description: ${task['description']}
Created On: ${task['createdAt']}
''';
                              Share.share(formattedText);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.copy),
                            onPressed: () {
                              final formattedText = '''
Task Owner: ${task['owner']}
Task Name: ${task['name']}
Task Description: ${task['description']}
Created On: ${task['createdAt']}
''';
                              Clipboard.setData(ClipboardData(text: formattedText));
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              taskProvider.deleteTask(task);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              final nameController = TextEditingController();
              final descriptionController = TextEditingController();
              final assigneeController = TextEditingController(text: widget.userName);
              return AlertDialog(
                title: Text("Add Task"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(labelText: 'Task Name'),
                    ),
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(labelText: 'Task Description'),
                    ),
                    TextField(
                      controller: assigneeController,
                      decoration: InputDecoration(labelText: 'Assignee'),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      taskProvider.addTask(
                        nameController.text,
                        descriptionController.text,
                        assigneeController.text,
                      );
                      Navigator.of(context).pop();
                    },
                    child: Text("Add Task"),
                  ),
                ],
              );
            },
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
