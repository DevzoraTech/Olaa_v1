// Presentation Layer - Voice Recording Widget
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'dart:async';
import 'dart:math';

class VoiceRecordingWidget extends StatefulWidget {
  final Function(File, String, int)? onVoiceRecorded;
  final VoidCallback? onCancel;

  const VoiceRecordingWidget({super.key, this.onVoiceRecorded, this.onCancel});

  @override
  State<VoiceRecordingWidget> createState() => _VoiceRecordingWidgetState();
}

class _VoiceRecordingWidgetState extends State<VoiceRecordingWidget>
    with TickerProviderStateMixin {
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  bool _isPaused = false;
  Duration _recordingDuration = Duration.zero;
  Timer? _recordingTimer;
  String? _recordingPath;
  List<double> _waveformData = [];
  late AnimationController _waveformController;
  late Animation<double> _waveformAnimation;

  @override
  void initState() {
    super.initState();
    _waveformController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _waveformAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _waveformController, curve: Curves.easeInOut),
    );

    // Start recording automatically when widget is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startRecording();
    });
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _waveformController.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  Future<void> _startRecording() async {
    try {
      // Request microphone permission
      final permission = await Permission.microphone.request();
      if (!permission.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Microphone permission is required for voice recording',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Check if recorder is available
      final isAvailable = await _audioRecorder.isRecording();
      if (isAvailable) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Recorder is already in use'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Start recording
      final hasPermission = await _audioRecorder.hasPermission();
      if (hasPermission) {
        final path = await _getRecordingPath();
        final config = const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        );

        await _audioRecorder.start(config, path: path);

        print('Recording started at path: $path');

        // Verify recording actually started
        final isActuallyRecording = await _audioRecorder.isRecording();
        print('Is actually recording: $isActuallyRecording');

        setState(() {
          _isRecording = true;
          _recordingPath = path;
          _recordingDuration = Duration.zero;
        });

        // Start timer immediately
        _startTimer();
        _startWaveformAnimation();

        // Show recording started feedback
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Recording started'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No microphone permission'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error starting recording: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Recording error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _stopRecording() async {
    try {
      print(
        'Stopping recording... Duration: ${_recordingDuration.inMilliseconds}ms',
      );
      final recordingPath = await _audioRecorder.stop();
      print('Recording stopped. Path: $recordingPath');

      _recordingTimer?.cancel();
      _waveformController.stop();

      // Use the returned path or fallback to stored path
      final finalPath = recordingPath ?? _recordingPath;
      print('Final path: $finalPath');

      if (finalPath != null && _recordingDuration.inMilliseconds > 500) {
        // At least 0.5 seconds
        final file = File(finalPath);
        final exists = await file.exists();
        print('File exists: $exists');

        if (exists) {
          final fileSize = await file.length();
          final fileName = 'voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
          print('File size: $fileSize bytes');

          // Show success feedback
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Recording saved: ${(fileSize / 1024).toStringAsFixed(1)} KB (${_formatDuration(_recordingDuration)})',
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );

          widget.onVoiceRecorded?.call(file, fileName, fileSize);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Recording file not found'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Recording too short (${_formatDuration(_recordingDuration)}) or failed',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }

      setState(() {
        _isRecording = false;
        _isPaused = false;
        _recordingDuration = Duration.zero;
        _recordingPath = null;
        _waveformData.clear();
      });
    } catch (e) {
      print('Error stopping recording: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error stopping recording: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _cancelRecording() async {
    try {
      await _audioRecorder.cancel();
      _recordingTimer?.cancel();
      _waveformController.stop();

      // Delete the recording file if it exists
      if (_recordingPath != null) {
        final file = File(_recordingPath!);
        if (await file.exists()) {
          await file.delete();
        }
      }

      setState(() {
        _isRecording = false;
        _isPaused = false;
        _recordingDuration = Duration.zero;
        _recordingPath = null;
        _waveformData.clear();
      });

      widget.onCancel?.call();
    } catch (e) {
      print('Error canceling recording: $e');
    }
  }

  void _startTimer() {
    print('Starting timer...');
    _recordingTimer?.cancel(); // Cancel any existing timer
    _recordingTimer = Timer.periodic(const Duration(milliseconds: 100), (
      timer,
    ) {
      if (_isRecording && mounted) {
        setState(() {
          _recordingDuration = Duration(
            milliseconds: _recordingDuration.inMilliseconds + 100,
          );
        });
        print('Timer tick: ${_recordingDuration.inMilliseconds}ms');
      } else {
        print('Timer stopping - isRecording: $_isRecording, mounted: $mounted');
        timer.cancel();
      }
    });
  }

  void _startWaveformAnimation() {
    _waveformController.repeat();
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!_isRecording) {
        timer.cancel();
        return;
      }

      // Get real audio amplitude data from the recorder
      _audioRecorder
          .onAmplitudeChanged(const Duration(milliseconds: 100))
          .listen((amplitude) {
            if (_isRecording && mounted) {
              // Convert amplitude to a 0-1 range for visualization
              final normalizedAmplitude =
                  (amplitude.current + 80) / 80; // Normalize from -80 to 0 dB
              final clampedAmplitude = normalizedAmplitude.clamp(0.0, 1.0);

              _waveformData.add(clampedAmplitude);

              // Keep only last 50 data points for performance
              if (_waveformData.length > 50) {
                _waveformData.removeAt(0);
              }

              setState(() {});
            }
          });
    });
  }

  Future<String> _getRecordingPath() async {
    final directory = Directory.systemTemp;
    final fileName = 'voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
    return '${directory.path}/$fileName';
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
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.red, width: 2),
      ),
      child: Row(
        children: [
          // Cancel button
          GestureDetector(
            onTap: _cancelRecording,
            child: Container(
              width: 50,
              height: 50,
              margin: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 24),
            ),
          ),

          // Waveform visualization
          Expanded(
            child: Container(
              height: 40,
              margin: const EdgeInsets.symmetric(horizontal: 10),
              child: _buildWaveform(),
            ),
          ),

          // Duration display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              _formatDuration(_recordingDuration),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Stop/Send button
          GestureDetector(
            onTap: _stopRecording,
            child: Container(
              width: 50,
              height: 50,
              margin: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(25),
              ),
              child: const Icon(Icons.send, color: Colors.white, size: 24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaveform() {
    if (_waveformData.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey[700],
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: Text(
            'Recording...',
            style: TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      );
    }

    return CustomPaint(
      painter: WaveformPainter(_waveformData),
      size: Size.infinite,
    );
  }
}

class WaveformPainter extends CustomPainter {
  final List<double> waveformData;
  final Paint _paint =
      Paint()
        ..color = Colors.white
        ..strokeWidth = 2
        ..style = PaintingStyle.fill;

  WaveformPainter(this.waveformData);

  @override
  void paint(Canvas canvas, Size size) {
    if (waveformData.isEmpty) return;

    final centerY = size.height / 2;
    final barWidth = size.width / waveformData.length;

    for (int i = 0; i < waveformData.length; i++) {
      final amplitude = waveformData[i];
      final barHeight = amplitude * size.height * 0.8;
      final x = i * barWidth;

      canvas.drawRect(
        Rect.fromLTWH(x, centerY - barHeight / 2, barWidth * 0.8, barHeight),
        _paint,
      );
    }
  }

  @override
  bool shouldRepaint(WaveformPainter oldDelegate) {
    return oldDelegate.waveformData != waveformData;
  }
}
