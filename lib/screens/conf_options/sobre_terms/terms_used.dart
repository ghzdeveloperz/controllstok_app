import 'package:flutter/material.dart';

class TermsUsedScreen extends StatelessWidget {
  const TermsUsedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Termos de Uso'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            _TitleText('1. Aceitação dos Termos'),
            _BodyText(
              'Ao utilizar o aplicativo ControllStok, o usuário concorda integralmente '
              'com estes Termos de Uso. Caso não concorde, recomenda-se não utilizar o aplicativo.',
            ),

            _TitleText('2. Finalidade do Aplicativo'),
            _BodyText(
              'O ControllStok tem como finalidade auxiliar no gerenciamento de estoque, '
              'permitindo o controle de produtos, quantidades e informações relacionadas.',
            ),

            _TitleText('3. Cadastro e Responsabilidade'),
            _BodyText(
              'O usuário é responsável pelas informações fornecidas no cadastro '
              'e por manter a confidencialidade de seus dados de acesso.',
            ),

            _TitleText('4. Uso Adequado'),
            _BodyText(
              'É proibido utilizar o aplicativo para fins ilícitos, fraudulentos '
              'ou que possam comprometer a segurança e o funcionamento do sistema.',
            ),

            _TitleText('5. Limitação de Responsabilidade'),
            _BodyText(
              'O ControllStok não se responsabiliza por perdas, danos ou prejuízos '
              'decorrentes do uso inadequado do aplicativo ou de informações incorretas inseridas pelo usuário.',
            ),

            _TitleText('6. Disponibilidade'),
            _BodyText(
              'O aplicativo pode sofrer interrupções temporárias para manutenção, '
              'atualizações ou por fatores externos fora do controle do desenvolvedor.',
            ),

            _TitleText('7. Alterações nos Termos'),
            _BodyText(
              'Os Termos de Uso podem ser alterados a qualquer momento. '
              'Recomenda-se que o usuário revise este documento periodicamente.',
            ),

            _TitleText('8. Contato'),
            _BodyText(
              'Em caso de dúvidas relacionadas a estes Termos de Uso, '
              'entre em contato pelo e-mail: contact@mystoreday.com.',
            ),

            SizedBox(height: 24),

            Text(
              'Última atualização: Janeiro de 2025',
              style: TextStyle(color: Colors.black54, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _TitleText extends StatelessWidget {
  final String text;

  const _TitleText(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 20),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _BodyText extends StatelessWidget {
  final String text;

  const _BodyText(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        height: 1.5,
        color: Colors.black87,
      ),
    );
  }
}
