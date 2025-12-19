import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/quiz.dart';
import '../viewmodels/quiz_provider.dart';

Quiz _createEmptyQuiz() => Quiz(
  id: FirebaseFirestore.instance.collection('quizzes').doc().id,
  title: '',
  description: '',
  createdBy: 'user',
  questions: [],
);

final quizFormNotifierProvider =
    StateNotifierProvider.autoDispose<QuizFormNotifier, Quiz>((ref) {
      return QuizFormNotifier(initialQuiz: _createEmptyQuiz());
    });

class QuizFormNotifier extends StateNotifier<Quiz> {
  QuizFormNotifier({required Quiz initialQuiz}) : super(initialQuiz);

  void updateMetadata({String? title, String? description}) {
    state = state.copyWith(
      title: title ?? state.title,
      description: description ?? state.description,
    );
  }

  void addQuestion() {
    final newQuestion = QuizQuestion(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      question: '',
      options: ['', '', '', ''],
      correctAnswerIndex: 0,
    );
    state = state.copyWith(questions: [...state.questions, newQuestion]);
  }

  void updateQuestion(
    String qId, {
    String? question,
    List<String>? options,
    int? index,
  }) {
    final updatedQuestions = state.questions.map((q) {
      if (q.id == qId) {
        return QuizQuestion(
          id: q.id,
          question: question ?? q.question,
          options: options ?? q.options,
          correctAnswerIndex: index ?? q.correctAnswerIndex,
        );
      }
      return q;
    }).toList();
    state = state.copyWith(questions: updatedQuestions);
  }

  void deleteQuestion(String qId) {
    state = state.copyWith(
      questions: state.questions.where((q) => q.id != qId).toList(),
    );
  }
}

class QuizCreationScreen extends ConsumerStatefulWidget {
  const QuizCreationScreen({super.key});

  @override
  ConsumerState<QuizCreationScreen> createState() => _QuizCreationScreenState();
}

class _QuizCreationScreenState extends ConsumerState<QuizCreationScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  Quiz? _initialQuiz;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Quiz) {
        _initialQuiz = args;
        _titleController.text = args.title;
        _descriptionController.text = args.description;

        ref.read(quizFormNotifierProvider.notifier).state = args;
      }
      _titleController.addListener(_updateMetadata);
      _descriptionController.addListener(_updateMetadata);
    });
  }

  void _updateMetadata() {
    if (!mounted) return;
    ref
        .read(quizFormNotifierProvider.notifier)
        .updateMetadata(
          title: _titleController.text,
          description: _descriptionController.text,
        );
  }

  @override
  void dispose() {
    _titleController.removeListener(_updateMetadata);
    _descriptionController.removeListener(_updateMetadata);
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveQuiz() async {
    final quizToSave = ref.read(quizFormNotifierProvider);
    final quizListNotifier = ref.read(quizListProvider.notifier);

    if (quizToSave.title.isEmpty || quizToSave.questions.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Title and at least one question are required.'),
          ),
        );
      }
      return;
    }

    final allValid = quizToSave.questions.every(
      (q) => q.question.isNotEmpty && q.options.every((o) => o.isNotEmpty),
    );

    if (!allValid) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please fill all questions and options completely.'),
          ),
        );
      }
      return;
    }

    // Save Logic (Create or Update)
    if (_initialQuiz != null) {
      await quizListNotifier.updateQuiz(quizToSave);
    } else {
      await quizListNotifier.addQuiz(quizToSave);
    }

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${_initialQuiz != null ? 'Updated' : 'Created'} Quiz: ${quizToSave.title}',
        ),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final quiz = ref.watch(quizFormNotifierProvider);
    final notifier = ref.read(quizFormNotifierProvider.notifier);
    final isEditing = _initialQuiz != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Quiz' : 'Create New Quiz'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveQuiz,
            tooltip: 'Save Quiz',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Quiz Title'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 2,
            ),
            const Divider(height: 40),

            Text(
              'Questions (${quiz.questions.length})',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),

            ...quiz.questions.asMap().entries.map((entry) {
              final index = entry.key;
              final q = entry.value;
              return _QuestionFormCard(
                key: ValueKey(q.id),
                index: index,
                question: q,
                onUpdate: notifier.updateQuestion,
                onDelete: notifier.deleteQuestion,
              );
            }),

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Question'),
                onPressed: notifier.addQuestion,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuestionFormCard extends ConsumerStatefulWidget {
  final int index;
  final QuizQuestion question;
  final Function(
    String qId, {
    String? question,
    List<String>? options,
    int? index,
  })
  onUpdate;
  final Function(String qId) onDelete;

  const _QuestionFormCard({
    super.key,
    required this.index,
    required this.question,
    required this.onUpdate,
    required this.onDelete,
  });

  @override
  ConsumerState<_QuestionFormCard> createState() => _QuestionFormCardState();
}

class _QuestionFormCardState extends ConsumerState<_QuestionFormCard> {
  late TextEditingController _questionController;
  late List<TextEditingController> _optionControllers;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _questionController = TextEditingController(text: widget.question.question);

    _optionControllers = List.generate(
      widget.question.options.length,
      (i) => TextEditingController(text: widget.question.options[i]),
    );
  }

  @override
  void didUpdateWidget(covariant _QuestionFormCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.question.question != widget.question.question &&
        _questionController.text != widget.question.question) {
      _questionController.text = widget.question.question;
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    for (var c in _optionControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.question;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Question ${widget.index + 1}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => widget.onDelete(question.id),
                ),
              ],
            ),

            // Question Input
            TextField(
              decoration: const InputDecoration(
                labelText: 'Question Text',
                isDense: true,
              ),
              controller: _questionController,
              textDirection: TextDirection.ltr,
              onChanged: (text) => widget.onUpdate(question.id, question: text),
            ),
            const SizedBox(height: 16),

            // Options Input
            Text(
              'Options (Select correct answer below):',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            ...question.options.asMap().entries.map((entry) {
              final optIndex = entry.key;

              return Row(
                key: ValueKey('${question.id}_option_$optIndex'),
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Option ${optIndex + 1}',
                        isDense: true,
                      ),
                      // Use the managed controller
                      controller: _optionControllers[optIndex],
                      textDirection: TextDirection.ltr,
                      onChanged: (text) {
                        final newOptions = List<String>.from(question.options);
                        newOptions[optIndex] = text;
                        widget.onUpdate(question.id, options: newOptions);
                      },
                    ),
                  ),
                  Checkbox(
                    value: question.correctAnswerIndex == optIndex,
                    onChanged: (checked) {
                      if (checked == true) {
                        widget.onUpdate(question.id, index: optIndex);
                      }
                    },
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
