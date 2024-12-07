class Validators {
  static String? required(String? value) {
    if (value == null || value.isEmpty) {
      return 'Este campo é obrigatório';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
    );
    
    if (!emailRegex.hasMatch(value)) {
      return 'Email inválido';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    
    final phoneRegex = RegExp(
      r'^\(\d{2}\) \d{4,5}-\d{4}$',
    );
    
    if (!phoneRegex.hasMatch(value)) {
      return 'Telefone inválido';
    }
    return null;
  }

  static String? cpf(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    
    final cpfRegex = RegExp(
      r'^\d{3}\.\d{3}\.\d{3}-\d{2}$',
    );
    
    if (!cpfRegex.hasMatch(value)) {
      return 'CPF inválido';
    }
    return null;
  }

  static String? cnpj(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    
    final cnpjRegex = RegExp(
      r'^\d{2}\.\d{3}\.\d{3}\/\d{4}-\d{2}$',
    );
    
    if (!cnpjRegex.hasMatch(value)) {
      return 'CNPJ inválido';
    }
    return null;
  }

  static String? cep(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    
    final cepRegex = RegExp(
      r'^\d{5}-\d{3}$',
    );
    
    if (!cepRegex.hasMatch(value)) {
      return 'CEP inválido';
    }
    return null;
  }

  static String? minLength(String? value, int minLength) {
    if (value == null || value.isEmpty) {
      return null;
    }
    
    if (value.length < minLength) {
      return 'Deve ter no mínimo $minLength caracteres';
    }
    return null;
  }

  static String? maxLength(String? value, int maxLength) {
    if (value == null || value.isEmpty) {
      return null;
    }
    
    if (value.length > maxLength) {
      return 'Deve ter no máximo $maxLength caracteres';
    }
    return null;
  }

  static String? numeric(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    
    final numericRegex = RegExp(r'^\d+$');
    
    if (!numericRegex.hasMatch(value)) {
      return 'Deve conter apenas números';
    }
    return null;
  }

  static String? combine(List<String? Function(String?)> validators) {
    return (String? value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) {
          return error;
        }
      }
      return null;
    };
  }
}
