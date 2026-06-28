import 'package:flutter/material.dart';

import '../../../home/presentation/models/shop_data.dart';

const String _kParagraph =
    'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Eget ornare quam '
    'vel facilisis feugiat amet sagittis arcu, tortor. Sapien, consequat '
    'ultrices morbi orci semper sit nulla. Leo auctor ut etiam est, amet '
    'aliquet ut vivamus. Odio vulputate est id tincidunt fames.';

class LegalPoliciesScreen extends StatelessWidget {
  const LegalPoliciesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                children: const [
                  _Heading('Terms'),
                  SizedBox(height: 12),
                  _Body(),
                  SizedBox(height: 12),
                  _Body(),
                  SizedBox(height: 24),
                  _Heading('Changes to the Service and/or Terms:'),
                  SizedBox(height: 12),
                  _Body(),
                  SizedBox(height: 12),
                  _Body(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
              'Legal and Policies',
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
}

class _Heading extends StatelessWidget {
  final String text;

  const _Heading(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: kDarkText,
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return Text(
      _kParagraph,
      style: TextStyle(fontSize: 13, height: 1.6, color: Colors.grey.shade500),
    );
  }
}
