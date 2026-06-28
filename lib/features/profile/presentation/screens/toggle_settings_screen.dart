import 'package:flutter/material.dart';

import '../../../home/presentation/models/shop_data.dart';

class ToggleSettingsScreen extends StatefulWidget {
  final String title;
  final Map<String, bool> options;

  const ToggleSettingsScreen({
    super.key,
    required this.title,
    required this.options,
  });

  @override
  State<ToggleSettingsScreen> createState() => _ToggleSettingsScreenState();
}

class _ToggleSettingsScreenState extends State<ToggleSettingsScreen> {
  late final Map<String, bool> _values = Map.of(widget.options);

  @override
  Widget build(BuildContext context) {
    final labels = _values.keys.toList();
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _SettingsHeader(title: widget.title),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                itemCount: labels.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final label = labels[i];
                  return Row(
                    children: [
                      Expanded(
                        child: Text(
                          label,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: kDarkText,
                          ),
                        ),
                      ),
                      Switch.adaptive(
                        value: _values[label]!,
                        activeThumbColor: Colors.white,
                        activeTrackColor: kPrimary,
                        onChanged: (v) => setState(() => _values[label] = v),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsHeader extends StatelessWidget {
  final String title;

  const _SettingsHeader({required this.title});

  @override
  Widget build(BuildContext context) {
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
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
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
}
