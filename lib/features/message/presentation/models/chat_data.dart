import 'package:flutter/material.dart';

import '../../../home/presentation/models/shop_data.dart';

class Activity {
  final String name;
  final Color color;

  const Activity({required this.name, required this.color});
}

class Conversation {
  final String name;
  final String preview;
  final String time;
  final int unread;
  final Color color;

  const Conversation({
    required this.name,
    required this.preview,
    required this.time,
    this.unread = 0,
    required this.color,
  });
}

enum ChatSender { me, other }

enum ChatKind { text, product }

class ChatMessage {
  final ChatSender sender;
  final ChatKind kind;
  final String text;
  final String time;
  final Product? product;
  final String? productColorName;
  final String? linkLine;

  const ChatMessage({
    required this.sender,
    this.kind = ChatKind.text,
    this.text = '',
    this.time = '',
    this.product,
    this.productColorName,
    this.linkLine,
  });
}

const List<Activity> kActivities = [
  Activity(name: 'Kristine', color: Color(0xFFE8C9A0)),
  Activity(name: 'Kay', color: Color(0xFFC9D6E8)),
  Activity(name: 'Cheryl', color: Color(0xFFE8B5B5)),
  Activity(name: 'Jeen', color: Color(0xFF3A3A3A)),
];

const List<Conversation> kConversations = [
  Conversation(
    name: 'Jhone Endrue',
    preview: 'Hello hw are you? I am going to market. Do you want anything?',
    time: '23 min',
    unread: 2,
    color: Color(0xFFC9D6E8),
  ),
  Conversation(
    name: 'Jihane Luande',
    preview:
        'We are on the runways at the military hangar, there is a plane in it.',
    time: '40 min',
    unread: 1,
    color: Color(0xFFE8B5B5),
  ),
  Conversation(
    name: 'Broman Alexander',
    preview: 'I receved my new watch that I ordered from Amazon.',
    time: '1 hr',
    color: Color(0xFFE8C9A0),
  ),
  Conversation(
    name: 'Zack Jr',
    preview: "I just arrived in front of the school. I'm wating for you hurry up!",
    time: '1 hr',
    color: Color(0xFF3A3A3A),
  ),
];
