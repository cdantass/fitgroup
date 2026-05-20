import 'package:flutter/material.dart';
import '../models/group.dart';
import '../models/chat_message.dart';
import '../theme/app_theme.dart';

class GroupState extends ChangeNotifier {
  static final GroupState instance = GroupState._();
  GroupState._();

  final Map<String, List<ChatMessage>> _chats = {
    '1': [
      ChatMessage(author: 'Cauã', text: 'Bom dia galera!', isMe: false, time: DateTime(2026, 5, 14, 9, 10)),
      ChatMessage(author: 'Thiago', text: 'Bom dia! Treino hoje às 18h?', isMe: false, time: DateTime(2026, 5, 14, 9, 12)),
    ],
    '2': [
      ChatMessage(author: 'Ana', text: 'Alguém tem receita fit para lanche?', isMe: false, time: DateTime(2026, 5, 15, 11, 0)),
      ChatMessage(author: 'Você', text: 'Omelete com aveia é ótimo!', isMe: true, time: DateTime(2026, 5, 15, 11, 5)),
    ],
    '3': [
      ChatMessage(author: 'Pedro', text: 'Praça confirmada pra amanhã', isMe: false, time: DateTime(2026, 5, 16, 8, 0)),
    ],
  };

  List<ChatMessage> getMessages(String groupId) => _chats[groupId] ?? [];

  void addMessage(String groupId, ChatMessage message) {
    _chats.putIfAbsent(groupId, () => []);
    _chats[groupId]!.add(message);
    notifyListeners();
  }

  final List<Group> _groups = [
    Group(
      id: '1',
      name: 'Grupo fitness',
      description: 'grupo de treino da academia bemestar',
      color: AppTheme.purple,
      members: 12,
      isJoined: true,
      isOwner: false,
    ),
    Group(
      id: '2',
      name: 'Grupo de nutrição',
      description: 'grupo focado em alimentação e nutrição',
      color: AppTheme.amber,
      members: 8,
      isJoined: true,
      isOwner: true,
    ),
    Group(
      id: '3',
      name: 'Grupo de Calistenia',
      description: 'Todo dia de segunda a sexta, praça 123',
      color: AppTheme.coral,
      members: 15,
      isJoined: true,
      isOwner: false,
    ),
    Group(
      id: '4',
      name: 'Amigos de Cardio',
      description: 'Todo dia de segunda a sexta, praça 123',
      color: const Color(0xFF3B82F6),
      members: 20,
      isJoined: false,
      isOwner: false,
    ),
    Group(
      id: '5',
      name: 'Yoga & Zen',
      description: 'Meditação e yoga toda manhã',
      color: AppTheme.teal,
      members: 6,
      isJoined: false,
      isOwner: false,
    ),
  ];

  List<Group> get myGroups => _groups.where((g) => g.isJoined).toList();
  List<Group> get discoverGroups => _groups.where((g) => !g.isJoined).toList();

  void joinGroup(String id) {
    final g = _groups.firstWhere((g) => g.id == id);
    g.isJoined = true;
    g.members++;
    notifyListeners();
  }

  void leaveGroup(String id) {
    final g = _groups.firstWhere((g) => g.id == id);
    g.isJoined = false;
    if (g.members > 0) g.members--;
    notifyListeners();
  }

  void createGroup({
    required String name,
    required String description,
    required Color color,
  }) {
    _groups.add(Group(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      description: description,
      color: color,
      members: 1,
      isJoined: true,
      isOwner: true,
    ));
    notifyListeners();
  }

  void updateGroup(String id, {String? name, String? description, Color? color}) {
    final g = _groups.firstWhere((g) => g.id == id);
    if (name != null) g.name = name;
    if (description != null) g.description = description;
    if (color != null) g.color = color;
    notifyListeners();
  }

  void deleteGroup(String id) {
    _groups.removeWhere((g) => g.id == id);
    notifyListeners();
  }
}
