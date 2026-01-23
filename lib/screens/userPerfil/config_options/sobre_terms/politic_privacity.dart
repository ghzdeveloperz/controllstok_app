import 'package:flutter/material.dart';

class PoliticPrivacityScreen extends StatelessWidget {
  const PoliticPrivacityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Política de Privacidade'),
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
            _TitleText('1. Introdução'),
            _BodyText(
              'O ControllStok é um aplicativo de gerenciamento de estoque. '
              'Esta Política de Privacidade descreve como as informações dos usuários '
              'são tratadas e protegidas.',
            ),

            _TitleText('2. Coleta de Dados'),
            _BodyText(
              'O aplicativo pode coletar informações básicas necessárias para o funcionamento, '
              'como dados de login e informações relacionadas aos produtos cadastrados no estoque.',
            ),

            _TitleText('3. Uso das Informações'),
            _BodyText(
              'As informações coletadas são utilizadas exclusivamente para o funcionamento '
              'do aplicativo, melhoria da experiência do usuário e controle interno de estoque.',
            ),

            _TitleText('4. Compartilhamento de Dados'),
            _BodyText(
              'O ControllStok não compartilha dados pessoais com terceiros, exceto quando exigido por lei.',
            ),

            _TitleText('5. Segurança'),
            _BodyText(
              'Adotamos medidas técnicas e organizacionais para proteger os dados armazenados, '
              'reduzindo riscos de acesso não autorizado.',
            ),

            _TitleText('6. Responsabilidades do Usuário'),
            _BodyText(
              'O usuário é responsável por manter suas credenciais de acesso seguras '
              'e por todas as atividades realizadas em sua conta.',
            ),

            _TitleText('7. Alterações'),
            _BodyText(
              'Esta Política de Privacidade pode ser atualizada periodicamente. '
              'Recomendamos que o usuário revise este documento regularmente.',
            ),

            _TitleText('8. Contato'),
            _BodyText(
              'Em caso de dúvidas sobre esta Política de Privacidade, '
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
