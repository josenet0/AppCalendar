import 'package:flutter/material.dart';
import '../models/task.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  List<Task> tasks = [];
  late DateTime selectedDate;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    selectedDate =
        ModalRoute.of(context)!.settings.arguments as DateTime; // Recebe o dia
  }

  // Adicionar tarefa (ShowDialog)
  void _addTask() {
    TextEditingController taskController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Adicionar tarefa'),
          content: TextField(
            controller: taskController,
            decoration: const InputDecoration(hintText: 'Nome da tarefa'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                if (taskController.text.isNotEmpty) {
                  setState(() {
                    tasks.add(
                      Task(name: taskController.text, date: selectedDate),
                    );
                  });
                }
                Navigator.pop(context);
              },
              child: const Text('Adicionar'),
            ),
          ],
        );
      },
    );
  }

  // Ordenação: pendentes primeiro + ordem alfabética
  List<Task> get sortedTasks {
    List<Task> pending = tasks.where((task) => !task.completed).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    List<Task> completed = tasks.where((task) => task.completed).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    return [...pending, ...completed];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple.shade900,
        onPressed: _addTask,
        child: const Icon(Icons.add),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: const Color(0xFF8A00FF),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título com Data
                Text(
                  'Tarefas de ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),

                // Lista de tarefas
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: sortedTasks.isEmpty
                        ? const Center(
                            child: Text(
                              'Nenhuma tarefa adicionada.',
                              style: TextStyle(color: Colors.black54),
                            ),
                          )
                        : ListView.builder(
                            itemCount: sortedTasks.length,
                            itemBuilder: (context, index) {
                              Task task = sortedTasks[index];
                              return ListTile(
                                leading: Checkbox(
                                  value: task.completed,
                                  onChanged: (value) {
                                    setState(() {
                                      task.completed = value!;
                                    });
                                  },
                                ),
                                title: Text(
                                  task.name,
                                  style: TextStyle(
                                    decoration: task.completed
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      tasks.remove(task);
                                    });
                                  },
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
