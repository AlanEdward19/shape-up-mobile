import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ImageCarouselWithIndicator extends StatefulWidget {
  final List<String> mediaUrls;

  const ImageCarouselWithIndicator({super.key, required this.mediaUrls});

  @override
  State<ImageCarouselWithIndicator> createState() => _ImageCarouselWithIndicatorState();
}

class _ImageCarouselWithIndicatorState extends State<ImageCarouselWithIndicator> {
  int _currentPage = 0;
  final PageController _controller = PageController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 300,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.mediaUrls.length,
            scrollDirection: Axis.horizontal,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              final url = widget.mediaUrls[index];
              if (isVideo(url)) {
                return VideoPlayerWidget(videoUrl: url);
              } else {
                return Image.network(
                  url,
                  fit: BoxFit.cover,
                  width: double.infinity,
                );
              }
            },
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.mediaUrls.length, (index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 8,
              width: _currentPage == index ? 16 : 8,
              decoration: BoxDecoration(
                color: _currentPage == index ? Colors.blueAccent : Colors.grey,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }

  bool isVideo(String url) {
    const videoExtensions = ['.mp4', '.webm', '.mov', '.ogg'];
    final cleanUrl = url.split('?')[0].split('#')[0];
    return videoExtensions.any((ext) => cleanUrl.toLowerCase().endsWith(ext));
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerWidget({super.key, required this.videoUrl});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: VideoPlayer(_controller),
    )
        : const Center(child: CircularProgressIndicator());
  }
}