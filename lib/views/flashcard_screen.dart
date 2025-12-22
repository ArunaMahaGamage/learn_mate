import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/translation_helper.dart';
import '../viewmodels/flashcard_provider.dart';
import '../components/flashcard_widget.dart';
import '../models/flashcard.dart';

class FlashcardScreen extends ConsumerWidget {
  const FlashcardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cards = ref.watch(flashcardProvider);
    final notifier = ref.read(flashcardProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(getLocalizedString(ref, 'flashcards')),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () => _showAddDialog(context, notifier, ref),
                icon: const Icon(Icons.add),
                label: Text(getLocalizedString(ref, 'add_new_card'),
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: cards.isEmpty
                ? _buildEmptyState(ref)
                : Column(
                    children: [
                      Expanded(
                        child: PageView.builder(
                          itemCount: cards.length,
                          controller: PageController(viewportFraction: 0.85),
                          itemBuilder: (context, index) {
                            final card = cards[index];
                            return Column(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                    ),
                                    child: FlashcardWidget(
                                      front: card.front,
                                      back: card.back,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                IconButton(
                                  onPressed: () =>
                                      _confirmDelete(context, notifier, card),
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.redAccent,
                                  ),
                                  tooltip: 'Delete Card',
                                ),
                                const SizedBox(height: 20),
                              ],
                            );
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 40),
                        child: Text(
                          "Swipe for more • ${cards.length} cards total",
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.style_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(getLocalizedString(ref, 'no_flashcards_found'),
            style: TextStyle(color: Colors.grey),
          ),
          Text(
            getLocalizedString(ref, 'start_adding_cards_for_your_exams'),
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    FlashcardNotifier notifier,
    Flashcard card,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Card?"),
        content: Text("Are you sure you want to delete '${card.front}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              notifier.deleteCard(card.id);
              Navigator.pop(ctx);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAddDialog(BuildContext context, FlashcardNotifier notifier, WidgetRef ref) {
    final frontController = TextEditingController();
    final backController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(getLocalizedString(ref, 'new_flashcard')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: frontController,
              decoration: InputDecoration(labelText: getLocalizedString(ref, 'front_question')),
              autofocus: true,
            ),
            TextField(
              controller: backController,
              decoration: InputDecoration(labelText: getLocalizedString(ref, 'back_answer')),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(getLocalizedString(ref, 'cancel')),
          ),
          ElevatedButton(
            onPressed: () {
              if (frontController.text.isNotEmpty &&
                  backController.text.isNotEmpty) {
                notifier.addCard(frontController.text, backController.text);
                Navigator.pop(ctx);
              }
            },
            child: Text(getLocalizedString(ref, 'save')),
          ),
        ],
      ),
    );
  }
}
