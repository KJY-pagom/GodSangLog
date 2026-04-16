import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/food_provider.dart';

class FoodSearchScreen extends ConsumerStatefulWidget {
  const FoodSearchScreen({super.key});

  @override
  ConsumerState<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends ConsumerState<FoodSearchScreen> {
  final _controller = TextEditingController();
  late final ProviderSubscription<Object?> _sub;

  @override
  void initState() {
    super.initState();
    _sub = ref.listenManual(foodSearchProvider, (_, next) {
      if (next is AsyncError) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('검색 결과를 불러오지 못했습니다')));
        });
      }
    });
  }

  @override
  void dispose() {
    _sub.close();
    _controller.dispose();
    super.dispose();
  }

  void _search() =>
      ref.read(foodSearchProvider.notifier).search(_controller.text);

  @override
  Widget build(BuildContext context) {
    final resultsAsync = ref.watch(foodSearchProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('음식 검색'),
        actions: [
          TextButton.icon(
            onPressed: () => context.push('/record/recipe'),
            icon: const Icon(Icons.menu_book_outlined),
            label: const Text('레시피'),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: '식품명을 입력하세요',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _search,
                ),
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (_) => _search(),
            ),
          ),
          Expanded(
            child: resultsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const SizedBox.shrink(),
              data: (result) {
                if (result.items.isEmpty) {
                  return Center(
                    child: Text(
                      _controller.text.trim().isEmpty
                          ? '식품명을 검색하세요'
                          : '검색 결과가 없습니다',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                    ),
                  );
                }

                return ListView.separated(
                  // 더보기 버튼을 위해 +1
                  itemCount: result.items.length + 1,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    // 마지막 아이템 → 더보기 버튼
                    if (i == result.items.length) {
                      if (!result.hasMore) return const SizedBox.shrink();
                      return _LoadMoreButton(
                        isLoading: result.isLoadingMore,
                        onTap: () =>
                            ref.read(foodSearchProvider.notifier).loadMore(),
                      );
                    }

                    final item = result.items[i];
                    return ListTile(
                      title: Text(item.name),
                      subtitle: Text(
                        '${item.calories.toInt()} kcal · 기준량 ${item.servingSize.toInt()}g',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () =>
                          context.push('/record/food/add', extra: item),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadMoreButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;

  const _LoadMoreButton({required this.isLoading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: isLoading
          ? const Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          : OutlinedButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.expand_more),
              label: const Text('더보기 (10건)'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(44),
              ),
            ),
    );
  }
}
