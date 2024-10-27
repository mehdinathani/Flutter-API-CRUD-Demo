import 'dart:convert';
import 'dart:developer';

import 'package:apigetdemo/task_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CrudView extends StatefulWidget {
  const CrudView({super.key});

  @override
  State<CrudView> createState() => _CrudViewState();
}

class _CrudViewState extends State<CrudView> {
  final baseURL = "ca9be156b1e092ffef4c.free.beeceptor.com";
  TextEditingController titleController = TextEditingController();

  Future<List<Task>> getTask() async {
    final url = Uri.https(baseURL, "/api/tasks/");
    final response = await http.get(url);
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((task) => Task.fromJson(task)).toList();
    } else {
      throw Exception('Failed to load Data.');
    }
  }

  Future<Task> createTask(Task task) async {
    final url = Uri.https(baseURL, "/api/tasks/");
    final response = await http.post(
      url,
      // headers: {
      //   "Content-Type": "application/json",
      // },
      body: jsonEncode(task.toJson()),
    );
    log('Response status: ${response.statusCode}');
    log('Response body: ${response.body}');

    if (response.statusCode == 200) {
      return Task.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("Failed to create task");
    }
  }

  Future<void> updateTask(String id, Task task) async {
    final url = Uri.https(baseURL, "/api/tasks/$id");
    log(url.toString());
    final response = await http.put(url, body: jsonEncode(task.toJson()));
    if (response.statusCode != 200) {
      throw Exception('Failed to update Task');
    }
  }

  Future<void> deleteTask(String id) async {
    final url = Uri.https(baseURL, '/api/tasks/$id');
    final response = await http.delete(url);
    if (response.statusCode != 200) {
      throw Exception('Failed to Delete task');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Crud API"),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder(
              future: getTask(),
              builder:
                  (BuildContext context, AsyncSnapshot<List<Task>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("No Data"));
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final task = snapshot.data![index];
                      return ListTile(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              titleController.text = task.title;
                              return AlertDialog(
                                title: const Text("Update Task"),
                                content: TextField(
                                  controller: titleController,
                                  decoration: const InputDecoration(
                                    labelText: "Task Title",
                                  ),
                                ),
                                actions: [
                                  ElevatedButton(
                                    onPressed: () async {
                                      // Update task title
                                      task.title = titleController.text;
                                      await updateTask(task.id!, task);
                                      Navigator.pop(context);
                                      setState(() {}); // Refresh the UI
                                    },
                                    child: const Text("Update"),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        title: Text(task.title),
                        subtitle: Text(task.description),
                        trailing: IconButton(
                            onPressed: () async {
                              await deleteTask(task.id!);
                              setState(() {});
                            },
                            icon: const Icon(Icons.delete)),
                      );
                    },
                  );
                }
              },
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await createTask(
                Task(
                  title: "My second Task",
                  description: "My second task description",
                ),
              );
              setState(() {}); // Refresh UI after task creation
            },
            child: const Text("Add Task"),
          ),
          // ElevatedButton(onPressed: () async {
          //   await updateTask(id, task)
          // }, child: const Text("Log ID Task"))
        ],
      ),
    );
  }
}
