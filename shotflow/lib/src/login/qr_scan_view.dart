import 'package:flutter/material.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class QRViewScreen extends StatefulWidget {
  const QRViewScreen({super.key});

  @override
  State<QRViewScreen> createState() => _QRViewScreenState();
}

class _QRViewScreenState extends State<QRViewScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  bool scanned = false;
  QRViewController? controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.scanQRTitle),
      ),
      body: Expanded(
        child: QRView(
          overlay: QrScannerOverlayShape(
            borderColor: Colors.white,
            borderRadius: 16,
            cutOutSize: 300,
            overlayColor: Colors.black.withAlpha(200),
          ),
          key: qrKey,
          onQRViewCreated: _onQRViewCreated,
        ),
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (!scanned && context.mounted) {
        Navigator.of(context).pop(scanData.code);
      }
      scanned = true;
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
