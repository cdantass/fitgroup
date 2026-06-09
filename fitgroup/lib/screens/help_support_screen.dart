import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({Key? key}) : super(key: key);

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  static const _faqs = [
    ('Como criar um grupo?',
     'Toque no ícone de grupos (terceiro ícone da barra inferior), depois toque no botão "+" no canto da tela. Preencha o nome, a descrição e escolha uma cor para o grupo.'),
    ('Como entrar em um grupo?',
     'Toque no ícone de grupos (terceiro ícone da barra inferior) e selecione a aba "Descobrir". Use a barra de busca para encontrar o grupo desejado e toque em "Entrar".'),
    ('Como criar um treino?',
     'Na tela inicial (ícone de casa), role até o grupo desejado e toque em "Novo treino". Adicione um nome, escolha o tipo e insira os exercícios.'),
    ('Como marcar exercícios como completos?',
     'Na tela inicial, abra um treino e toque no checkbox ao lado de cada exercício para marcá-lo como concluído.'),
    ('Como apagar um treino?',
     'Na tela inicial, localize o treino no card do grupo, toque no ícone "⋮" (três pontos) no canto superior do card e selecione "Excluir treino".'),
    ('Meus dados são seguros?',
     'Sim! Seus dados são armazenados com segurança no Firebase e vinculados exclusivamente à sua conta. Nenhuma outra pessoa tem acesso às suas informações.'),
    ('Como sair de um grupo?',
     'Toque no ícone de grupos (terceiro ícone da barra inferior) e selecione a aba "Descobrir". Encontre o grupo e toque em "Sair".'),
  ];

  static BoxDecoration get _cardDecoration => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F5),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildInfoCard(),
                const SizedBox(height: 16),
                _sectionLabel('Perguntas Frequentes'),
                const SizedBox(height: 10),
                _buildFaqCard(),
                const SizedBox(height: 24),
                _sectionLabel('Não encontrou sua resposta?'),
                const SizedBox(height: 10),
                _buildContactCard(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.grey, letterSpacing: 0.5)),
      );

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: _cardDecoration,
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: const Color(0xFF5B4DB1).withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.help_outline_rounded, color: Color(0xFF5B4DB1), size: 22),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Central de Ajuda', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                SizedBox(height: 2),
                Text('Encontre respostas para perguntas comuns', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqCard() {
    return Container(
      decoration: _cardDecoration,
      clipBehavior: Clip.hardEdge,
      child: Column(
        children: _faqs.indexed.map((entry) {
          final (i, faq) = entry;
          return Column(
            children: [
              _FaqTile(pergunta: faq.$1, resposta: faq.$2),
              if (i < _faqs.length - 1)
                Divider(height: 1, thickness: 1, color: Colors.grey.shade100, indent: 16, endIndent: 16),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContactCard() {
    return Container(
      decoration: _cardDecoration,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: _sendEmail,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: const Color(0xFF5B4DB1).withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.mail_outline_rounded, color: Color(0xFF5B4DB1), size: 22),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Entrar em Contato', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                      SizedBox(height: 2),
                      Text('Envie um email para o suporte', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF09152B),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 90,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Transform.scale(
                  scale: 1.9,
                  child: Image.asset(
                    'img/logo_fitgroup.png',
                    errorBuilder: (_, __, ___) => const Icon(Icons.image_not_supported, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _sendEmail() async {
  const email = 'caua.dantas@souunit.com.br';
  const subject = 'Ajuda e Suporte - FitGroup';
  const body = 'Olá,\n\nGostaria de receber suporte em relação ao aplicativo FitGroup.\n\nObrigado!';

  final Uri gmailAppUri = Uri.parse(
    'googlegmail://co?to=$email&subject=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}',
  );

  final Uri gmailWebUri = Uri.parse(
    'https://mail.google.com/mail/?view=cm&fs=1&to=$email&su=${Uri.encodeComponent(subject)}&body=${Uri.encodeComponent(body)}',
  );

  try {
    if (await canLaunchUrl(gmailAppUri)) {
      await launchUrl(gmailAppUri);
    } else if (await canLaunchUrl(gmailWebUri)) {
      await launchUrl(gmailWebUri, mode: LaunchMode.externalApplication);
    } else {
      _showEmailFallback(email);
    }
  } catch (_) {
    _showEmailFallback(email);
  }
}

  void _showEmailFallback(String email) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Entrar em Contato'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Envie um email para:'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
              child: Text(email, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF5B4DB1))),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Fechar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5B4DB1), foregroundColor: Colors.white),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: email));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email copiado!')));
              Navigator.pop(ctx);
            },
            child: const Text('Copiar Email'),
          ),
        ],
      ),
    );
  }
}

class _FaqTile extends StatefulWidget {
  final String pergunta;
  final String resposta;
  const _FaqTile({required this.pergunta, required this.resposta});

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      onExpansionChanged: (v) => setState(() => _isExpanded = v),
      tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      title: Text(widget.pergunta,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
      trailing: Icon(
        _isExpanded ? Icons.expand_less_rounded : Icons.expand_more_rounded,
        color: const Color(0xFF5B4DB1),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(widget.resposta,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600, height: 1.6)),
        ),
      ],
    );
  }
}
