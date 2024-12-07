import 'package:get/get.dart';
import '../services/admin_service.dart';
import '../models/organization_model.dart';

class AdminController extends GetxController {
  final AdminService _adminService = AdminService.to;

  // Estado observável
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<OrganizationModel> organizations = <OrganizationModel>[].obs;
  final RxMap<String, dynamic> adminStats = <String, dynamic>{}.obs;

  // Paginação
  final RxInt currentPage = 0.obs;
  final int itemsPerPage = 10;
  final RxBool hasMoreItems = true.obs;

  // Filtros
  final RxString searchTerm = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    try {
      isLoading.value = true;
      await Future.wait([
        loadOrganizations(),
        loadAdminStats(),
      ]);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadOrganizations({bool refresh = false}) async {
    try {
      if (refresh) {
        currentPage.value = 0;
        organizations.clear();
        hasMoreItems.value = true;
      }

      if (!hasMoreItems.value) return;

      final newOrganizations = await _adminService.getOrganizations(
        limit: itemsPerPage,
        offset: currentPage.value * itemsPerPage,
        searchTerm: searchTerm.value,
      );

      if (newOrganizations.length < itemsPerPage) {
        hasMoreItems.value = false;
      }

      organizations.addAll(newOrganizations);
      currentPage.value++;
    } catch (e) {
      errorMessage.value = e.toString();
    }
  }

  Future<void> loadAdminStats() async {
    try {
      final stats = await _adminService.getAdminStats();
      adminStats.value = stats;
    } catch (e) {
      errorMessage.value = e.toString();
    }
  }

  Future<void> createOrganization({
    required String name,
    required String planType,
    String? logoUrl,
    int? inspectionLimit,
    int? userLimit,
    DateTime? trialEndsAt,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _adminService.createOrganization(
        name,
        planType,
        logoUrl: logoUrl,
        inspectionLimit: inspectionLimit,
        userLimit: userLimit,
        trialEndsAt: trialEndsAt,
      );

      await loadOrganizations(refresh: true);
      await loadAdminStats();

      Get.back(); // Fecha o modal/dialog
      Get.snackbar(
        'Sucesso',
        'Organização criada com sucesso',
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateOrganization(
    String id, {
    String? name,
    String? logoUrl,
    String? planType,
    int? inspectionLimit,
    int? userLimit,
    DateTime? trialEndsAt,
    bool? isActive,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      await _adminService.updateOrganization(
        id,
        name: name,
        logoUrl: logoUrl,
        planType: planType,
        inspectionLimit: inspectionLimit,
        userLimit: userLimit,
        trialEndsAt: trialEndsAt,
        isActive: isActive,
      );

      await loadOrganizations(refresh: true);
      await loadAdminStats();

      Get.back(); // Fecha o modal/dialog
      Get.snackbar(
        'Sucesso',
        'Organização atualizada com sucesso',
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void updateSearchTerm(String term) {
    searchTerm.value = term;
    loadOrganizations(refresh: true);
  }
}
