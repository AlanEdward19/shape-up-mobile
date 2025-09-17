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
  bool _isMuted = false;

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

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
    });
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      _controller.setVolume(_isMuted ? 0 : 1);
    });
  }

  void _enterFullScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          VideoPlayer(_controller),
          _buildControls(),
        ],
      ),
    )
        : const Center(child: CircularProgressIndicator());
  }

  Widget _buildControls() {
    return Container(
      color: Colors.black54,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(
              _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
            ),
            onPressed: _togglePlayPause,
          ),
          IconButton(
            icon: Icon(
              _isMuted ? Icons.volume_off : Icons.volume_up,
              color: Colors.white,
            ),
            onPressed: _toggleMute,
          ),
          IconButton(
            icon: const Icon(Icons.fullscreen, color: Colors.white),
            onPressed: _enterFullScreen,
          ),
        ],
      ),
    );
  }
}