import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService.to;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString error = ''.obs;

  Rx<UserModel?> get currentUser => _authService.currentUser;
  bool get isAuthenticated => _authService.isAuthenticated;

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      await _authService.login(email, password);
      Get.offAllNamed('/home');
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    String? organizationId,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      await _authService.register(
        name: name,
        email: email,
        password: password,
        organizationId: organizationId,
      );
      Get.offAllNamed('/home');
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    Get.offAllNamed('/login');
  }

  Future<void> signOut() async {
    try {
      await _authService.signOut();
      Get.offAllNamed('/login');
    } catch (e) {
      error.value = 'Failed to sign out: ${e.toString()}';
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      await _authService.resetPassword(email);
      Get.snackbar(
        'Sucesso',
        'Email de redefinição de senha enviado',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
