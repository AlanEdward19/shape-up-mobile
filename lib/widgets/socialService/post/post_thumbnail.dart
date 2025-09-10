import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';

class PostThumbnail extends StatelessWidget {
  final String mediaUrl;

  const PostThumbnail({required this.mediaUrl, Key? key}) : super(key: key);

  Future<String?> _generateThumbnail(String videoPath) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final thumbnailPath = await VideoThumbnail.thumbnailFile(
        video: videoPath,
        thumbnailPath: tempDir.path,
        imageFormat: ImageFormat.JPEG,
        maxHeight: 200, // Altura máxima da thumbnail
        quality: 75, // Qualidade da imagem
      );
      return thumbnailPath;
    } catch (e) {
      debugPrint("Erro ao gerar thumbnail: $e");
      return null;
    }
  }

  bool checkIfMediaIsVideo(String url) {
    const videoExtensions = ['.mp4', '.webm', '.mov', '.ogg'];
    final cleanUrl = url.split('?')[0].split('#')[0];
    return videoExtensions.any((ext) => cleanUrl.toLowerCase().endsWith(ext));
  }

  @override
  Widget build(BuildContext context) {
    final isVideo = checkIfMediaIsVideo(mediaUrl);

    if (isVideo) {
      return FutureBuilder<String?>(
        future: _generateThumbnail(mediaUrl),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || snapshot.data == null) {
            return const Icon(Icons.error, color: Colors.red);
          } else {
            return Image.file(File(snapshot.data!), fit: BoxFit.cover);
          }
        },
      );
    } else {
      return Image.network(mediaUrl, fit: BoxFit.cover);
    }
  }
}