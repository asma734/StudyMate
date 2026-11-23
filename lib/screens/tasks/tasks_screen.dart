// ══════════════════════════════════════════════════════════════
// TasksScreen — StudyMate AI Companion
// Smart priority-sorted task list with filter tabs.
// ══════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/priority_calculator.dart';
import '../../models/task_model.dart';
import '../../providers/tasks_provider.dart';
import '../../providers/books_provider.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TasksProvider>().loadData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tasksProvider = context.watch<TasksProvider>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Tasks 📝', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary),
            onPressed: () => _showAddTaskSheet(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textMuted,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5),
          indicatorColor: AppColors.primary,
          tabs: [
            Tab(text: 'To Do (${tasksProvider.todoTasks.length})'),
            Tab(text: 'In Progress (${tasksProvider.inProgressTasks.length})'),
            Tab(text: 'Done (${tasksProvider.doneTasks.length})'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Summary banner
          if (tasksProvider.overdueCount > 0)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEB),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Text('⚠️', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 8),
                  Text(
                    '${tasksProvider.overdueCount} overdue task${tasksProvider.overdueCount > 1 ? 's' : ''}!',
                    style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                ],
              ),
            ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _TaskList(tasks: tasksProvider.todoTasks, emptyMsg: 'No tasks to do 🎉'),
                _TaskList(tasks: tasksProvider.inProgressTasks, emptyMsg: 'Nothing in progress yet'),
                _TaskList(tasks: tasksProvider.doneTasks, emptyMsg: 'Complete a task to see it here'),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTaskSheet(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Task', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
    );
  }

  void _showAddTaskSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: context.read<TasksProvider>(),
        child: ChangeNotifierProvider.value(
          value: context.read<BooksProvider>(),
          child: const _AddTaskBottomSheet(),
        ),
      ),
    );
  }
}

// ── Task List ──────────────────────────────────────────────────
class _TaskList extends StatelessWidget {
  final List<TaskModel> tasks;
  final String emptyMsg;

  const _TaskList({required this.tasks, required this.emptyMsg});

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('✅', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 14),
            Text(emptyMsg, style: TextStyle(color: AppColors.textMuted, fontSize: 14, fontWeight: FontWeight.w600)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      itemCount: tasks.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) => _TaskCard(task: tasks[i]),
    );
  }
}

// ── Task Card ──────────────────────────────────────────────────
class _TaskCard extends StatelessWidget {
  final TaskModel task;
  const _TaskCard({required this.task});

