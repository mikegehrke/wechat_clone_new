import 'package:flutter/material.dart';
import 'dart:math';

class QRPaymentWidget extends StatefulWidget {
  final String userId;
  final String userName;
  final double? balance;
  final Function(String)? onQRScanned;
  final Function()? onGenerateQR;

  const QRPaymentWidget({
    super.key,
    required this.userId,
    required this.userName,
    this.balance,
    this.onQRScanned,
    this.onGenerateQR,
  });

  @override
  State<QRPaymentWidget> createState() => _QRPaymentWidgetState();
}

class _QRPaymentWidgetState extends State<QRPaymentWidget> {
  String? _qrCodeData;
  bool _isGenerating = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Icon(
                    Icons.qr_code,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'QR Code Payment',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Scan to pay or receive money',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.balance != null)
                  Text(
                    '\$${widget.balance!.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
              ],
            ),
          ),
          
          // QR Code section
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // QR Code display
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: _qrCodeData != null
                      ? _buildQRCode(_qrCodeData!)
                      : _buildQRCodePlaceholder(),
                ),
                
                const SizedBox(height: 16),
                
                // User info
                Text(
                  widget.userName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                Text(
                  'ID: ${widget.userId}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isGenerating ? null : _generateQRCode,
                        icon: _isGenerating
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.qr_code_2),
                        label: Text(_isGenerating ? 'Generating...' : 'Generate QR'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _scanQRCode,
                        icon: const Icon(Icons.qr_code_scanner),
                        label: const Text('Scan QR'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Instructions
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Colors.blue,
                        size: 24,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'How to use QR Payment:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '• Generate QR: Show your QR code to receive payments\n'
                        '• Scan QR: Scan someone else\'s QR to send money\n'
                        '• Universal: Works with any QR payment system',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQRCode(String data) {
    // In a real app, you would use a QR code generation library
    // For now, we'll create a simple visual representation
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Simulated QR code pattern
          ...List.generate(8, (row) => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(8, (col) => Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.all(1),
              decoration: BoxDecoration(
                color: Random().nextBool() ? Colors.black : Colors.white,
                borderRadius: BorderRadius.circular(1),
              ),
            )),
          )),
          const SizedBox(height: 8),
          Text(
            'QR Code',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQRCodePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.qr_code_2,
          size: 64,
          color: Colors.grey[400],
        ),
        const SizedBox(height: 8),
        Text(
          'Generate QR Code',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        Text(
          'Tap the button below',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  void _generateQRCode() {
    setState(() {
      _isGenerating = true;
    });

    // Simulate QR code generation
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _qrCodeData = 'PAYMENT_QR:${widget.userId}:${DateTime.now().millisecondsSinceEpoch}';
        _isGenerating = false;
      });

      if (widget.onGenerateQR != null) {
        widget.onGenerateQR!();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('QR Code generated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  void _scanQRCode() {
    // In a real app, you would use a QR code scanner
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Scan QR Code'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.qr_code_scanner,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Camera Scanner',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  Text(
                    'Point camera at QR code',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'QR Scanner will be available in the next update!',
              style: TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Simulate scanning a QR code
              _simulateQRScan();
            },
            child: const Text('Simulate Scan'),
          ),
        ],
      ),
    );
  }

  void _simulateQRScan() {
    final mockQRData = 'PAYMENT_QR:user_123:${DateTime.now().millisecondsSinceEpoch}';
    
    if (widget.onQRScanned != null) {
      widget.onQRScanned!(mockQRData);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('QR Code scanned: $mockQRData'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}