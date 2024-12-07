import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import './database_service.dart';
import './sync_service.dart';

class PhotoService {
  static final _picker = ImagePicker();
  static final _uuid = Uuid();

  static Future<String?> takePhoto() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (photo != null) {
      return await _savePhoto(photo);
    }
    return null;
  }

  static Future<String?> pickPhoto() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (photo != null) {
      return await _savePhoto(photo);
    }
    return null;
  }

  static Future<List<String>> pickMultiplePhotos() async {
    final List<XFile> photos = await _picker.pickMultiImage(
      imageQuality: 80,
    );

    final List<String> paths = [];
    for (final photo in photos) {
      final path = await _savePhoto(photo);
      if (path != null) {
        paths.add(path);
      }
    }

    return paths;
  }

  static Future<String?> _savePhoto(XFile photo) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final photosDir = Directory('${appDir.path}/photos');
      if (!await photosDir.exists()) {
        await photosDir.create(recursive: true);
      }

      final fileName = '${_uuid.v4()}${path.extension(photo.path)}';
      final localPath = '${photosDir.path}/$fileName';

      // Copiar a foto para o diretório local
      await File(photo.path).copy(localPath);

      // Adicionar à fila de sincronização
      await DatabaseService.savePhoto(fileName, localPath);

      return localPath;
    } catch (e) {
      print('Erro ao salvar foto: $e');
      return null;
    }
  }

  static Future<void> deletePhoto(String photoPath) async {
    try {
      final file = File(photoPath);
      if (await file.exists()) {
        await file.delete();
      }

      // Adicionar à fila de sincronização para deletar no servidor
      final fileName = path.basename(photoPath);
      await DatabaseService.deletePhoto(fileName);
    } catch (e) {
      print('Erro ao deletar foto: $e');
    }
  }

  static Future<File?> getPhoto(String photoPath) async {
    final file = File(photoPath);
    if (await file.exists()) {
      return file;
    }
    return null;
  }

  static Future<void> syncPhotos() async {
    final syncService = SyncService();
    if (!await syncService.hasInternetConnection()) {
      return;
    }

    final pendingPhotos = await DatabaseService.getPendingPhotoSync();
    for (final photo in pendingPhotos) {
      try {
        if (photo.operation == 'delete') {
          await _deletePhotoFromServer(photo.fileName);
        } else {
          await _uploadPhotoToServer(photo.fileName, photo.localPath);
        }
        await DatabaseService.markPhotoSynced(photo.id!);
      } catch (e) {
        print('Erro ao sincronizar foto ${photo.fileName}: $e');
      }
    }
  }

  static Future<void> _uploadPhotoToServer(String fileName, String localPath) async {
    // TODO: Implementar upload para o servidor
    // Exemplo:
    // final file = File(localPath);
    // final response = await ApiService.uploadPhoto(fileName, file);
  }

  static Future<void> _deletePhotoFromServer(String fileName) async {
    // TODO: Implementar deleção no servidor
    // Exemplo:
    // await ApiService.deletePhoto(fileName);
  }
}
