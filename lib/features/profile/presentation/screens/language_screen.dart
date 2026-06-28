import 'package:flutter/material.dart';

import '../../../home/presentation/models/shop_data.dart';

enum _Flag { uk, indonesia, china, germany }

class _Language {
  final String name;
  final _Flag flag;

  const _Language(this.name, this.flag);
}

const List<_Language> _kLanguages = [
  _Language('English', _Flag.uk),
  _Language('Bahasa Indonesia', _Flag.indonesia),
  _Language('Chinese', _Flag.china),
  _Language('Deutsch', _Flag.germany),
];

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String _selected = 'English';
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final visible = _kLanguages
        .where((l) => l.name.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 12),
            _buildSearch(),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                itemCount: visible.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (_, i) {
                  final lang = visible[i];
                  return _LanguageTile(
                    language: lang,
                    selected: _selected == lang.name,
                    onTap: () => setState(() => _selected = lang.name),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const SizedBox(
              width: 40,
              height: 40,
              child: Icon(Icons.arrow_back, size: 22, color: kDarkText),
            ),
          ),
          const Expanded(
            child: Text(
              'Language',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: kDarkText,
              ),
            ),
          ),
          const SizedBox(
            width: 40,
            height: 40,
            child: Icon(Icons.more_vert, color: kDarkText),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F7FB),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: Colors.grey.shade400, size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                onChanged: (v) => setState(() => _query = v.trim()),
                decoration: InputDecoration(
                  hintText: 'Search language',
                  hintStyle:
                      TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  border: InputBorder.none,
                  isCollapsed: true,
                ),
                style: const TextStyle(fontSize: 14, color: kDarkText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final _Language language;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.language,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? kPrimary : Colors.grey.shade200,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            _FlagCircle(flag: language.flag),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                language.name,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: kDarkText,
                ),
              ),
            ),
            if (selected)
              const Icon(Icons.check, color: kPrimary, size: 20),
          ],
        ),
      ),
    );
  }
}

/// Small stylised flag rendered as a clipped circle. Approximations are fine —
/// they read clearly at this size and avoid relying on emoji fonts.
class _FlagCircle extends StatelessWidget {
  final _Flag flag;

  const _FlagCircle({required this.flag});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: SizedBox(width: 26, height: 26, child: _build()),
    );
  }

  Widget _build() {
    switch (flag) {
      case _Flag.uk:
        return Stack(
          fit: StackFit.expand,
          children: [
            Container(color: const Color(0xFF012169)),
            Center(
              child: Container(width: double.infinity, height: 6, color: Colors.white),
            ),
            Center(
              child: Container(width: 6, height: double.infinity, color: Colors.white),
            ),
            Center(
              child: Container(width: double.infinity, height: 3, color: const Color(0xFFC8102E)),
            ),
            Center(
              child: Container(width: 3, height: double.infinity, color: const Color(0xFFC8102E)),
            ),
          ],
        );
      case _Flag.indonesia:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: const [
            Expanded(child: ColoredBox(color: Color(0xFFE70011))),
            Expanded(child: ColoredBox(color: Colors.white)),
          ],
        );
      case _Flag.china:
        return Container(
          color: const Color(0xFFDE2910),
          alignment: Alignment.center,
          child: const Icon(Icons.star, color: Color(0xFFFFDE00), size: 13),
        );
      case _Flag.germany:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: const [
            Expanded(child: ColoredBox(color: Colors.black)),
            Expanded(child: ColoredBox(color: Color(0xFFDD0000))),
            Expanded(child: ColoredBox(color: Color(0xFFFFCE00))),
          ],
        );
    }
  }
}
