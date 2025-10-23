// Presentation Layer - Voice Message Playback Widget
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:math';

enum DownloadState { notDownloaded, downloading, downloaded, error }

class VoiceMessagePlayback extends StatefulWidget {
  final String? fileUrl;
  final String? localFilePath;
  final String? fileName;
  final int? fileSize;
  final bool isMe;
  final Duration? duration;

  const VoiceMessagePlayback({
    super.key,
    this.fileUrl,
    this.localFilePath,
    this.fileName,
    this.fileSize,
    required this.isMe,
    this.duration,
  });

  @override
  State<VoiceMessagePlayback> createState() => _VoiceMessagePlaybackState();
}

class _VoiceMessagePlaybackState extends State<VoiceMessagePlayback> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  // Download state management
  DownloadState _downloadState = DownloadState.notDownloaded;
  double _downloadProgress = 0.0;
  String? _localFilePath;

  @override
  void initState() {
    super.initState();
    _checkLocalFile();
    _initializePlayer();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _checkLocalFile() async {
    if (widget.localFilePath != null) {
      final file = File(widget.localFilePath!);
      if (await file.exists()) {
        setState(() {
          _downloadState = DownloadState.downloaded;
          _localFilePath = widget.localFilePath;
        });
        return;
      }
    }

    // Check if file exists in local storage
    if (widget.fileName != null) {
      final localFile = await _getLocalFilePath();
      if (await File(localFile).exists()) {
        setState(() {
          _downloadState = DownloadState.downloaded;
          _localFilePath = localFile;
        });
        return;
      }
    }

    // If no local file exists and we have a URL, mark as not downloaded
    if (widget.fileUrl != null) {
      setState(() {
        _downloadState = DownloadState.notDownloaded;
      });
    }
  }

  Future<String> _getLocalFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    final voiceDir = Directory('${directory.path}/voice_messages');
    if (!await voiceDir.exists()) {
      await voiceDir.create(recursive: true);
    }
    return '${voiceDir.path}/${widget.fileName ?? 'voice_${DateTime.now().millisecondsSinceEpoch}.m4a'}';
  }

  Future<void> _downloadVoiceMessage() async {
    if (widget.fileUrl == null) return;

    setState(() {
      _downloadState = DownloadState.downloading;
      _downloadProgress = 0.0;
    });

    try {
      final response = await http.get(Uri.parse(widget.fileUrl!));

      if (response.statusCode == 200) {
        final localPath = await _getLocalFilePath();
        final file = File(localPath);

        // Write file with progress tracking
        final bytes = response.bodyBytes;
        final sink = file.openWrite();

        for (int i = 0; i < bytes.length; i += 1024) {
          final chunk = bytes.sublist(i, min(i + 1024, bytes.length));
          sink.add(chunk);

          if (mounted) {
            setState(() {
              _downloadProgress = (i + chunk.length) / bytes.length;
            });
          }

          // Small delay to show progress
          await Future.delayed(const Duration(milliseconds: 10));
        }

        await sink.close();

        if (mounted) {
          setState(() {
            _downloadState = DownloadState.downloaded;
            _localFilePath = localPath;
            _downloadProgress = 1.0;
          });
        }

        // Initialize player with local file
        await _initializePlayer();
      } else {
        if (mounted) {
          setState(() {
            _downloadState = DownloadState.error;
          });
        }
      }
    } catch (e) {
      print('Error downloading voice message: $e');
      if (mounted) {
        setState(() {
          _downloadState = DownloadState.error;
        });
      }
    }
  }

  Future<void> _initializePlayer() async {
    try {
      _audioPlayer.onDurationChanged.listen((duration) {
        if (mounted) {
          setState(() {
            _totalDuration = duration;
          });
        }
      });

      _audioPlayer.onPositionChanged.listen((position) {
        if (mounted) {
          setState(() {
            _currentPosition = position;
          });
        }
      });

      _audioPlayer.onPlayerStateChanged.listen((state) {
        if (mounted) {
          setState(() {
            _isPlaying = state == PlayerState.playing;
          });
        }
      });

      _audioPlayer.onPlayerComplete.listen((_) {
        if (mounted) {
          setState(() {
            _isPlaying = false;
            _currentPosition = Duration.zero;
          });
        }
      });
    } catch (e) {
      print('Error initializing audio player: $e');
    }
  }

  Future<void> _togglePlayPause() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        if (_currentPosition == Duration.zero) {
          await _playAudio();
        } else {
          await _audioPlayer.resume();
        }
      }
    } catch (e) {
      print('Error toggling play/pause: $e');
    }
  }

  Future<void> _playAudio() async {
    try {
      // If not downloaded, start download first
      if (_downloadState == DownloadState.notDownloaded) {
        await _downloadVoiceMessage();
        return;
      }

      // If downloading, wait for it to complete
      if (_downloadState == DownloadState.downloading) {
        return;
      }

      // If error, try to download again
      if (_downloadState == DownloadState.error) {
        await _downloadVoiceMessage();
        return;
      }

      String? audioPath;

      // Use local file if available
      if (_localFilePath != null && await File(_localFilePath!).exists()) {
        audioPath = _localFilePath!;
      } else if (widget.localFilePath != null &&
          await File(widget.localFilePath!).exists()) {
        audioPath = widget.localFilePath!;
      } else if (widget.fileUrl != null) {
        audioPath = widget.fileUrl!;
      }

      if (audioPath != null) {
        if (audioPath.startsWith('http')) {
          await _audioPlayer.play(UrlSource(audioPath));
        } else {
          await _audioPlayer.play(DeviceFileSource(audioPath));
        }
      }
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  void _seekTo(Duration position) {
    _audioPlayer.seek(position);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Widget _buildPlayButton() {
    switch (_downloadState) {
      case DownloadState.downloading:
        return Stack(
          alignment: Alignment.center,
          children: [
            CircularProgressIndicator(
              value: _downloadProgress,
              strokeWidth: 3,
              color:
                  Colors
                      .blue[600], // Use consistent blue for both sender and receiver
            ),
            Text(
              '${(_downloadProgress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 8,
                color:
                    Colors
                        .blue[600], // Use consistent blue for both sender and receiver
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );

      case DownloadState.notDownloaded:
        return Icon(
          Icons.download,
          color:
              Colors
                  .blue[600], // Use consistent blue for both sender and receiver
          size: 20,
        );

      case DownloadState.error:
        return Icon(
          Icons.error_outline,
          color: Colors.red, // Use consistent red for both sender and receiver
          size: 20,
        );

      case DownloadState.downloaded:
        return Icon(
          _isPlaying ? Icons.pause : Icons.play_arrow,
          color:
              Colors.white, // Use consistent white for both sender and receiver
          size: 24,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            Colors
                .grey[200], // Use consistent grey background for both sender and receiver
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Play/Pause button with download indicator
          GestureDetector(
            onTap: _togglePlayPause,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color:
                    Colors
                        .blue[600], // Use consistent blue for both sender and receiver
                borderRadius: BorderRadius.circular(20),
              ),
              child: _buildPlayButton(),
            ),
          ),

          const SizedBox(width: 12),

          // Single progress tracker with dots (WhatsApp style)
          Expanded(
            child: Column(
              children: [
                // Single unified progress tracker
                SizedBox(height: 20, child: _buildDotProgressTracker()),

                const SizedBox(height: 4),

                // Duration display
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(_currentPosition),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      _formatDuration(_totalDuration),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDotProgressTracker() {
    return GestureDetector(
      onTapDown: (details) {
        // Calculate tap position and seek to that position
        final RenderBox box = context.findRenderObject() as RenderBox;
        final localPosition = box.globalToLocal(details.globalPosition);
        final progress = localPosition.dx / box.size.width;
        final newPosition = Duration(
          milliseconds: (progress * _totalDuration.inMilliseconds).toInt(),
        );
        _seekTo(newPosition);
      },
      child: CustomPaint(
        painter: DotProgressTrackerPainter(
          currentPosition: _currentPosition,
          totalDuration: _totalDuration,
          isPlaying: _isPlaying,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class DotProgressTrackerPainter extends CustomPainter {
  final Duration currentPosition;
  final Duration totalDuration;
  final bool isPlaying;

  DotProgressTrackerPainter({
    required this.currentPosition,
    required this.totalDuration,
    required this.isPlaying,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (totalDuration.inMilliseconds <= 0) return;

    final progress =
        currentPosition.inMilliseconds / totalDuration.inMilliseconds;
    final dotCount = 30; // Number of dots in the progress tracker
    final dotSpacing = size.width / dotCount;
    final dotRadius = 2.0;
    final currentDotIndex = (progress * dotCount).floor();

    for (int i = 0; i < dotCount; i++) {
      final x = i * dotSpacing + dotSpacing / 2;
      final y = size.height / 2;

      Color dotColor;
      double dotSize = dotRadius;

      if (i < currentDotIndex) {
        // Played portion - white dots
        dotColor = Colors.white;
      } else if (i == currentDotIndex) {
        // Current position - larger green dot
        dotColor = Colors.green;
        dotSize = dotRadius * 1.5;
      } else {
        // Unplayed portion - white dots
        dotColor = Colors.white;
      }

      final paint =
          Paint()
            ..color = dotColor
            ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), dotSize, paint);
    }
  }

  @override
  bool shouldRepaint(DotProgressTrackerPainter oldDelegate) {
    return oldDelegate.currentPosition != currentPosition ||
        oldDelegate.totalDuration != totalDuration ||
        oldDelegate.isPlaying != isPlaying;
  }
}
