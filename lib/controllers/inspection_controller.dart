import 'package:get/get.dart';
import '../models/inspection_model.dart';
import '../services/inspection_service.dart';

class InspectionController extends GetxController {
  final InspectionService _inspectionService;
  final RxList<InspectionModel> inspections = <InspectionModel>[].obs;
  final Rx<InspectionModel?> selectedInspection = Rx<InspectionModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  InspectionController(this._inspectionService);

  @override
  void onInit() {
    super.onInit();
    loadInspections();
  }

  Future<void> loadInspections({
    String? organizationId,
    String? inspectorId,
    String? clientId,
    InspectionStatus? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';

      final loadedInspections = await _inspectionService.getInspections(
        organizationId: organizationId,
        inspectorId: inspectorId,
        clientId: clientId,
        status: status,
        startDate: startDate,
        endDate: endDate,
      );

      inspections.assignAll(loadedInspections);
    } catch (e) {
      error.value = 'Failed to load inspections: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadInspection(String id) async {
    try {
      isLoading.value = true;
      error.value = '';

      final inspection = await _inspectionService.getInspection(id);
      selectedInspection.value = inspection;
    } catch (e) {
      error.value = 'Failed to load inspection: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createInspection(InspectionModel inspection) async {
    try {
      isLoading.value = true;
      error.value = '';

      final createdInspection =
          await _inspectionService.createInspection(inspection);
      inspections.add(createdInspection);
      selectedInspection.value = createdInspection;
    } catch (e) {
      error.value = 'Failed to create inspection: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateInspection(InspectionModel inspection) async {
    try {
      isLoading.value = true;
      error.value = '';

      final updatedInspection =
          await _inspectionService.updateInspection(inspection);
      final index = inspections.indexWhere((i) => i.id == inspection.id);
      if (index != -1) {
        inspections[index] = updatedInspection;
      }
      selectedInspection.value = updatedInspection;
    } catch (e) {
      error.value = 'Failed to update inspection: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteInspection(String id) async {
    try {
      isLoading.value = true;
      error.value = '';

      await _inspectionService.deleteInspection(id);
      inspections.removeWhere((inspection) => inspection.id == id);
      if (selectedInspection.value?.id == id) {
        selectedInspection.value = null;
      }
    } catch (e) {
      error.value = 'Failed to delete inspection: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addPhoto(String inspectionId, String photoUrl) async {
    try {
      isLoading.value = true;
      error.value = '';

      await _inspectionService.addPhoto(inspectionId, photoUrl);
      await loadInspection(inspectionId);
    } catch (e) {
      error.value = 'Failed to add photo: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> removePhoto(String inspectionId, String photoUrl) async {
    try {
      isLoading.value = true;
      error.value = '';

      await _inspectionService.removePhoto(inspectionId, photoUrl);
      await loadInspection(inspectionId);
    } catch (e) {
      error.value = 'Failed to remove photo: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addDocument(String inspectionId, String documentUrl) async {
    try {
      isLoading.value = true;
      error.value = '';

      await _inspectionService.addDocument(inspectionId, documentUrl);
      await loadInspection(inspectionId);
    } catch (e) {
      error.value = 'Failed to add document: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> removeDocument(String inspectionId, String documentUrl) async {
    try {
      isLoading.value = true;
      error.value = '';

      await _inspectionService.removeDocument(inspectionId, documentUrl);
      await loadInspection(inspectionId);
    } catch (e) {
      error.value = 'Failed to remove document: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateStatus(
      String inspectionId, InspectionStatus status) async {
    try {
      isLoading.value = true;
      error.value = '';

      await _inspectionService.updateStatus(inspectionId, status);
      await loadInspection(inspectionId);
    } catch (e) {
      error.value = 'Failed to update status: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateData(
      String inspectionId, Map<String, dynamic> data) async {
    try {
      isLoading.value = true;
      error.value = '';

      await _inspectionService.updateData(inspectionId, data);
      await loadInspection(inspectionId);
    } catch (e) {
      error.value = 'Failed to update data: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadInspectionsByDateRange(
    DateTime startDate,
    DateTime endDate, {
    String? organizationId,
    String? inspectorId,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';

      final loadedInspections =
          await _inspectionService.getInspectionsByDateRange(
        startDate,
        endDate,
        organizationId: organizationId,
        inspectorId: inspectorId,
      );

      inspections.assignAll(loadedInspections);
    } catch (e) {
      error.value = 'Failed to load inspections by date range: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadPendingInspections({
    String? organizationId,
    String? inspectorId,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';

      final loadedInspections = await _inspectionService.getPendingInspections(
        organizationId: organizationId,
        inspectorId: inspectorId,
      );

      inspections.assignAll(loadedInspections);
    } catch (e) {
      error.value = 'Failed to load pending inspections: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadCompletedInspections({
    String? organizationId,
    String? inspectorId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      isLoading.value = true;
      error.value = '';

      final loadedInspections =
          await _inspectionService.getCompletedInspections(
        organizationId: organizationId,
        inspectorId: inspectorId,
        startDate: startDate,
        endDate: endDate,
      );

      inspections.assignAll(loadedInspections);
    } catch (e) {
      error.value = 'Failed to load completed inspections: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }
}
