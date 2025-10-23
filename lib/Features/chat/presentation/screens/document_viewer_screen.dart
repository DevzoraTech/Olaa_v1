// Presentation Layer - Document Viewer Screen
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class DocumentViewerScreen extends StatefulWidget {
  final String? fileUrl;
  final String? localFilePath;
  final String fileName;
  final bool isMe;

  const DocumentViewerScreen({
    super.key,
    this.fileUrl,
    this.localFilePath,
    required this.fileName,
    required this.isMe,
  });

  @override
  State<DocumentViewerScreen> createState() => _DocumentViewerScreenState();
}

class _DocumentViewerScreenState extends State<DocumentViewerScreen> {
  PdfController? _pdfController;
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  int _currentPage = 1;
  String? _fileContent; // For text files
  String? _filePath; // Local file path

  @override
  void initState() {
    super.initState();
    _initializeDocument();
  }

  @override
  void dispose() {
    _pdfController?.dispose();
    super.dispose();
  }

  Future<void> _initializeDocument() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
        _errorMessage = null;
      });

      String? filePath;
      final fileExtension = widget.fileName.split('.').last.toLowerCase();

      // Try local file first
      if (widget.localFilePath != null) {
        final localFile = File(widget.localFilePath!);
        if (await localFile.exists()) {
          print(
            'DEBUG: Loading document from local path: ${widget.localFilePath}',
          );
          filePath = widget.localFilePath;
        } else {
          print('DEBUG: Local file does not exist: ${widget.localFilePath}');
        }
      }

      // If no local file, try to download from URL
      if (filePath == null && widget.fileUrl != null) {
        print('DEBUG: Downloading document from URL: ${widget.fileUrl}');
        filePath = await _downloadDocumentFromUrl(widget.fileUrl!);
      }

      // Check if we have a valid file path
      if (filePath == null || !await File(filePath).exists()) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Document file not found or could not be downloaded';
          _isLoading = false;
        });
        return;
      }

      _filePath = filePath;

      // Handle different file types
      if (fileExtension == 'pdf') {
        await _loadPdfDocument(filePath);
      } else if (_isTextFile(fileExtension)) {
        await _loadTextDocument(filePath);
      } else {
        // For other document types (docx, xlsx, etc.), show a message
        setState(() {
          _hasError = true;
          _errorMessage =
              'This document type (.$fileExtension) is not supported for viewing. You can download it to view with an external app.';
          _isLoading = false;
        });
      }
    } catch (e) {
      print('DEBUG: Error in _initializeDocument: $e');
      setState(() {
        _hasError = true;
        _errorMessage = 'Error loading document: $e';
        _isLoading = false;
      });
    }
  }

  bool _isTextFile(String extension) {
    const textExtensions = [
      'txt',
      'md',
      'json',
      'xml',
      'csv',
      'log',
      'ini',
      'cfg',
    ];
    return textExtensions.contains(extension);
  }

  Future<void> _loadPdfDocument(String filePath) async {
    try {
      final document = await PdfDocument.openFile(filePath);
      print('DEBUG: PDF document opened successfully');

      _pdfController = PdfController(document: Future.value(document));
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('DEBUG: Error opening PDF file: $e');
      setState(() {
        _hasError = true;
        _errorMessage = 'Error opening PDF file: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadTextDocument(String filePath) async {
    try {
      final file = File(filePath);
      final content = await file.readAsString();
      print('DEBUG: Text document loaded successfully');

      setState(() {
        _fileContent = content;
        _isLoading = false;
      });
    } catch (e) {
      print('DEBUG: Error reading text file: $e');
      setState(() {
        _hasError = true;
        _errorMessage = 'Error reading text file: $e';
        _isLoading = false;
      });
    }
  }

  Future<String?> _downloadDocumentFromUrl(String url) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final documentsDir = Directory('${directory.path}/documents');
      if (!await documentsDir.exists()) {
        await documentsDir.create(recursive: true);
      }

      final fileName =
          widget.fileName ??
          'document_${DateTime.now().millisecondsSinceEpoch}';
      final filePath = '${documentsDir.path}/$fileName';
      final file = File(filePath);

      // Download the file
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);
        print('DEBUG: Document downloaded to: $filePath');
        return filePath;
      } else {
        print('DEBUG: Failed to download document: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('DEBUG: Error downloading document: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          widget.fileName,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        actions: [
          if (_pdfController != null) ...[
            // Page counter
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '$_currentPage / ${_pdfController!.pagesCount}',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ),
            // Share button
            IconButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Share functionality coming soon'),
                    backgroundColor: Colors.blue,
                  ),
                );
              },
              icon: const Icon(Icons.share),
            ),
          ],
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(height: 16),
            Text(
              widget.fileUrl != null && widget.localFilePath == null
                  ? 'Downloading document...'
                  : 'Loading document...',
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red[400], size: 64),
            const SizedBox(height: 16),
            Text(
              _errorMessage ?? 'Unknown error',
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[600],
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Go Back'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    _initializeDocument(); // Retry loading
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ],
        ),
      );
    }

    // Show PDF viewer if it's a PDF
    if (_pdfController != null) {
      return PdfView(
        controller: _pdfController!,
        scrollDirection: Axis.vertical,
        renderer:
            (PdfPage page) => page.render(
              width: page.width * 2,
              height: page.height * 2,
              format: PdfPageImageFormat.png,
              backgroundColor: '#FFFFFF',
            ),
        onDocumentLoaded: (document) {
          print('PDF loaded: ${document.pagesCount} pages');
        },
        onPageChanged: (page) {
          setState(() {
            _currentPage = page;
          });
          print('Page changed to: $page');
        },
        onDocumentError: (error) {
          setState(() {
            _hasError = true;
            _errorMessage = 'Error loading PDF: $error';
          });
        },
      );
    }

    // Show text viewer if it's a text file
    if (_fileContent != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: SelectableText(
            _fileContent!,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontFamily: 'monospace',
            ),
          ),
        ),
      );
    }

    // Show unsupported document type message
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.description_outlined, color: Colors.orange[400], size: 64),
          const SizedBox(height: 16),
          Text(
            'Document Type Not Supported',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'This document type cannot be viewed in-app. You can download it to view with an external app.',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement download functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Download functionality coming soon'),
                  backgroundColor: Colors.blue,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[600],
              foregroundColor: Colors.white,
            ),
            child: const Text('Download'),
          ),
        ],
      ),
    );
  }
}
