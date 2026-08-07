import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';

import '../../domain/models/photo.dart';
import '../providers/photos_provider.dart';
import '../../../projects/data/repositories/project_repository.dart';

class PhotosScreen extends StatelessWidget {
  final String projectId;

  const PhotosScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<PhotosProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Фотографии')),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add_a_photo),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (_) {
              return SafeArea(
                child: Wrap(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.photo_library),
                      title: const Text("Выбрать из галереи"),
                      onTap: () async {
                        Navigator.pop(context);
                        await provider.uploadPhoto(projectId);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.photo_camera),
                      title: const Text("Сделать фото"),
                      onTap: () async {
                        Navigator.pop(context);
                        await provider.uploadFromCamera(projectId);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.close),
                      title: const Text("Отмена"),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      body: StreamBuilder<List<Photo>>(
        stream: provider.getPhotos(projectId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final photos = snapshot.data ?? [];

          if (photos.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.photo_library_outlined, size: 80),
                  SizedBox(height: 16),
                  Text(
                    "Фотографий пока нет",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text("Нажмите + чтобы добавить первое фото"),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: photos.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.8,
            ),
            itemBuilder: (context, index) {
              final photo = photos[index];

              return GestureDetector(
                onTap: () {
                  _openPhoto(context, photos, index);
                },
                onLongPress: () async {
                  final action = await showModalBottomSheet<String>(
                    context: context,
                    builder: (_) {
                      return SafeArea(
                        child: Wrap(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.edit_note),
                              title: const Text("Редактировать подпись"),
                              onTap: () {
                                Navigator.pop(context, "edit_caption");
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.star),
                              title: const Text("Сделать обложкой"),
                              onTap: () {
                                Navigator.pop(context, "cover");
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.delete),
                              title: const Text("Удалить"),
                              onTap: () {
                                Navigator.pop(context, "delete");
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.close),
                              title: const Text("Отмена"),
                              onTap: () {
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );

                  if (action == "edit_caption") {
                    await _showEditCaptionDialog(context, photo);
                  }

                  if (action == "cover") {
                    await ProjectRepository().setProjectCover(
                      projectId,
                      photo.imageUrl,
                    );

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Обложка проекта обновлена ⭐"),
                        ),
                      );
                    }
                  }

                  if (action == "delete") {
                    await provider.deletePhoto(photo);
                  }
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Hero(
                        tag: photo.id,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: CachedNetworkImage(
                            imageUrl: photo.imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (_, __) =>
                                const Center(child: CircularProgressIndicator()),
                            errorWidget: (_, __, ___) => const Icon(Icons.error),
                          ),
                        ),
                      ),
                    ),
                    if (photo.caption.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        photo.caption,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _showEditCaptionDialog(BuildContext context, Photo photo) async {
    final controller = TextEditingController(text: photo.caption);
    final caption = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Редактировать подпись'),
          content: TextField(
            controller: controller,
            maxLines: null,
            decoration: const InputDecoration(
              hintText: 'Введите подпись для фото',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Отмена'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: const Text('Сохранить'),
            ),
          ],
        );
      },
    );

    if (caption != null && caption != photo.caption) {
      await Provider.of<PhotosProvider>(context, listen: false)
          .updatePhotoCaption(photo, caption);
    }
  }

  void _openPhoto(BuildContext context, List<Photo> photos, int initialIndex) {
    final controller = PageController(initialPage: initialIndex);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) {
          return Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              title: const Text("Просмотр фото"),
            ),
            body: PageView.builder(
              controller: controller,
              itemCount: photos.length,
              itemBuilder: (context, index) {
                final photo = photos[index];

                return Hero(
                  tag: photo.id,
                  child: PhotoView(
                    imageProvider: CachedNetworkImageProvider(photo.imageUrl),
                    minScale: PhotoViewComputedScale.contained,
                    maxScale: PhotoViewComputedScale.covered * 3,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
