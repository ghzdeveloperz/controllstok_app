String mapAuthErrorToMessage(dynamic error) {
  final message = error.toString().toLowerCase();

  if (message.contains('wrong-password') ||
      message.contains('user-not-found') ||
      message.contains('invalid-credential')) {
    return 'E-mail ou senha incorretos';
  }

  if (message.contains('invalid-email')) {
    return 'E-mail inválido';
  }

  if (message.contains('too-many-requests')) {
    return 'Muitas tentativas. Tente novamente mais tarde';
  }

  if (message.contains('network')) {
    return 'Erro de conexão. Verifique sua internet';
  }

  return 'Erro ao autenticar. Tente novamente';
}
