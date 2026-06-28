import 'package:flutter/material.dart';

import '../../../home/presentation/models/shop_data.dart';
import '../models/chat_data.dart';

class ChatScreen extends StatelessWidget {
  final Conversation conversation;

  const ChatScreen({super.key, required this.conversation});

  List<ChatMessage> get _messages {
    final bag = Product(
      name: 'Bix Bag Limited Edition 229',
      seller: 'Upbox Bag',
      price: 1100,
    );
    return [
      const ChatMessage(
        sender: ChatSender.me,
        text: 'Hi, I have purchased this product',
      ),
      ChatMessage(
        sender: ChatSender.me,
        kind: ChatKind.product,
        product: bag,
        productColorName: 'Brown',
        linkLine:
            'Ahmir has paid \$1,100. Click this link\nKutuku.com/payment/success/...',
      ),
      const ChatMessage(
        sender: ChatSender.me,
        text: 'Send it soon ok!',
        time: '10.15 AM',
      ),
      const ChatMessage(
        sender: ChatSender.other,
        text: 'Hi Ahmir, Thanks for buying our product',
        time: '10.30 AM',
      ),
      const ChatMessage(
        sender: ChatSender.other,
        text: 'Your package will be packed soon',
        time: '10.31 AM',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                children: [
                  for (final m in _messages) _MessageBubble(message: m),
                ],
              ),
            ),
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 16, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const SizedBox(
              width: 36,
              height: 40,
              child: Icon(Icons.arrow_back_ios_new, size: 18, color: kDarkText),
            ),
          ),
          CircleAvatar(
            radius: 22,
            backgroundColor: conversation.color,
            child: const Icon(Icons.person, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                conversation.name,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: kDarkText,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: const [
                  _OnlineDot(),
                  SizedBox(width: 5),
                  Text(
                    'Online',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF22C55E),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          Icon(Icons.videocam_outlined, color: Colors.grey.shade600, size: 24),
          const SizedBox(width: 18),
          Icon(Icons.call_outlined, color: Colors.grey.shade600, size: 22),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Icon(Icons.photo_camera_outlined,
                  color: Colors.grey.shade500, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Type message...',
                        style: TextStyle(
                            fontSize: 14, color: Colors.grey.shade400),
                      ),
                    ),
                    Icon(Icons.mic_none, color: Colors.grey.shade500, size: 22),
                    const SizedBox(width: 12),
                    Icon(Icons.link, color: Colors.grey.shade500, size: 22),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: kPrimary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send, color: Colors.white, size: 22),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnlineDot extends StatelessWidget {
  const _OnlineDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      height: 7,
      decoration: const BoxDecoration(
        color: Color(0xFF22C55E),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isMe = message.sender == ChatSender.me;
    final align = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: align,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.72,
            ),
            child: message.kind == ChatKind.product
                ? _ProductBubble(message: message)
                : _TextBubble(message: message, isMe: isMe),
          ),
          if (message.time.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              message.time,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
            ),
          ],
        ],
      ),
    );
  }
}

class _TextBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;

  const _TextBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
      bottomLeft: Radius.circular(isMe ? 16 : 4),
      bottomRight: Radius.circular(isMe ? 4 : 16),
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isMe ? kPrimary : const Color(0xFFF2F2F5),
        borderRadius: radius,
      ),
      child: Text(
        message.text,
        style: TextStyle(
          fontSize: 14,
          height: 1.3,
          color: isMe ? Colors.white : kDarkText,
        ),
      ),
    );
  }
}

/// The purple "I purchased this" bubble that embeds a product card and a
/// payment-link line.
class _ProductBubble extends StatelessWidget {
  final ChatMessage message;

  const _ProductBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final product = message.product!;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: kPrimary,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDEDED),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.shopping_bag_outlined,
                      color: Colors.grey.shade500, size: 22),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: kDarkText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Color : ${message.productColorName ?? '-'}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (message.linkLine != null) ...[
            const SizedBox(height: 10),
            Text(
              message.linkLine!,
              style: const TextStyle(
                fontSize: 13,
                height: 1.35,
                color: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
