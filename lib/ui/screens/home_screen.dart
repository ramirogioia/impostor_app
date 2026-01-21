import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/word_pack_repository.dart';
import '../../domain/validation/word_pack_validation.dart';
import '../widgets/category_item.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packAsync = ref.watch(currentWordPackProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Impostor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _Header(),
            const SizedBox(height: 16),
            packAsync.when(
              data: (result) => _WordPackView(result: result),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) =>
                  Text('Failed to load packs: ${error.toString()}'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Pass & play party game',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text('Choose a language and word pack to start.'),
      ],
    );
  }
}

class _WordPackView extends StatelessWidget {
  const _WordPackView({required this.result});

  final WordPackLoadResult result;

  @override
  Widget build(BuildContext context) {
    final pack = result.pack;
    final categories = pack.categories;
    if (categories.isEmpty) {
      return const Text('No categories found in pack.');
    }
    return Expanded(
      child: ListView.separated(
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final category = categories[index];
          return Card(
            child: ListTile(
              title: CategoryItem(
                displayName: category.displayName,
                categoryId: category.id,
              ),
              subtitle: Text(
                '${category.words.length} words · ${category.id}',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          );
        },
      ),
    );
  }
}

