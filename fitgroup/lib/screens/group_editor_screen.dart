import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/group.dart';
import '../state/group_state.dart';
import '../theme/app_theme.dart';

class GroupEditorScreen extends StatefulWidget {
  final Group? group;

  const GroupEditorScreen({super.key, this.group});

  @override
  State<GroupEditorScreen> createState() => _GroupEditorScreenState();
}

class _GroupEditorScreenState extends State<GroupEditorScreen> {
  late final TextEditingController _groupNameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _memberSearchController;
  late final bool _isEditing;
  bool _isSaving = false;
  bool _isLoadingMembers = true;
  bool _isSearching = false;
  bool _searchedOnce = false;
  late Color _selectedColor;

  final List<_GroupMember> _members = [];
  List<_GroupMember> _searchResults = [];
  List<Map<String, dynamic>>? _allUsersCache;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.group != null;
    _selectedColor = widget.group?.color ?? kGroupColors.first;
    _groupNameController = TextEditingController(text: widget.group?.name ?? '');
    _descriptionController = TextEditingController(text: widget.group?.description ?? '');
    _memberSearchController = TextEditingController();
    _loadMembers();
  }

  @override
  void dispose() {
    _groupNameController.dispose();
    _descriptionController.dispose();
    _memberSearchController.dispose();
    super.dispose();
  }

  // Extrai UID de um item que pode ser DocumentReference ou String
  String? _extractUid(dynamic item) {
    if (item is DocumentReference) return item.id;
    if (item is String) return item;
    return null;
  }

  Future<void> _loadMembers() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      if (mounted) setState(() => _isLoadingMembers = false);
      return;
    }

    if (!_isEditing || widget.group == null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(currentUser.uid)
          .get();
      final userData = userDoc.data() ?? {};
      if (mounted) {
        setState(() {
          _members.add(_GroupMember(
            uid: currentUser.uid,
            email: userData['email'] as String? ?? currentUser.email ?? '',
            nome: userData['nome'] as String? ?? '',
            isAdmin: true,
          ));
          _isLoadingMembers = false;
        });
      }
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('grupos')
          .doc(widget.group!.id)
          .get();

      if (!mounted) return;

      final data = doc.data() ?? {};
      final usuariosRaw = (data['usuarios'] as List?) ?? [];
      final adminRaw = [
        ...((data['admin'] as List?) ?? []),
        ...((data['admins'] as List?) ?? []),
      ];

      final uids = usuariosRaw
          .map(_extractUid)
          .whereType<String>()
          .toList();
      final adminUids = adminRaw
          .map(_extractUid)
          .whereType<String>()
          .toSet();

      final List<_GroupMember> loaded = [];
      for (final uid in uids) {
        final userDoc = await FirebaseFirestore.instance
            .collection('usuarios')
            .doc(uid)
            .get();
        final userData = userDoc.data() ?? {};
        final fallbackEmail =
            uid == currentUser.uid ? (currentUser.email ?? uid) : uid;
        loaded.add(_GroupMember(
          uid: uid,
          email: (userData['email'] as String?) ?? fallbackEmail,
          nome: (userData['nome'] as String?) ?? '',
          isAdmin: adminUids.contains(uid),
        ));
      }

      if (mounted) {
        setState(() {
          _members
            ..clear()
            ..addAll(loaded);
          _isLoadingMembers = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingMembers = false);
    }
  }

  Future<void> _saveGroup() async {
    final name = _groupNameController.text.trim();
    final description = _descriptionController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe o nome do grupo.')),
      );
      return;
    }

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Faca login para salvar o grupo.')),
      );
      return;
    }

    final uids = _members.map((m) => m.uid).toList();
    final adminUids = _members.where((m) => m.isAdmin).map((m) => m.uid).toList();

    setState(() => _isSaving = true);
    try {
      if (_isEditing && widget.group != null) {
        await GroupState.instance.updateGroup(
          widget.group!.id,
          name: name,
          description: description,
          color: _selectedColor,
          usuarios: uids,
          admins: adminUids,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Grupo atualizado com sucesso.')),
        );
      } else {
        await GroupState.instance.createGroup(
          name: name,
          description: description,
          color: _selectedColor,
          userUid: currentUser.uid,
          memberUids: uids,
          adminUids: adminUids,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Grupo criado com sucesso.')),
        );
      }

      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _searchUsers(String query) async {
    if (query.length < 2) {
      setState(() {
        _searchResults = [];
        _searchedOnce = false;
      });
      return;
    }

    setState(() => _isSearching = true);

    try {
      _allUsersCache ??= await FirebaseFirestore.instance
          .collection('usuarios')
          .get()
          .then((s) => s.docs
              .map((d) => <String, dynamic>{'uid': d.id, ...d.data()})
              .toList());

      if (!mounted) return;

      final q = query.toLowerCase();
      final results = _allUsersCache!
          .where((u) {
            final email = (u['email'] ?? '').toString().toLowerCase();
            final nome = (u['nome'] ?? '').toString().toLowerCase();
            return email.contains(q) || nome.contains(q);
          })
          .map((u) => _GroupMember(
                uid: u['uid'] as String,
                email: u['email']?.toString() ?? '',
                nome: u['nome']?.toString() ?? '',
              ))
          .where((m) => !_members.any((member) => member.uid == m.uid))
          .take(5)
          .toList();

      setState(() {
        _searchResults = results;
        _isSearching = false;
        _searchedOnce = true;
      });
    } catch (_) {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  void _selectMember(_GroupMember member) {
    setState(() {
      _members.add(member);
      _searchResults = [];
      _searchedOnce = false;
      _memberSearchController.clear();
    });
  }

  Future<void> _addMember() async {
    final email = _memberSearchController.text.trim();
    if (email.isEmpty) return;

    final exists = _members.any((m) => m.email.toLowerCase() == email.toLowerCase());
    if (exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Esse membro ja esta adicionado.')),
      );
      return;
    }

    final query = await FirebaseFirestore.instance
        .collection('usuarios')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (!mounted) return;

    if (query.docs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario nao encontrado.')),
      );
      return;
    }

    final userDoc = query.docs.first;
    final userData = userDoc.data();
    setState(() {
      _members.add(_GroupMember(
        uid: userDoc.id,
        email: userData['email'] as String? ?? email,
        nome: userData['nome'] as String? ?? '',
      ));
      _searchResults = [];
      _searchedOnce = false;
      _memberSearchController.clear();
    });
  }

  void _toggleAdmin(int index) {
    setState(() {
      _members[index] = _members[index].copyWith(isAdmin: !_members[index].isAdmin);
    });
  }

  void _removeMember(int index) {
    if (_members[index].isAdmin && _members.where((m) => m.isAdmin).length == 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('O grupo precisa manter pelo menos um admin.')),
      );
      return;
    }
    setState(() => _members.removeAt(index));
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
                      title: 'Informacoes do grupo',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFieldLabel('Nome do grupo'),
                          TextField(
                            controller: _groupNameController,
                            decoration: _inputDecoration('Digite o nome do grupo'),
                          ),
                          const SizedBox(height: 14),
                          _buildFieldLabel('Descricao do grupo'),
                          TextField(
                            controller: _descriptionController,
                            maxLines: 3,
                            decoration: _inputDecoration('Digite a descricao do grupo'),
                          ),
                          const SizedBox(height: 14),
                          _buildFieldLabel('Cor do grupo'),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 10,
                            children: kGroupColors.map((c) {
                              final selected = c.toARGB32() == _selectedColor.toARGB32();
                              return GestureDetector(
                                onTap: () => setState(() => _selectedColor = c),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: c,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: selected ? AppTheme.primaryDark : Colors.transparent,
                                      width: 3,
                                    ),
                                  ),
                                  child: selected
                                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                                      : null,
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSectionCard(
                      title: 'Adicionar membros',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _memberSearchController,
                                  decoration: _inputDecoration('Buscar por nome ou email'),
                                  keyboardType: TextInputType.emailAddress,
                                  onChanged: _searchUsers,
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
                                  child: _isSearching
                                      ? const Padding(
                                          padding: EdgeInsets.all(12),
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Icon(Icons.add_rounded, color: Colors.white, size: 26),
                                ),
                              ),
                            ],
                          ),
                          if (_searchedOnce && _searchResults.isEmpty && !_isSearching) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.search_off_rounded, color: Color(0xFF94A3B8), size: 18),
                                  SizedBox(width: 8),
                                  Text(
                                    'Nenhum usuario encontrado',
                                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ] else if (_searchResults.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: _searchResults.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final user = entry.value;
                                  final displayName = user.nome.isNotEmpty
                                      ? user.nome
                                      : user.email.split('@').first;
                                  return InkWell(
                                    onTap: () => _selectMember(user),
                                    borderRadius: BorderRadius.vertical(
                                      top: index == 0 ? const Radius.circular(12) : Radius.zero,
                                      bottom: index == _searchResults.length - 1
                                          ? const Radius.circular(12)
                                          : Radius.zero,
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 12),
                                      decoration: BoxDecoration(
                                        border: index < _searchResults.length - 1
                                            ? const Border(
                                                bottom: BorderSide(color: Color(0xFFE2E8F0)))
                                            : null,
                                      ),
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 16,
                                            backgroundColor: const Color(0xFFE2E8F0),
                                            child: Text(
                                              displayName[0].toUpperCase(),
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF475569),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  displayName,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w700,
                                                    color: Color(0xFF0F172A),
                                                  ),
                                                ),
                                                Text(
                                                  user.email,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Color(0xFF64748B),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const Icon(
                                            Icons.add_circle_outline_rounded,
                                            color: AppTheme.primaryDark,
                                            size: 20,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildSectionCard(
                      title: 'Membros (${_members.length})',
                      child: _isLoadingMembers
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          : _members.isEmpty
                              ? const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  child: Text(
                                    'Nenhum membro ainda.',
                                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                                  ),
                                )
                              : Column(
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
                                        padding: EdgeInsets.only(
                                          bottom: index == _members.length - 1 ? 0 : 12,
                                        ),
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
                            onPressed: _isSaving ? null : _saveGroup,
                            child: Text(_isSaving ? 'Salvando...' : 'Salvar grupo'),
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
          Text(
            _isEditing ? 'Editar grupo' : 'Criar grupo',
            style: const TextStyle(
              color: AppTheme.primaryDark,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  void _showMemberActions(int index) {
    final member = _members[index];

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return SafeArea(
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
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
                      backgroundColor: member.isAdmin
                          ? const Color(0xFFDBEAFE)
                          : const Color(0xFFE2E8F0),
                      child: Icon(
                        member.isAdmin ? Icons.star_rounded : Icons.person_rounded,
                        color: member.isAdmin
                            ? const Color(0xFF1D4ED8)
                            : const Color(0xFF475569),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        member.nome.isNotEmpty ? member.nome : member.email,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      member.isAdmin ? 'Admin' : 'Membro',
                      style: TextStyle(
                        color: member.isAdmin
                            ? const Color(0xFF1D4ED8)
                            : const Color(0xFF64748B),
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _BottomSheetAction(
                  icon: member.isAdmin
                      ? Icons.remove_moderator_rounded
                      : Icons.verified_rounded,
                  label: member.isAdmin ? 'Remover admin' : 'Promover a admin',
                  isDestructive: false,
                  onTap: () {
                    Navigator.pop(ctx);
                    _toggleAdmin(index);
                  },
                ),
                const SizedBox(height: 10),
                _BottomSheetAction(
                  icon: Icons.person_remove_alt_1_rounded,
                  label: 'Remover do grupo',
                  isDestructive: true,
                  onTap: () {
                    Navigator.pop(ctx);
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

  Widget _buildSectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
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
  final String uid;
  final String email;
  final String nome;
  final bool isAdmin;

  const _GroupMember({
    required this.uid,
    required this.email,
    this.nome = '',
    this.isAdmin = false,
  });

  _GroupMember copyWith({String? uid, String? email, String? nome, bool? isAdmin}) {
    return _GroupMember(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      nome: nome ?? this.nome,
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
    final displayName = member.nome.isNotEmpty
        ? member.nome
        : member.email.contains('@')
            ? member.email.split('@').first
            : member.email;

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
              backgroundColor: member.isAdmin
                  ? const Color(0xFFDBEAFE)
                  : const Color(0xFFE2E8F0),
              child: Icon(
                member.isAdmin ? Icons.star_rounded : Icons.person_rounded,
                color: member.isAdmin
                    ? const Color(0xFF1D4ED8)
                    : const Color(0xFF475569),
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
                          displayName,
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
                  const SizedBox(height: 4),
                  Text(
                    member.email,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.more_horiz_rounded, color: Color(0xFF94A3B8), size: 22),
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
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(999)),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _LegendPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _LegendPill({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w800),
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
                style: TextStyle(color: foreground, fontSize: 14, fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
