import 'package:flutter/material.dart';
import 'rotinas_screen.dart';

class CriarScreen extends StatefulWidget {
  const CriarScreen({super.key});

  @override
  State<CriarScreen> createState() => _CriarScreenState();
}

class _CriarScreenState extends State<CriarScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _categoriaController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _exercicioController = TextEditingController();

  final List<String> _exercicios = [];

  @override
  void dispose() {
    _nomeController.dispose();
    _categoriaController.dispose();
    _descricaoController.dispose();
    _exercicioController.dispose();
    super.dispose();
  }

  void _adicionarExercicio() {
    final texto = _exercicioController.text.trim();
    if (texto.isNotEmpty) {
      setState(() {
        _exercicios.add(texto);
        _exercicioController.clear();
      });
    }
  }

  void _salvar() {
    if (_formKey.currentState?.validate() ?? false) {
      // Lógica de salvar
      Navigator.pop(context);
    }
  }

  void _cancelar() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhite,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      _buildField(
                        label: 'Nome da rotina',
                        hint: 'nome da rotina',
                        controller: _nomeController,
                        validator: (v) =>
                            (v == null || v.isEmpty) ? 'Informe o nome' : null,
                      ),
                      const SizedBox(height: 20),
                      _buildField(
                        label: 'Categoria',
                        hint: 'categoria da rotina',
                        controller: _categoriaController,
                      ),
                      const SizedBox(height: 20),
                      _buildField(
                        label: 'Descrição',
                        hint: 'descrição da rotina',
                        controller: _descricaoController,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 20),
                      _buildExercicioField(),
                      if (_exercicios.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _buildExerciciosList(),
                      ],
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
            _buildBottomButtons(),
          ],
        ),
      ),
      bottomNavigationBar: const FitgroupBottomNav(selectedIndex: 1),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
        children: [
          TextButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.chevron_left, color: kTextDark, size: 22),
            label: const Text(
              'Treinos',
              style: TextStyle(color: kTextDark, fontSize: 15),
            ),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required String label,
    required String hint,
    required TextEditingController controller,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: kTextDark,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 14, color: kTextDark),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: kTextGrey, fontSize: 14),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: kBorderGrey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: kDarkNavy, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.red, width: 1.5),
            ),
            filled: true,
            fillColor: kWhite,
          ),
        ),
      ],
    );
  }

  Widget _buildExercicioField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Adicionar exercício',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: kTextDark,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _exercicioController,
                style: const TextStyle(fontSize: 14, color: kTextDark),
                onFieldSubmitted: (_) => _adicionarExercicio(),
                decoration: InputDecoration(
                  hintText: 'adicionar exercício',
                  hintStyle: TextStyle(color: kTextGrey, fontSize: 14),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 14),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: kBorderGrey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: kDarkNavy, width: 1.5),
                  ),
                  filled: true,
                  fillColor: kWhite,
                  suffixIcon: GestureDetector(
                    onTap: _adicionarExercicio,
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: kDarkNavy,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.add, color: kWhite, size: 18),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExerciciosList() {
    return Column(
      children: _exercicios
          .asMap()
          .entries
          .map(
            (entry) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: kLightGrey,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: kBorderGrey),
              ),
              child: Row(
                children: [
                  const Icon(Icons.fitness_center,
                      size: 16, color: kTextGrey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: const TextStyle(
                          fontSize: 14, color: kTextDark),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() => _exercicios.removeAt(entry.key));
                    },
                    child:
                        const Icon(Icons.close, size: 16, color: kTextGrey),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: BoxDecoration(
        color: kWhite,
        border: Border(top: BorderSide(color: kBorderGrey)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _cancelar,
              style: OutlinedButton.styleFrom(
                foregroundColor: kTextDark,
                side: BorderSide(color: kBorderGrey),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                'Cancelar',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _salvar,
              style: ElevatedButton.styleFrom(
                backgroundColor: kDarkNavy,
                foregroundColor: kWhite,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
              ),
              child: const Text(
                'Salvar',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }
}