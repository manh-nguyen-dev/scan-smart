import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:scan_smart/utils/snackbar_util.dart';

import '../database/database_helper.dart';
import '../models/scan_model.dart';

class GenerateQRScreen extends StatefulWidget {
  const GenerateQRScreen({super.key});

  @override
  State<GenerateQRScreen> createState() => _GenerateQRScreenState();
}

class _GenerateQRScreenState extends State<GenerateQRScreen> {
  final TextEditingController _controller = TextEditingController();
  String _qrData = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate QR Code'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Enter text to encode',
                border: OutlineInputBorder(),
              ),
              onChanged: (text) {
                setState(() {
                  _qrData = text;
                });
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Center(
                child: _qrData.isNotEmpty
                    ? QrImageView(
                        data: _qrData,
                        version: QrVersions.auto,
                        size: 300.0,
                      )
                    : const Text(
                        'Enter text to generate QR code',
                        style: TextStyle(
                          fontWeight: FontWeight.w300,
                          fontSize: 24,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (_qrData.isNotEmpty) {
                  final qrImage = await _generateQRImage();
                  final scanModel = ScanModel(
                    code: _qrData,
                    timestamp: DateTime.now(),
                    image: qrImage,
                  );
                  await DatabaseHelper().insertScan(scanModel);
                  final result = await _saveImageToGallery(qrImage);
                  if (!context.mounted) return;
                  showSnackBar(context, "Image saved to gallery: $result'");
                }
              },
              child: const Text(
                'Save QR Data',
                style: TextStyle(
                  fontWeight: FontWeight.w300,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<Uint8List> _generateQRImage() async {
    final qrPainter = QrPainter(
      data: _qrData,
      version: QrVersions.auto,
      eyeStyle: const QrEyeStyle(
        color: Colors.black,
      ),
      gapless: false,
    );

    final picData = await qrPainter.toImageData(200);
    return picData!.buffer.asUint8List();
  }

  Future<String> _saveImageToGallery(Uint8List imageBytes) async {
    final result = await ImageGallerySaver.saveImage(imageBytes);
    return result['filePath'];
  }
}
