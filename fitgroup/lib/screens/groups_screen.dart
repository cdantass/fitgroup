import 'package:flutter/material.dart';
import '../models/group.dart';
import '../state/group_state.dart';
import '../theme/app_theme.dart';
import 'create_group_screen.dart';
import 'group_chat_screen.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  bool _showMyGroups = true;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    GroupState.instance.addListener(_rebuild);
  }

  @override
  void dispose() {
    GroupState.instance.removeListener(_rebuild);
    _searchController.dispose();
    super.dispose();
  }

  void _rebuild() => setState(() {});

  List<Group> get _displayedGroups {
    final source = _showMyGroups
        ? GroupState.instance.myGroups
        : GroupState.instance.discoverGroups;
    if (_searchQuery.isEmpty) return source;
    return source
        .where((g) => g.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            _buildTabs(),
            Expanded(
              child: _displayedGroups.isEmpty ? _buildEmpty() : _buildList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreate,
        backgroundColor: AppTheme.primaryDark,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (v) => setState(() => _searchQuery = v),
          decoration: InputDecoration(
            hintText: 'Buscar grupos',
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
            prefixIcon:
                Icon(Icons.search_rounded, color: Colors.grey.shade400, size: 20),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            Expanded(
              child: _TabButton(
                label: 'Seus grupos',
                isActive: _showMyGroups,
                onTap: () => setState(() => _showMyGroups = true),
              ),
            ),
            Expanded(
              child: _TabButton(
                label: 'Descobrir',
                isActive: !_showMyGroups,
                onTap: () => setState(() => _showMyGroups = false),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
      itemCount: _displayedGroups.length,
      itemBuilder: (context, index) {
        final group = _displayedGroups[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _GroupCard(
            group: group,
            onTap: () => _handleTap(group),
            onAction: (action) => _handleAction(action, group),
          ),
        );
      },
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.group_outlined, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            _showMyGroups
                ? 'Você não está em nenhum grupo'
                : 'Nenhum grupo para descobrir',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          ),
          if (_showMyGroups) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: _openCreate,
              child: const Text('Criar um grupo'),
            ),
          ],
        ],
      ),
    );
  }

  void _handleTap(Group group) {
    if (group.isJoined) {
      Navigator.push(
          context, MaterialPageRoute(builder: (_) => GroupChatScreen(group: group)));
    } else {
      _showJoinDialog(group);
    }
  }

  void _handleAction(String action, Group group) {
    switch (action) {
      case 'chat':
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => GroupChatScreen(group: group)));
      case 'edit':
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => CreateGroupScreen(group: group)));
      case 'leave':
        _showLeaveDialog(group);
      case 'delete':
        _showDeleteDialog(group);
      case 'join':
        _showJoinDialog(group);
    }
  }

  void _showJoinDialog(Group group) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title:
            Text(group.name, style: const TextStyle(fontWeight: FontWeight.w800)),
        content: Text('Deseja entrar em "${group.name}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryDark,
                foregroundColor: Colors.white),
            onPressed: () {
              GroupState.instance.joinGroup(group.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Você entrou em ${group.name}!')));
            },
            child: const Text('Entrar'),
          ),
        ],
      ),
    );
  }

  void _showLeaveDialog(Group group) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Sair do grupo',
            style: TextStyle(fontWeight: FontWeight.w800)),
        content: Text('Deseja sair de "${group.name}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              GroupState.instance.leaveGroup(group.id);
              Navigator.pop(ctx);
            },
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(Group group) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Excluir grupo',
            style: TextStyle(fontWeight: FontWeight.w800)),
        content: Text(
            'Deseja excluir permanentemente "${group.name}"? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              GroupState.instance.deleteGroup(group.id);
              Navigator.pop(ctx);
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  void _openCreate() {
    Navigator.push(
        context, MaterialPageRoute(builder: (_) => const CreateGroupScreen()));
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TabButton(
      {required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primaryDark : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.grey.shade500,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  final Group group;
  final VoidCallback onTap;
  final void Function(String) onAction;

  const _GroupCard(
      {required this.group, required this.onTap, required this.onAction});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: group.color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: group.color.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(18, 16, 8, 18),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    group.description,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert_rounded,
                  color: Colors.white.withValues(alpha: 0.8)),
              color: Colors.white,
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onSelected: onAction,
              itemBuilder: (_) {
                if (!group.isJoined) {
                  return [
                    const PopupMenuItem(
                        value: 'join', child: Text('Entrar no grupo'))
                  ];
                }
                return [
                  const PopupMenuItem(value: 'chat', child: Text('Abrir chat')),
                  if (group.isOwner)
                    const PopupMenuItem(
                        value: 'edit', child: Text('Editar grupo')),
                  if (!group.isOwner)
                    const PopupMenuItem(
                        value: 'leave', child: Text('Sair do grupo')),
                  if (group.isOwner)
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Excluir grupo',
                          style: TextStyle(color: Colors.red)),
                    ),
                ];
              },
            ),
          ],
        ),
      ),
    );
  }
}
