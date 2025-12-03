import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'preview_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker _picker = ImagePicker();
  
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PreviewScreen(
              sourceType: SourceType.image,
              filePath: image.path,
            ),
          ),
        );
      }
    } catch (e) {
      _showError('Error picking image: $e');
    }
  }

  Future<void> _pickVideo(ImageSource source) async {
    try {
      final XFile? video = await _picker.pickVideo(source: source);
      if (video != null) {
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PreviewScreen(
              sourceType: SourceType.video,
              filePath: video.path,
            ),
          ),
        );
      }
    } catch (e) {
      _showError('Error picking video: $e');
    }
  }

  void _openNetworkStreamDialog() {
    final TextEditingController urlController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Stream URL'),
        content: TextField(
          controller: urlController,
          decoration: const InputDecoration(
            hintText: 'http://, rtsp://, or rtmp://',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (urlController.text.isNotEmpty) {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PreviewScreen(
                      sourceType: SourceType.stream,
                      filePath: urlController.text,
                    ),
                  ),
                );
              }
            },
            child: const Text('Connect'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Virtual Camera Studio'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionHeader('Select Source'),
          const SizedBox(height: 10),
          _buildSourceCard(
            icon: Icons.image,
            title: 'Photo Gallery',
            subtitle: 'Use a static photo as your camera feed',
            color: Colors.blue,
            onTap: () => _pickImage(ImageSource.gallery),
          ),
          const SizedBox(height: 12),
          _buildSourceCard(
            icon: Icons.videocam,
            title: 'Video File',
            subtitle: 'Loop a video from your device',
            color: Colors.orange,
            onTap: () => _pickVideo(ImageSource.gallery),
          ),
          const SizedBox(height: 12),
          _buildSourceCard(
            icon: Icons.cast_connected,
            title: 'Network Stream',
            subtitle: 'Connect to IP camera or RTMP stream',
            color: Colors.purple,
            onTap: _openNetworkStreamDialog,
          ),
          const SizedBox(height: 24),
          _buildSectionHeader('Privacy Tools'),
          const SizedBox(height: 10),
          _buildSourceCard(
            icon: Icons.security,
            title: 'Blackout Mode',
            subtitle: 'Instantly show a black screen',
            color: Colors.grey,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PreviewScreen(
                    sourceType: SourceType.blackout,
                    filePath: '',
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
    );
  }

  Widget _buildSourceCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
