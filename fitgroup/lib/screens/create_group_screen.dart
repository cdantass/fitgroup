import 'package:flutter/material.dart';
import '../models/group.dart';
import '../state/group_state.dart';
import '../theme/app_theme.dart';

class CreateGroupScreen extends StatefulWidget {
  final Group? group;

  const CreateGroupScreen({super.key, this.group});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late Color _color;

  bool get _isEditing => widget.group != null;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.group?.name ?? '');
    _descCtrl = TextEditingController(text: widget.group?.description ?? '');
    _color = widget.group?.color ?? kGroupColors.first;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameCtrl.text.trim();
    final desc = _descCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Nome obrigatório')));
      return;
    }
    if (_isEditing) {
      GroupState.instance
          .updateGroup(widget.group!.id, name: name, description: desc, color: _color);
    } else {
      GroupState.instance.createGroup(name: name, description: desc, color: _color);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Editar grupo' : 'Novo grupo',
          style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Colors.white),
        ),
        backgroundColor: AppTheme.primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PreviewCard(
              name: _nameCtrl.text,
              description: _descCtrl.text,
              color: _color,
            ),
            const SizedBox(height: 28),
            _label('Nome do grupo'),
            const SizedBox(height: 8),
            _field(_nameCtrl, 'Ex: Grupo de corrida',
                onChanged: (_) => setState(() {})),
            const SizedBox(height: 20),
            _label('Descrição'),
            const SizedBox(height: 8),
            _field(_descCtrl, 'Ex: Todo dia às 7h, Parque X',
                maxLines: 3, onChanged: (_) => setState(() {})),
            const SizedBox(height: 20),
            _label('Cor do grupo'),
            const SizedBox(height: 12),
            _colorPicker(),
            const SizedBox(height: 36),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryDark,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(
                  _isEditing ? 'Salvar alterações' : 'Criar grupo',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFF374151)),
      );

  Widget _field(
    TextEditingController ctrl,
    String hint, {
    int maxLines = 1,
    void Function(String)? onChanged,
  }) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        filled: true,
        fillColor: const Color(0xFFF8F9FA),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200)),
        focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: AppTheme.purple, width: 1.5)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }

  Widget _colorPicker() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: kGroupColors.map((c) {
        final selected = c.toARGB32() == _color.toARGB32();
        return GestureDetector(
          onTap: () => setState(() => _color = c),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: c,
              shape: BoxShape.circle,
              border: Border.all(
                  color: selected ? AppTheme.primaryDark : Colors.transparent,
                  width: 3),
              boxShadow: [
                BoxShadow(
                    color: c.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 3))
              ],
            ),
            child: selected
                ? const Icon(Icons.check, color: Colors.white, size: 18)
                : null,
          ),
        );
      }).toList(),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  final String name;
  final String description;
  final Color color;

  const _PreviewCard(
      {required this.name, required this.description, required this.color});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: double.infinity,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 8))
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name.isEmpty ? 'Nome do grupo' : name,
            style: TextStyle(
              color: name.isEmpty
                  ? Colors.white.withValues(alpha: 0.5)
                  : Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description.isEmpty ? 'Descrição do grupo' : description,
            style: TextStyle(
              color: description.isEmpty
                  ? Colors.white.withValues(alpha: 0.4)
                  : Colors.white.withValues(alpha: 0.85),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
