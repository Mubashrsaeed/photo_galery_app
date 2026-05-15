import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoDetailScreen extends StatefulWidget {
  final List<String> videoList;
  final int initialIndex;

  const VideoDetailScreen({
    super.key,
    required this.videoList,
    required this.initialIndex,
  });

  @override
  State<VideoDetailScreen> createState() => _VideoDetailScreenState();
}

class _VideoDetailScreenState extends State<VideoDetailScreen> {
  late PageController pageController;
  late VideoPlayerController controller;

  int currentIndex = 0;
  bool showControls = true;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    pageController = PageController(initialPage: currentIndex);
    _loadVideo(currentIndex);
  }

  Future<void> _loadVideo(int index) async {
    controller = VideoPlayerController.asset(widget.videoList[index]);
    await controller.initialize();
    setState(() {});
    controller.play();
  }

  void _next() {
    if (currentIndex < widget.videoList.length - 1) {
      currentIndex++;
      controller.dispose();
      _loadVideo(currentIndex);
    }
  }

  void _previous() {
    if (currentIndex > 0) {
      currentIndex--;
      controller.dispose();
      _loadVideo(currentIndex);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: controller.value.isInitialized
          ? GestureDetector(
              onDoubleTapDown: (details) {
                final width = MediaQuery.of(context).size.width;

                if (details.globalPosition.dx < width / 2) {
                  _previous(); // LEFT = back
                } else {
                  _next(); // RIGHT = forward
                }
              },

              onTap: () {
                setState(() {
                  showControls = !showControls;
                });
              },

              child: Stack(
                children: [
                  Center(
                    child: AspectRatio(
                      aspectRatio: controller.value.aspectRatio,
                      child: VideoPlayer(controller),
                    ),
                  ),

                  if (showControls)
                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: Column(
                        children: [
                          VideoProgressIndicator(
                            controller,
                            allowScrubbing: true,
                          ),

                          const SizedBox(height: 10),

                          Text(
                            "${controller.value.position.toString().split('.').first} / "
                            "${controller.value.duration.toString().split('.').first}",
                            style: const TextStyle(color: Colors.white),
                          ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.skip_previous,
                                  color: Colors.white,
                                ),
                                onPressed: _previous,
                              ),

                              IconButton(
                                icon: Icon(
                                  controller.value.isPlaying
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  setState(() {
                                    controller.value.isPlaying
                                        ? controller.pause()
                                        : controller.play();
                                  });
                                },
                              ),

                              IconButton(
                                icon: const Icon(
                                  Icons.skip_next,
                                  color: Colors.white,
                                ),
                                onPressed: _next,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
