import 'package:get/get.dart';
import '../models/property_model.dart';
import '../services/property_service.dart';

class PropertyController extends GetxController {
  final PropertyService _propertyService;
  final RxList<PropertyModel> properties = <PropertyModel>[].obs;
  final Rx<PropertyModel?> selectedProperty = Rx<PropertyModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  // Lista de subtipos customizados por tipo
  final RxMap<PropertyType, RxList<String>> customSubtypes = RxMap<PropertyType, RxList<String>>();

  PropertyController(this._propertyService);

  @override
  void onInit() {
    super.onInit();
    loadProperties();
    _initializeCustomSubtypes();
  }

  void _initializeCustomSubtypes() {
    // Inicializa a lista de subtipos customizados para cada tipo
    for (var type in PropertyType.values) {
      customSubtypes[type] = <String>[].obs;
    }
    // Carrega subtipos customizados do armazenamento local se existirem
    _loadCustomSubtypes();
  }

  void _loadCustomSubtypes() {
    // TODO: Implementar carregamento de subtipos customizados do storage local
  }

  void _saveCustomSubtypes() {
    // TODO: Implementar salvamento de subtipos customizados no storage local
  }

  List<String> getSubtypesForType(PropertyType type) {
    final defaultSubtypes = List<String>.from(propertySubtypes[type] ?? []);
    final custom = customSubtypes[type]?.toList() ?? [];
    
    // Combina os subtipos padrão com os customizados, removendo duplicatas
    return {...defaultSubtypes, ...custom}.toList()..sort();
  }

  void addCustomSubtype(PropertyType type, String newSubtype) {
    if (!customSubtypes.containsKey(type)) {
      customSubtypes[type] = <String>[].obs;
    }
    if (!customSubtypes[type]!.contains(newSubtype)) {
      customSubtypes[type]!.add(newSubtype);
      _saveCustomSubtypes();
    }
  }

  void removeCustomSubtype(PropertyType type, String subtype) {
    // Não permite remover subtipos padrão
    if (propertySubtypes[type]?.contains(subtype) ?? false) {
      return;
    }
    
    customSubtypes[type]?.remove(subtype);
    _saveCustomSubtypes();

    // Se o imóvel selecionado usar este subtipo, atualiza para 'Outro'
    if (selectedProperty.value?.subtype == subtype) {
      updateProperty(selectedProperty.value!.copyWith(subtype: 'Outro'));
    }
  }

  void editCustomSubtype(PropertyType type, String oldSubtype, String newSubtype) {
    // Não permite editar subtipos padrão
    if (propertySubtypes[type]?.contains(oldSubtype) ?? false) {
      return;
    }

    final index = customSubtypes[type]?.indexOf(oldSubtype) ?? -1;
    if (index != -1) {
      customSubtypes[type]![index] = newSubtype;
      _saveCustomSubtypes();

      // Atualiza todos os imóveis que usam o subtipo antigo
      for (var property in properties) {
        if (property.subtype == oldSubtype) {
          updateProperty(property.copyWith(subtype: newSubtype));
        }
      }
    }
  }

  Future<void> loadProperties() async {
    try {
      isLoading.value = true;
      error.value = '';
      final loadedProperties = await _propertyService.getProperties();
      properties.assignAll(loadedProperties);
    } catch (e) {
      error.value = 'Falha ao carregar imóveis: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadProperty(String id) async {
    try {
      isLoading.value = true;
      error.value = '';
      final property = await _propertyService.getProperty(id);
      selectedProperty.value = property;
    } catch (e) {
      error.value = 'Falha ao carregar imóvel: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createProperty(PropertyModel property) async {
    try {
      isLoading.value = true;
      error.value = '';
      final createdProperty = await _propertyService.createProperty(property);
      properties.add(createdProperty);
      Get.back();
      Get.snackbar(
        'Sucesso',
        'Imóvel criado com sucesso',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      error.value = 'Falha ao criar imóvel: ${e.toString()}';
      Get.snackbar(
        'Erro',
        error.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProperty(PropertyModel property) async {
    try {
      isLoading.value = true;
      error.value = '';
      final updatedProperty = await _propertyService.updateProperty(property);
      final index = properties.indexWhere((p) => p.id == property.id);
      if (index != -1) {
        properties[index] = updatedProperty;
      }
      selectedProperty.value = updatedProperty;
      Get.snackbar(
        'Sucesso',
        'Imóvel atualizado com sucesso',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      error.value = 'Falha ao atualizar imóvel: ${e.toString()}';
      Get.snackbar(
        'Erro',
        error.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteProperty(String id) async {
    try {
      isLoading.value = true;
      error.value = '';
      await _propertyService.deleteProperty(id);
      properties.removeWhere((p) => p.id == id);
      if (selectedProperty.value?.id == id) {
        selectedProperty.value = null;
      }
      Get.back();
      Get.snackbar(
        'Sucesso',
        'Imóvel excluído com sucesso',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      error.value = 'Falha ao excluir imóvel: ${e.toString()}';
      Get.snackbar(
        'Erro',
        error.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
