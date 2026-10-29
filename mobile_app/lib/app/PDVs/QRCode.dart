import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({Key? key}) : super(key: key);

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final MobileScannerController controller = MobileScannerController();
  bool isScanned = false;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Scan Your QR Code',
          style: TextStyle(
            fontSize: 24,
            color: Colors.white,
            fontStyle: FontStyle.normal,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: controller,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty && !isScanned) {
                final Barcode barcode = barcodes.first;
                if (barcode.rawValue != null) {
                  setState(() {
                    isScanned = true;
                  });
                  
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                      contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                      title: const Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color:  Color(0xFF2DB34B),
                            size: 28,
                          ),
                           SizedBox(width: 10),
                           Text(
                            'QR Code Scanned',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      content: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Scanned Data:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              '${barcode.rawValue}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "Thank's for doing your work!",
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Color(0xFF2DB34B),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pop(context, true); // Return true to indicate successful scan
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF2DB34B),
                          ),
                          child: const Text(
                            'OK',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
              }
            },
          ),
          
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white,
                  width: 2.0,
                ),
              ),
            ),
          ),
          
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  if (isScanned) {
                    setState(() {
                      isScanned = false;
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2DB34B),
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.qr_code_scanner,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      isScanned ? 'Scan Again' : 'Scan QR Code',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}