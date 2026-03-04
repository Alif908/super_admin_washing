part of 'dashboard.dart';

mixin _DownloadReportMixin<T extends StatefulWidget> on State<T> {
  Future<void> _downloadFullReport() async {
    try {
      // ── Fetch live wash history from API ───────────────────────────
      final raw = await SuperAdminService.getAllWashHistory();

      List<WashHistoryModel> history = [];
      if (raw['success'] == true) {
        history = (raw['data'] as List? ?? [])
            .map((e) => WashHistoryModel.fromJson(e))
            .toList();
      }

      if (history.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No wash history available to export.'),
              backgroundColor: _red,
            ),
          );
        }
        return;
      }

      // ── Build CSV from live data ───────────────────────────────────
      const headers = [
        'Order ID',
        'Device ID',
        'Device Name',
        'Hub',
        'User',
        'Amount',
        'Date',
      ];

      final csvBuffer = StringBuffer();
      csvBuffer.writeln(headers.map(_csvEscape).join(','));

      for (final w in history) {
        final row = [
          '${w.id}',
          w.device?.deviceId ?? '-',
          w.device?.deviceName ?? '-',
          w.hub?.hubName ?? '-',
          w.user?.name ?? '-',
          w.finalAmount != null ? w.finalAmount!.toStringAsFixed(2) : '0.00',
          w.createdAt ?? '-',
        ];
        csvBuffer.writeln(row.map(_csvEscape).join(','));
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
        saveDir = Directory('/storage/emulated/0/Download');
        if (!await saveDir.exists()) {
          saveDir = await getExternalStorageDirectory();
        }
      } else if (Platform.isIOS) {
        saveDir = await getApplicationDocumentsDirectory();
      } else {
        saveDir = await getTemporaryDirectory();
      }

      final file = File('${saveDir!.path}/$fileName');
      await file.writeAsString(csvString);

      debugPrint('✅ [REPORT] saved ${history.length} rows → ${file.path}');

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
      debugPrint('❌ [REPORT] $e');
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
