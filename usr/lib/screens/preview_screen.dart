import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

enum SourceType { image, video, stream, blackout }

class PreviewScreen extends StatefulWidget {
  final SourceType sourceType;
  final String filePath;

  const PreviewScreen({
    super.key,
    required this.sourceType,
    required this.filePath,
  });

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  VideoPlayerController? _videoController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeMedia();
  }

  Future<void> _initializeMedia() async {
    if (widget.sourceType == SourceType.video) {
      _videoController = VideoPlayerController.file(File(widget.filePath));
      await _videoController!.initialize();
      await _videoController!.setLooping(true);
      await _videoController!.play();
    } else if (widget.sourceType == SourceType.stream) {
      // Note: Standard VideoPlayer supports some network streams (HTTP/HLS).
      // For RTSP/RTMP, a more specialized package like fjkplayer or vlc might be needed in production.
      // We will attempt standard network load here.
      _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.filePath));
      try {
        await _videoController!.initialize();
        await _videoController!.play();
      } catch (e) {
        debugPrint('Error loading stream: $e');
      }
    }
    
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Live Feed Preview', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Placeholder for settings
            },
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Center(
        child: _buildContent(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Placeholder for "Start Broadcasting" or "Record"
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Broadcasting started (Simulation)')),
          );
        },
        backgroundColor: Colors.red,
        child: const Icon(Icons.videocam),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildContent() {
    switch (widget.sourceType) {
      case SourceType.blackout:
        return Container(color: Colors.black);
      
      case SourceType.image:
        return Image.file(
          File(widget.filePath),
          fit: BoxFit.contain,
          width: double.infinity,
          height: double.infinity,
        );
        
      case SourceType.video:
      case SourceType.stream:
        if (!_isInitialized || _videoController == null) {
          return const CircularProgressIndicator();
        }
        if (_videoController!.value.hasError) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                'Error loading media:\n${_videoController!.value.errorDescription}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
            ],
          );
        }
        return AspectRatio(
          aspectRatio: _videoController!.value.aspectRatio,
          child: VideoPlayer(_videoController!),
        );
    }
  }
}
