import 'package:flutter/material.dart';

import '../models/app_data.dart';
import '../theme/app_theme.dart';

class GroupEditorScreen extends StatefulWidget {
  final FitGroup group;

  const GroupEditorScreen({super.key, required this.group});

  @override
  State<GroupEditorScreen> createState() => _GroupEditorScreenState();
}

class _GroupEditorScreenState extends State<GroupEditorScreen> {
  late final TextEditingController _groupNameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _memberSearchController;

  late final List<_GroupMember> _members = [
    const _GroupMember(name: 'Cauã', isAdmin: true),
    const _GroupMember(name: 'Marcel', isAdmin: false),
    const _GroupMember(name: 'Thiago', isAdmin: false),
  ];

  @override
  void initState() {
    super.initState();
    _groupNameController = TextEditingController(text: widget.group.name);
    _descriptionController = TextEditingController(
      text: 'Grupo para combinar treinos, organizar membros e acompanhar a evolução.',
    );
    _memberSearchController = TextEditingController();
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    _descriptionController.dispose();
    _memberSearchController.dispose();
    super.dispose();
  }

  void _addMember() {
    final name = _memberSearchController.text.trim();
    if (name.isEmpty) {
      return;
    }

    final exists = _members.any((member) => member.name.toLowerCase() == name.toLowerCase());
    if (exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Esse membro já está adicionado.')),
      );
      return;
    }

    setState(() {
      _members.add(_GroupMember(name: name));
      _memberSearchController.clear();
    });
  }

  void _toggleAdmin(int index) {
    setState(() {
      _members[index] = _members[index].copyWith(isAdmin: !_members[index].isAdmin);
    });
  }

  void _removeMember(int index) {
    if (_members[index].isAdmin && _members.where((member) => member.isAdmin).length == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('O grupo precisa manter pelo menos um admin.')),
      );
      return;
    }

    setState(() {
      _members.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionCard(
                      title: 'Informações do grupo',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel('Nome do grupo'),
                          TextField(
                            controller: _groupNameController,
                            decoration: _inputDecoration('Digite o nome do grupo'),
                          ),
                          const SizedBox(height: 14),
                          _buildFieldLabel('Descrição do grupo'),
                          TextField(
                            controller: _descriptionController,
                            maxLines: 3,
                            decoration: _inputDecoration('Digite a descrição do grupo'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSectionCard(
                      title: 'Adicionar membros',
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _memberSearchController,
                              decoration: _inputDecoration('Pesquisar contato'),
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => _addMember(),
                            ),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: _addMember,
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryDark,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.add_rounded, color: Colors.white, size: 26),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSectionCard(
                      title: 'Permissões e membros',
                      child: Column(
                        children: [
                          Row(
                            children: [
                              _LegendPill(
                                icon: Icons.star_rounded,
                                label: 'Admin',
                                color: AppTheme.primaryDark,
                              ),
                              const SizedBox(width: 10),
                              _LegendPill(
                                icon: Icons.person_outline_rounded,
                                label: 'Membro',
                                color: const Color(0xFF94A3B8),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          ...List.generate(_members.length, (index) {
                            final member = _members[index];
                            return Padding(
                              padding: EdgeInsets.only(bottom: index == _members.length - 1 ? 0 : 12),
                              child: _MemberTile(
                                member: member,
                                onTap: () => _showMemberActions(index),
                                onToggleAdmin: () => _toggleAdmin(index),
                                onRemove: () => _removeMember(index),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF94A3B8),
                              side: const BorderSide(color: Color(0xFFE2E8F0)),
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancelar'),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryDark,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Grupo salvo em modo mock.')),
                              );
                              Navigator.pop(context);
                            },
                            child: const Text('Salvar grupo'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            color: const Color(0xFF0F172A),
          ),
          const SizedBox(width: 4),
          const Text(
            'Criar grupo',
            style: TextStyle(
              color: AppTheme.primaryDark,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: () {},
            child: const Text('Ajuda'),
          ),
        ],
      ),
    );
  }

  void _showMemberActions(int index) {
    final member = _members[index];

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: member.isAdmin ? const Color(0xFFDBEAFE) : const Color(0xFFE2E8F0),
                      child: Icon(
                        member.isAdmin ? Icons.star_rounded : Icons.person_rounded,
                        color: member.isAdmin ? const Color(0xFF1D4ED8) : const Color(0xFF475569),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        member.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    Text(
                      member.isAdmin ? 'Admin' : 'Membro',
                      style: TextStyle(
                        color: member.isAdmin ? const Color(0xFF1D4ED8) : const Color(0xFF64748B),
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _BottomSheetAction(
                  icon: member.isAdmin ? Icons.remove_moderator_rounded : Icons.verified_rounded,
                  label: member.isAdmin ? 'Remover admin' : 'Promover a admin',
                  isDestructive: false,
                  onTap: () {
                    Navigator.pop(context);
                    _toggleAdmin(index);
                  },
                ),
                const SizedBox(height: 10),
                _BottomSheetAction(
                  icon: Icons.person_remove_alt_1_rounded,
                  label: 'Remover do grupo',
                  isDestructive: true,
                  onTap: () {
                    Navigator.pop(context);
                    _removeMember(index);
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionCard({
    required String title,
    String subtitle = '',
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 13,
                height: 1.4,
                color: const Color(0xFF475569).withOpacity(0.92),
              ),
            ),
            const SizedBox(height: 16),
          ] else
            const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppTheme.primaryDark, width: 1.4),
      ),
    );
  }

  Widget _buildFieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: Color(0xFF334155),
        ),
      ),
    );
  }
}

class _GroupMember {
  final String name;
  final bool isAdmin;

  const _GroupMember({required this.name, this.isAdmin = false});

  _GroupMember copyWith({String? name, bool? isAdmin}) {
    return _GroupMember(
      name: name ?? this.name,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }
}

class _MemberTile extends StatelessWidget {
  final _GroupMember member;
  final VoidCallback onTap;
  final VoidCallback onToggleAdmin;
  final VoidCallback onRemove;

  const _MemberTile({
    required this.member,
    required this.onTap,
    required this.onToggleAdmin,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: member.isAdmin ? const Color(0xFFDBEAFE) : const Color(0xFFE2E8F0),
              child: Icon(
                member.isAdmin ? Icons.star_rounded : Icons.person_rounded,
                color: member.isAdmin ? const Color(0xFF1D4ED8) : const Color(0xFF475569),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          member.name,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      _RolePill(isAdmin: member.isAdmin),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    member.isAdmin ? 'Admin do grupo' : 'Membro do grupo',
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.35,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.more_horiz_rounded,
              color: const Color(0xFF94A3B8).withOpacity(0.95),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

class _RolePill extends StatelessWidget {
  final bool isAdmin;

  const _RolePill({required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    final background = isAdmin ? const Color(0xFFDBEAFE) : const Color(0xFFF1F5F9);
    final color = isAdmin ? const Color(0xFF1D4ED8) : const Color(0xFF64748B);
    final label = isAdmin ? 'Admin' : 'Membro';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _LegendPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _LegendPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomSheetAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isDestructive;
  final VoidCallback onTap;

  const _BottomSheetAction({
    required this.label,
    required this.icon,
    required this.isDestructive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final background = isDestructive ? const Color(0xFFFEE2E2) : const Color(0xFFF8FAFC);
    final foreground = isDestructive ? const Color(0xFFB91C1C) : const Color(0xFF334155);

    return SizedBox(
      width: double.infinity,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: foreground),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  color: foreground,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}