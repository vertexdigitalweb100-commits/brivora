import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:provider/provider.dart';

import '../../domain/models/photo.dart';
import '../providers/photos_provider.dart';

class PhotosScreen extends StatelessWidget {
  final String projectId;

  const PhotosScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<PhotosProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Фотографии')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await provider.uploadPhoto(projectId);
        },
        child: const Icon(Icons.add_a_photo),
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
            ),
            itemBuilder: (context, index) {
              final photo = photos[index];

              return GestureDetector(
                onTap: () {
                  _openPhoto(context, photo);
                },
                onLongPress: () async {
                  final delete = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text("Удалить фото?"),
                      content: const Text(
                        "Фотография будет удалена без возможности восстановления.",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text("Отмена"),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text("Удалить"),
                        ),
                      ],
                    ),
                  );

                  if (delete == true) {
                    await provider.deletePhoto(photo);
                  }
                },
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
              );
            },
          );
        },
      ),
    );
  }

  void _openPhoto(BuildContext context, Photo photo) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) {
          return Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              title: const Text('Просмотр фото'),
            ),
            body: Hero(
              tag: photo.id,
              child: PhotoView(
                imageProvider: CachedNetworkImageProvider(photo.imageUrl),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 3,
              ),
            ),
          );
        },
      ),
    );
  }
}
