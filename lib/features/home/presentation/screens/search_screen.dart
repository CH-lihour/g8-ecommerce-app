import 'package:flutter/material.dart';
import '../models/shop_data.dart';
import 'search_results_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  List<String> _lastSearch = List.of(kLastSearch);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Records [term] as a recent search (most recent first, no duplicates) and
  /// opens the results screen for it.
  void _search(String term) {
    final query = term.trim();
    if (query.isEmpty) return;
    setState(() {
      _lastSearch.remove(query);
      _lastSearch.insert(0, query);
    });
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => SearchResultsScreen(query: query)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.arrow_back_ios, size: 18),
                    color: kDarkText,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: TextField(
                        autofocus: true,
                        controller: _controller,
                        textInputAction: TextInputAction.search,
                        onSubmitted: _search,
                        decoration: InputDecoration(
                          hintText: 'Search',
                          prefixIcon: Icon(
                            Icons.search,
                            color: Colors.grey.shade400,
                          ),
                          contentPadding: EdgeInsets.zero,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: kPrimary),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: kPrimary,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Last Search',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: kDarkText,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() => _lastSearch = []),
                    child: const Text(
                      'Clear All',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: kPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _lastSearch
                    .map(
                      (term) => _SearchChip(
                        label: term,
                        onTap: () => _search(term),
                        onRemove: () =>
                            setState(() => _lastSearch.remove(term)),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 28),
              const Text(
                'Popular Search',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: kDarkText,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.only(top: 8),
                  itemCount: kPopularSearch.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 18),
                  itemBuilder: (_, i) => _PopularRow(
                    item: kPopularSearch[i],
                    onTap: () => _search(kPopularSearch[i].name),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _SearchChip({
    required this.label,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: const TextStyle(fontSize: 13, color: kDarkText)),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onRemove,
              child: Icon(Icons.close, size: 15, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}

class _PopularRow extends StatelessWidget {
  final PopularSearch item;
  final VoidCallback onTap;

  const _PopularRow({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: item.swatch,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.image_outlined, color: Colors.white54),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: kDarkText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.searches,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: item.tagColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              item.tag,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: item.tagColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