  Color get _subjectColor {
    final hex = task.subjectColorHex.replaceAll('#', '');
    try {
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return AppColors.primarySoft;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tasksProvider = context.read<TasksProvider>();
    final score = task.priorityScore;
    final label = PriorityCalculator.label(score);
    final deadlineLabel = PriorityCalculator.deadlineLabel(task.deadline);
    final isOverdue = task.deadline.isBefore(DateTime.now()) && task.status != TaskStatus.done;

    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.12),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 26),
      ),
      onDismissed: (_) => tasksProvider.deleteTask(task.id),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: AppColors.shadowPurple, blurRadius: 8, offset: const Offset(0, 3))],
          border: isOverdue ? Border.all(color: Colors.redAccent.withOpacity(0.3), width: 1.2) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Subject color dot
                Container(
                  width: 10, height: 10,
                  decoration: BoxDecoration(color: _subjectColor, shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    task.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14.5,
                      decoration: task.status == TaskStatus.done ? TextDecoration.lineThrough : null,
                      color: task.status == TaskStatus.done ? AppColors.textLight : AppColors.textMain,
                    ),
                  ),
                ),
                // Priority badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _priorityBg(score),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(label, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              task.subjectName,
              style: TextStyle(color: AppColors.textMuted, fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 12,
                  color: isOverdue ? Colors.redAccent : AppColors.textLight,
                ),
                const SizedBox(width: 4),
                Text(
                  deadlineLabel,
                  style: TextStyle(
                    color: isOverdue ? Colors.redAccent : AppColors.textLight,
                    fontSize: 11.5,
                    fontWeight: isOverdue ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                const Spacer(),
                // Status toggle buttons
                if (task.status == TaskStatus.todo)
                  _statusButton('Start', Icons.play_arrow_rounded, AppColors.primary, () {
                    tasksProvider.markStatus(task.id, TaskStatus.inProgress);
                  }),
                if (task.status == TaskStatus.inProgress)
                  _statusButton('Done ✓', Icons.check_circle_outline_rounded, AppColors.mintDark, () {
                    tasksProvider.markStatus(task.id, TaskStatus.done);
                  }),
                if (task.status == TaskStatus.done)
                  _statusButton('Reopen', Icons.refresh_rounded, AppColors.textMuted, () {
                    tasksProvider.markStatus(task.id, TaskStatus.todo);
                  }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: color, fontSize: 11.5, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  Color _priorityBg(double score) {
    if (score >= 4.0) return const Color(0xFFFFEBEB);
    if (score >= 3.0) return const Color(0xFFFFF3E0);
    if (score >= 2.0) return const Color(0xFFFFFDE7);
    return const Color(0xFFE8F5E9);
  }
}

// ── Add Task Bottom Sheet ──────────────────────────────────────
class _AddTaskBottomSheet extends StatefulWidget {
  const _AddTaskBottomSheet();

  @override
  State<_AddTaskBottomSheet> createState() => _AddTaskBottomSheetState();
}

class _AddTaskBottomSheetState extends State<_AddTaskBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  DateTime _deadline = DateTime.now().add(const Duration(days: 7));
  int _coefficient = 3;
  int _difficulty = 3;
  int _effort = 1;
  TaskType _type = TaskType.homework;
  String _subjectId = '';
  String _subjectName = 'General';
  String _subjectColorHex = '#B8A7EA';

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final urgency = PriorityCalculator.urgencyFromDeadline(_deadline);
    final task = TaskModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      subjectId: _subjectId,
      subjectName: _subjectName,
      subjectColorHex: _subjectColorHex,
      deadline: _deadline,
      type: _type,
      coefficientImportance: _coefficient,
      urgency: urgency,
      difficulty: _difficulty,
      effortInvested: _effort,
    );
    context.read<TasksProvider>().addTask(task);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final books = context.watch<BooksProvider>().subjects;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(28), topRight: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(width: 40, height: 4,
                  decoration: BoxDecoration(color: AppColors.borderLight, borderRadius: BorderRadius.circular(2))),
              ),
              const SizedBox(height: 20),
              const Text('New Academic Task 📝',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textMain)),
              const SizedBox(height: 20),

              // Title
              TextFormField(
                controller: _titleCtrl,
                decoration: _inputDeco('Task Title *', Icons.task_alt_outlined),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Title is required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descCtrl,
                decoration: _inputDeco('Description (optional)', Icons.notes_outlined),
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              // Subject picker
              if (books.isNotEmpty) ...[
                const Text('Subject', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _subjectId.isEmpty ? null : _subjectId,
                  decoration: _inputDeco('Select Subject', Icons.book_outlined),
                  hint: const Text('Select a subject'),
                  items: books.map((s) => DropdownMenuItem(
                    value: s.id,
                    child: Text(s.name),
                  )).toList(),
                  onChanged: (v) {
                    if (v == null) return;
                    final sub = books.firstWhere((s) => s.id == v);
                    setState(() {
                      _subjectId = v;
                      _subjectName = sub.name;
                      _subjectColorHex = sub.colorHex;
                      _coefficient = sub.coefficient.round().clamp(1, 5);
                    });
                  },
                ),
                const SizedBox(height: 16),
              ],

              // Task type
              const Text('Task Type', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: TaskType.values.map((t) {
                  final selected = _type == t;
                  return ChoiceChip(
                    label: Text(_typeLabel(t)),
                    selected: selected,
                    selectedColor: AppColors.primaryLight,
                    labelStyle: TextStyle(
                      color: selected ? AppColors.primary : AppColors.textMuted,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 12,
                    ),
                    onSelected: (_) => setState(() => _type = t),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Deadline
              const Text('Deadline', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _deadline,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) setState(() => _deadline = picked);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.bgLight,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined, color: AppColors.primary, size: 18),
                      const SizedBox(width: 10),
                      Text(
                        '${_deadline.day}/${_deadline.month}/${_deadline.year}  —  ${PriorityCalculator.deadlineLabel(_deadline)}',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Sliders
              _slider('Difficulty', _difficulty, (v) => setState(() => _difficulty = v)),
              _slider('Effort already done', _effort, (v) => setState(() => _effort = v)),

              const SizedBox(height: 8),
              // Priority preview
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Priority Score', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary)),
                    Text(
                      '${PriorityCalculator.compute(
                        coefficientImportance: _coefficient,
                        urgency: PriorityCalculator.urgencyFromDeadline(_deadline),
                        difficulty: _difficulty,
                        effortInvested: _effort,
                      ).toStringAsFixed(2)} / 5.0 — ${PriorityCalculator.label(PriorityCalculator.compute(
                        coefficientImportance: _coefficient,
                        urgency: PriorityCalculator.urgencyFromDeadline(_deadline),
                        difficulty: _difficulty,
                        effortInvested: _effort,
                      ))}',
                      style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      icon: const Icon(Icons.add_task_rounded, size: 18),
                      label: const Text('Add Task', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _slider(String label, int value, ValueChanged<int> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5)),
            Text('$value / 5', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
          ],
        ),
        Slider(
          value: value.toDouble(),
          min: 1, max: 5, divisions: 4,
          activeColor: AppColors.primary,
          onChanged: (v) => onChanged(v.round()),
        ),
        const SizedBox(height: 4),
      ],
    );
  }

  InputDecoration _inputDeco(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
      filled: true,
      fillColor: AppColors.bgLight,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
    );
  }

  String _typeLabel(TaskType t) {
    switch (t) {
      case TaskType.homework: return '📋 Homework';
      case TaskType.revision: return '📖 Revision';
      case TaskType.project: return '🚀 Project';
      case TaskType.exam: return '📌 Exam';
      case TaskType.tp: return '🔬 TP';
      case TaskType.lab: return '🧪 Lab';
      case TaskType.reading: return '📚 Reading';
      case TaskType.other: return '📎 Other';
    }
  }
}
