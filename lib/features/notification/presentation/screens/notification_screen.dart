import 'package:flutter/material.dart';

import '../../../home/presentation/models/shop_data.dart';

class _Notice {
  final String title;
  final String body;
  final String time;
  final IconData? icon;
  final Color color;
  final bool isMessage;
  final String? action;

  const _Notice({
    required this.title,
    required this.body,
    required this.time,
    this.icon,
    this.color = kPrimary,
    this.isMessage = false,
    this.action,
  });
}

const List<_Notice> _kNotices = [
  _Notice(
    title: 'Purchase Completed!',
    body: 'You have successfully purchased 334 headphones, thank you and wait '
        'for your package to arrive ✨',
    time: '2 m ago',
    icon: Icons.shopping_cart_outlined,
  ),
  _Notice(
    title: 'Jeremmy Send You a Message',
    body: 'hello your package has almost arrived, are you at home now?',
    time: '2 m ago',
    isMessage: true,
    color: Color(0xFFE8C9A0),
    action: 'Reply the message',
  ),
  _Notice(
    title: 'Flash Sale!',
    body: 'Get 20% discount for first transaction in this month! 😍',
    time: '2 m ago',
    icon: Icons.flash_on_outlined,
  ),
  _Notice(
    title: 'Package Sent',
    body: 'Hi your package has been sent from new york',
    time: '10 m ago',
    icon: Icons.local_shipping_outlined,
  ),
];

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Text(
                'Recent',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: kDarkText,
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                itemCount: _kNotices.length,
                separatorBuilder: (_, _) => const SizedBox(height: 22),
                itemBuilder: (_, i) => _NoticeTile(notice: _kNotices[i]),
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
              child: Icon(Icons.arrow_back_ios_new, size: 18, color: kDarkText),
            ),
          ),
          const Expanded(
            child: Text(
              'Notification',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: kDarkText,
              ),
            ),
          ),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.settings_outlined,
                size: 20, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

class _NoticeTile extends StatelessWidget {
  final _Notice notice;

  const _NoticeTile({required this.notice});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _leading(),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      notice.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: kDarkText,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    notice.time,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                notice.body,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: Colors.grey.shade500,
                ),
              ),
              if (notice.action != null) ...[
                const SizedBox(height: 6),
                Text(
                  notice.action!,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: kPrimary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _leading() {
    if (notice.isMessage) {
      return CircleAvatar(
        radius: 18,
        backgroundColor: notice.color,
        child: const Icon(Icons.person, color: Colors.white, size: 20),
      );
    }
    return Container(
      width: 36,
      height: 36,
      decoration: const BoxDecoration(
        color: Color(0xFFF2F2F5),
        shape: BoxShape.circle,
      ),
      child: Icon(notice.icon, size: 18, color: Colors.grey.shade600),
    );
  }
}
