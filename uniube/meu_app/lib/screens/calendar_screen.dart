import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Task {
  String text;
  bool done;
  Task({required this.text, this.done = false});
}

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDate = DateTime.now();
  final Map<String, List<Task>> _tasksByDay = {};

  String _keyFor(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

  List<Task> _getTasksFor(DateTime d) {
    final key = _keyFor(d);
    final list = _tasksByDay[key] ?? [];
    final pending = list.where((t) => !t.done).toList()
      ..sort((a, b) => a.text.toLowerCase().compareTo(b.text.toLowerCase()));
    final done = list.where((t) => t.done).toList()
      ..sort((a, b) => a.text.toLowerCase().compareTo(b.text.toLowerCase()));
    return [...pending, ...done];
  }

  void _addTask(DateTime day, String text) {
    final key = _keyFor(day);
    setState(() {
      _tasksByDay.putIfAbsent(key, () => []).add(Task(text: text));
    });
  }

  void _removeTask(DateTime day, Task task) {
    final key = _keyFor(day);
    setState(() {
      _tasksByDay[key]?.remove(task);
    });
  }

  void _toggleDone(DateTime day, Task task) {
    setState(() => task.done = !task.done);
  }

  Future<void> _showAddTaskDialog() async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0C0C0C),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Text("Nova tarefa", style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: controller,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Digite a tarefa",
              hintStyle: const TextStyle(color: Colors.white54),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.purple.shade400),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.purple.shade200),
              ),
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Cancelar", style: TextStyle(color: Colors.white70)),
              onPressed: () => Navigator.pop(ctx),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C2BFF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Adicionar"),
              onPressed: () {
                final txt = controller.text.trim();
                if (txt.isNotEmpty) _addTask(_selectedDate, txt);
                Navigator.pop(ctx);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF9F2BFF),
              onPrimary: Colors.white,
              surface: Color(0xFF1F1F1F),
            ),
            dialogBackgroundColor: const Color(0xFF0C0C0C),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final tasks = _getTasksFor(_selectedDate);
    final dateLabel = DateFormat('dd/MM/yyyy').format(_selectedDate);

    return Scaffold(
      backgroundColor: const Color(0xFF0C0C0C),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          "Bem-vindo, José!",
          style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("RA: 1181583",
              style: TextStyle(color: Colors.white70, fontSize: 15)
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7C2BFF), Color(0xFF9F2BFF)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Text(dateLabel,
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A0072),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.calendar_month, color: Colors.white),
                    label: const Text("Selecionar dia"),
                    onPressed: _pickDate,
                  )
                ],
              ),
            ),
            const SizedBox(height: 18),
            Text(
              "Tarefas de $dateLabel",
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: tasks.isEmpty
                  ? const Center(
                      child: Text("Nenhuma tarefa", style: TextStyle(color: Colors.white54)),
                    )
                  : ListView.separated(
                      itemBuilder: (_, i) => _taskItem(tasks[i]),
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemCount: tasks.length,
                    ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF9F2BFF),
        onPressed: _showAddTaskDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _taskItem(Task task) {
    final isDone = task.done;
    return Dismissible(
      key: UniqueKey(),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade700,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => _removeTask(_selectedDate, task),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: const Color(0xFF161616),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => _toggleDone(_selectedDate, task),
              child: Icon(
                isDone ? Icons.check_circle : Icons.radio_button_unchecked,
                color: isDone ? Colors.greenAccent : Colors.orangeAccent,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                task.text,
                style: TextStyle(
                  fontSize: 16,
                  color: isDone ? Colors.white54 : Colors.white,
                  decoration: isDone ? TextDecoration.lineThrough : TextDecoration.none,
                ),
              ),
            ),
            IconButton(
              onPressed: () => _removeTask(_selectedDate, task),
              icon: const Icon(Icons.delete_outline, color: Colors.white54),
            )
          ],
        ),
      ),
    );
  }
}
