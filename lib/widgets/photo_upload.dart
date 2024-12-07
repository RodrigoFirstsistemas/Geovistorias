import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/photo_service.dart';
import '../theme/app_theme.dart';

class PhotoUpload extends StatelessWidget {
  final List<String> photos;
  final Function(List<String>) onPhotosChanged;
  final int maxPhotos;
  final bool showAddButton;

  const PhotoUpload({
    Key? key,
    required this.photos,
    required this.onPhotosChanged,
    this.maxPhotos = 10,
    this.showAddButton = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (photos.isNotEmpty)
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: photos.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: AppTheme.paddingSmall),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppTheme.borderRadiusMedium),
                          child: Image.file(
                            File(photos[index]),
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 18,
                              ),
                              onPressed: () {
                                final newPhotos = List<String>.from(photos);
                                newPhotos.removeAt(index);
                                onPhotosChanged(newPhotos);
                              },
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 4,
                          right: 4,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(AppTheme.borderRadiusSmall),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.fullscreen,
                                color: Colors.white,
                                size: 18,
                              ),
                              onPressed: () => _showPhotoViewer(context, photos[index]),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        if (showAddButton && photos.length < maxPhotos)
          Padding(
            padding: const EdgeInsets.only(top: AppTheme.paddingMedium),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ElevatedButton.icon(
                  onPressed: () => _showPhotoOptions(context),
                  icon: const Icon(Icons.add_a_photo),
                  label: const Text('Adicionar Foto'),
                ),
                if (photos.isNotEmpty) ...[
                  const SizedBox(width: AppTheme.paddingMedium),
                  Text(
                    '${photos.length}/$maxPhotos fotos',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }

  void _showPhotoOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Tirar Foto'),
              onTap: () async {
                Get.back();
                final photo = await PhotoService.takePhoto();
                if (photo != null) {
                  final newPhotos = List<String>.from(photos)..add(photo);
                  onPhotosChanged(newPhotos);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Escolher da Galeria'),
              onTap: () async {
                Get.back();
                final remainingPhotos = maxPhotos - photos.length;
                if (remainingPhotos > 1) {
                  final newPhotos = await PhotoService.pickMultiplePhotos();
                  if (newPhotos.isNotEmpty) {
                    final allPhotos = List<String>.from(photos)..addAll(newPhotos);
                    if (allPhotos.length > maxPhotos) {
                      allPhotos.removeRange(maxPhotos, allPhotos.length);
                    }
                    onPhotosChanged(allPhotos);
                  }
                } else {
                  final photo = await PhotoService.pickPhoto();
                  if (photo != null) {
                    final newPhotos = List<String>.from(photos)..add(photo);
                    onPhotosChanged(newPhotos);
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showPhotoViewer(BuildContext context, String photoPath) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Stack(
          children: [
            InteractiveViewer(
              child: Image.file(
                File(photoPath),
                fit: BoxFit.contain,
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                ),
                onPressed: () => Get.back(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
