import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthService extends GetxService {
  static AuthService get to => Get.find();
  
  final _supabase = Supabase.instance.client;
  final SharedPreferences _prefs;
  
  AuthService(this._prefs);

  // Estado observável do usuário atual
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  
  // Token de autenticação
  String? get authToken => _prefs.getString('auth_token');

  // Inicialização do serviço
  Future<AuthService> init() async {
    // Verificar se há um token salvo
    final token = _prefs.getString('auth_token');
    if (token != null) {
      try {
        await _loadUserProfile();
      } catch (e) {
        await logout();
      }
    }
    return this;
  }

  // Login com email e senha
  Future<UserModel> login(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.session != null) {
        await _prefs.setString('auth_token', response.session!.accessToken);
        
        // Carregar perfil do usuário
        final user = await _loadUserProfile();
        
        // Registrar último login
        await _supabase
          .from('users')
          .update({'last_login_at': DateTime.now().toIso8601String()})
          .eq('id', user.id);

        return user;
      } else {
        throw Exception('Falha na autenticação');
      }
    } catch (e) {
      throw Exception('Erro no login: ${e.toString()}');
    }
  }

  // Registro de novo usuário
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    String? organizationId,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
          'organization_id': organizationId,
        },
      );

      if (response.user != null) {
        // Criar perfil do usuário
        final userData = {
          'id': response.user!.id,
          'name': name,
          'email': email,
          'roles': [UserRole.viewer.toString()],
          'organization_id': organizationId,
          'is_active': true,
          'created_at': DateTime.now().toIso8601String(),
        };

        await _supabase.from('users').insert(userData);

        // Login automático após registro
        return login(email, password);
      } else {
        throw Exception('Falha no registro');
      }
    } catch (e) {
      throw Exception('Erro no registro: ${e.toString()}');
    }
  }

  // Carregar perfil do usuário
  Future<UserModel> _loadUserProfile() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) throw Exception('Usuário não autenticado');

      final response = await _supabase
        .from('users')
        .select()
        .eq('id', userId)
        .single();

      final user = UserModel.fromJson(response);
      currentUser.value = user;
      return user;
    } catch (e) {
      throw Exception('Erro ao carregar perfil: ${e.toString()}');
    }
  }

  // Logout
  Future<void> logout() async {
    await _supabase.auth.signOut();
    await _prefs.remove('auth_token');
    currentUser.value = null;
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      currentUser.value = null;
    } catch (e) {
      throw Exception('Failed to sign out: ${e.toString()}');
    }
  }

  // Redefinição de senha
  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw Exception('Erro ao redefinir senha: ${e.toString()}');
    }
  }

  // Atualizar senha
  Future<void> updatePassword(String newPassword) async {
    try {
      await _supabase.auth.updateUser(
        UserAttributes(
          password: newPassword,
        ),
      );
    } catch (e) {
      throw Exception('Erro ao atualizar senha: ${e.toString()}');
    }
  }

  // Verificar se o usuário está autenticado
  bool get isAuthenticated => currentUser.value != null;

  // Verificar se o usuário tem determinada role
  bool hasRole(UserRole role) => 
      currentUser.value?.hasRole(role) ?? false;

  // Verificar se o usuário tem alguma das roles
  bool hasAnyRole(List<UserRole> roles) => 
      currentUser.value?.hasAnyRole(roles) ?? false;
}
