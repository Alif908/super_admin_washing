part of 'dashboard.dart';

mixin _DownloadReportMixin<T extends StatefulWidget> on State<T> {
  // ── Sample transaction data (replace with your real data source) ──────
  final List<Map<String, String>> _transactions = const [
    {
      'Order ID': '2',
      'Device ID': 'DEV001',
      'Device Name': 'Pressure Washer Pro 4000',
      'Hub': 'Calicut Express Wash Hub',
      'User': 'User A',
      'Amount': '180',
      'Status': 'Completed',
      'Date': '2026-02-27',
    },
    {
      'Order ID': '1',
      'Device ID': 'DEV001',
      'Device Name': 'Pressure Washer Pro 4000',
      'Hub': 'Calicut Express Wash Hub',
      'User': 'User A',
      'Amount': '180',
      'Status': 'Completed',
      'Date': '2026-02-20',
    },
  ];

  Future<void> _downloadFullReport() async {
    try {
      // ── Build CSV ──────────────────────────────────────────────────
      final headers = _transactions.first.keys.toList();
      final csvBuffer = StringBuffer();
      csvBuffer.writeln(headers.map(_csvEscape).join(','));
      for (final row in _transactions) {
        csvBuffer.writeln(
          headers.map((h) => _csvEscape(row[h] ?? '')).join(','),
        );
      }
      final csvString = csvBuffer.toString();

      // ── Resolve save path ──────────────────────────────────────────
      final timestamp = DateTime.now()
          .toIso8601String()
          .replaceAll(':', '-')
          .substring(0, 19);
      final fileName = 'fleet_report_$timestamp.csv';

      Directory? saveDir;

      if (Platform.isAndroid) {
        // Android: save directly to /storage/emulated/0/Download
        saveDir = Directory('/storage/emulated/0/Download');
        if (!await saveDir.exists()) {
          // Fallback to app external storage if Download not accessible
          saveDir = await getExternalStorageDirectory();
        }
      } else if (Platform.isIOS) {
        // iOS: save to app Documents folder (visible in Files app)
        saveDir = await getApplicationDocumentsDirectory();
      } else {
        saveDir = await getTemporaryDirectory();
      }

      final file = File('${saveDir!.path}/$fileName');
      await file.writeAsString(csvString);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: _green,
            duration: const Duration(seconds: 4),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '✅ Report saved successfully!',
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  Platform.isAndroid
                      ? 'Check your Downloads folder\n$fileName'
                      : 'Saved to Files app\n$fileName',
                  style: const TextStyle(color: Colors.black87, fontSize: 11),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e'), backgroundColor: _red),
        );
      }
    }
  }

  String _csvEscape(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }
}
