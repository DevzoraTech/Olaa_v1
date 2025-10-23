// Presentation Layer - Audio File Playback Widget
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:math';

enum DownloadState { notDownloaded, downloading, downloaded, error }

class AudioFilePlayback extends StatefulWidget {
  final String? fileUrl;
  final String? localFilePath;
  final String? fileName;
  final int? fileSize;
  final bool isMe;
  final Duration? duration;
  final bool isDownloaded;
  final double downloadProgress;
  final bool isDownloading;
  final Function(String)?
  onDownloadComplete; // Callback to update message state

  const AudioFilePlayback({
    super.key,
    this.fileUrl,
    this.localFilePath,
    this.fileName,
    this.fileSize,
    required this.isMe,
    this.duration,
    this.isDownloaded = false,
    this.downloadProgress = 0.0,
    this.isDownloading = false,
    this.onDownloadComplete,
  });

  @override
  State<AudioFilePlayback> createState() => _AudioFilePlaybackState();
}

class _AudioFilePlaybackState extends State<AudioFilePlayback> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  List<double> _waveformData = [];

  // Download state management
  DownloadState _downloadState = DownloadState.notDownloaded;
  double _downloadProgress = 0.0;
  String? _localFilePath;

  @override
  void initState() {
    super.initState();
    _initializeDownloadState();
    _checkLocalFile();
    _initializePlayer();
    _generateWaveformData();
  }

  void _initializeDownloadState() {
    if (widget.isDownloaded && widget.localFilePath != null) {
      _downloadState = DownloadState.downloaded;
      _localFilePath = widget.localFilePath;
    } else if (widget.isDownloading) {
      _downloadState = DownloadState.downloading;
      _downloadProgress = widget.downloadProgress;
    } else {
      _downloadState = DownloadState.notDownloaded;
    }
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
    final localPath = await _getLocalFilePath();
    if (localPath != null) {
      final file = File(localPath);
      if (await file.exists()) {
        setState(() {
          _downloadState = DownloadState.downloaded;
          _localFilePath = localPath;
        });
      }
    }
  }

  Future<String?> _getLocalFilePath() async {
    if (widget.fileUrl == null) return null;

    try {
      final directory = await getApplicationDocumentsDirectory();
      final chatMediaDir = Directory('${directory.path}/chat_media');
      if (!await chatMediaDir.exists()) {
        await chatMediaDir.create(recursive: true);
      }

      // Extract filename from URL or use a generated name
      final fileName =
          widget.fileName ?? 'audio_${DateTime.now().millisecondsSinceEpoch}';
      return '${chatMediaDir.path}/$fileName';
    } catch (e) {
      print('Error getting local file path: $e');
      return null;
    }
  }

  Future<void> _initializePlayer() async {
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state == PlayerState.playing;
        });
      }
    });

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
  }

  void _generateWaveformData() {
    // Generate random waveform data for visualization
    final random = Random();
    _waveformData = List.generate(
      50,
      (index) => random.nextDouble() * 0.8 + 0.2,
    );
  }

  Future<void> _downloadAudioFile() async {
    if (widget.fileUrl == null) return;

    setState(() {
      _downloadState = DownloadState.downloading;
      _downloadProgress = 0.0;
    });

    try {
      final client = http.Client();
      final request = http.Request('GET', Uri.parse(widget.fileUrl!));

      // Set timeout for faster failure detection
      final streamedResponse = await client
          .send(request)
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              client.close();
              throw Exception('Download timeout');
            },
          );

      if (streamedResponse.statusCode == 200) {
        final localPath = await _getLocalFilePath();
        if (localPath != null) {
          final file = File(localPath);
          final sink = file.openWrite();

          // Get total content length for progress tracking
          final totalBytes = streamedResponse.contentLength ?? 0;
          int downloadedBytes = 0;

          // Stream the response to file with progress tracking
          await for (final chunk in streamedResponse.stream) {
            sink.add(chunk);
            downloadedBytes += chunk.length;

            // Update progress if we know the total size
            if (totalBytes > 0) {
              final progress = downloadedBytes / totalBytes;
              setState(() {
                _downloadProgress = progress;
              });
            }
          }

          await sink.close();
          client.close();

          setState(() {
            _downloadState = DownloadState.downloaded;
            _downloadProgress = 1.0;
            _localFilePath = localPath;
          });

          // Notify parent widget about download completion
          widget.onDownloadComplete?.call(localPath);
        } else {
          client.close();
          throw Exception('Could not create local file path');
        }
      } else {
        client.close();
        throw Exception(
          'Failed to download file: ${streamedResponse.statusCode}',
        );
      }
    } catch (e) {
      print('Error downloading audio file: $e');
      setState(() {
        _downloadState = DownloadState.error;
        _downloadProgress = 0.0;
      });
    }
  }

  Future<void> _playAudio() async {
    try {
      if (_downloadState == DownloadState.notDownloaded) {
        await _downloadAudioFile();
        return;
      }

      if (_downloadState == DownloadState.downloading) {
        return; // Wait for download to complete
      }

      if (_downloadState == DownloadState.error) {
        await _downloadAudioFile();
        return;
      }

      if (_downloadState == DownloadState.downloaded &&
          _localFilePath != null) {
        await _audioPlayer.play(DeviceFileSource(_localFilePath!));
      } else if (widget.fileUrl != null) {
        await _audioPlayer.play(UrlSource(widget.fileUrl!));
      }
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  Future<void> _pauseAudio() async {
    await _audioPlayer.pause();
  }

  Future<void> _seekTo(Duration position) async {
    await _audioPlayer.seek(position);
  }

  Widget _buildPlayButton() {
    switch (_downloadState) {
      case DownloadState.downloading:
        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color:
                widget.isMe
                    ? Colors.white.withOpacity(0.2)
                    : Colors.orange[100],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: _downloadProgress,
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  widget.isMe ? Colors.white : Colors.orange[600]!,
                ),
              ),
              if (_downloadProgress >
                  0.1) // Only show percentage after some progress
                Text(
                  '${(_downloadProgress * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: widget.isMe ? Colors.white : Colors.orange[600]!,
                  ),
                ),
            ],
          ),
        );

      case DownloadState.notDownloaded:
        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            _downloadAudioFile();
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color:
                  widget.isMe
                      ? Colors.white.withOpacity(0.2)
                      : Colors.orange[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.download_rounded,
              color: widget.isMe ? Colors.white : Colors.orange[600],
              size: 20,
            ),
          ),
        );

      case DownloadState.error:
        return GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            _downloadAudioFile();
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color:
                  widget.isMe ? Colors.white.withOpacity(0.2) : Colors.red[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.error_outline,
              color: widget.isMe ? Colors.white : Colors.red[600],
              size: 20,
            ),
          ),
        );

      case DownloadState.downloaded:
        return GestureDetector(
          onTap: _isPlaying ? _pauseAudio : _playAudio,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color:
                  widget.isMe
                      ? Colors.white.withOpacity(0.2)
                      : Colors.orange[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: widget.isMe ? Colors.white : Colors.orange[600],
              size: 20,
            ),
          ),
        );
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: widget.isMe ? Colors.orange[600] : Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Play/Pause/Download button
          _buildPlayButton(),

          const SizedBox(width: 12),

          // Waveform visualization
          Expanded(
            child: Column(
              children: [
                // Waveform bars
                SizedBox(
                  height: 20,
                  child: CustomPaint(
                    painter: AudioWaveformPainter(
                      waveformData: _waveformData,
                      progress:
                          _totalDuration.inMilliseconds > 0
                              ? _currentPosition.inMilliseconds /
                                  _totalDuration.inMilliseconds
                              : 0.0,
                      isMe: widget.isMe,
                    ),
                    size: const Size(double.infinity, 20),
                  ),
                ),
                const SizedBox(height: 4),
                // Progress slider
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 6,
                    ),
                    trackHeight: 2,
                    activeTrackColor:
                        widget.isMe ? Colors.white : Colors.orange[600],
                    inactiveTrackColor:
                        widget.isMe
                            ? Colors.white.withOpacity(0.3)
                            : Colors.orange[200],
                    thumbColor: widget.isMe ? Colors.white : Colors.orange[600],
                  ),
                  child: Slider(
                    value:
                        _totalDuration.inMilliseconds > 0
                            ? _currentPosition.inMilliseconds /
                                _totalDuration.inMilliseconds
                            : 0.0,
                    onChanged: (value) {
                      final position = Duration(
                        milliseconds:
                            (value * _totalDuration.inMilliseconds).round(),
                      );
                      _seekTo(position);
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Duration display
          Text(
            _formatDuration(_totalDuration),
            style: TextStyle(
              fontSize: 12,
              color:
                  widget.isMe
                      ? Colors.white.withOpacity(0.8)
                      : Colors.grey[600]!,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class AudioWaveformPainter extends CustomPainter {
  final List<double> waveformData;
  final double progress;
  final bool isMe;

  AudioWaveformPainter({
    required this.waveformData,
    required this.progress,
    required this.isMe,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    final barWidth = size.width / waveformData.length;
    final centerY = size.height / 2;

    for (int i = 0; i < waveformData.length; i++) {
      final barHeight = waveformData[i] * size.height * 0.8;
      final x = i * barWidth;
      final y = centerY - barHeight / 2;

      // Determine color based on progress
      if (i / waveformData.length <= progress) {
        paint.color = isMe ? Colors.white : Colors.orange[600]!;
      } else {
        paint.color =
            isMe ? Colors.white.withOpacity(0.3) : Colors.orange[200]!;
      }

      canvas.drawRect(Rect.fromLTWH(x + 1, y, barWidth - 2, barHeight), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
