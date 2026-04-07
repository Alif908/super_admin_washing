part of 'dashboard.dart';

mixin _DownloadReportMixin on State<DashboardScreen> {
  // ── Abstract members that _State must provide ──────────────────────────
  List<WashHistoryModel> get _washHistory;
  String? _deviceStringIdById(int? numericId);
  String? _deviceNameById(int? numericId);
  String _hubNameById(int? id);
  String? _userNameById(int? userId);

  // ── Implementation ─────────────────────────────────────────────────────
  Future<void> _downloadFullReport() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: _blue,
          duration: Duration(seconds: 2),
          content: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
              SizedBox(width: 12),
              Text(
                'Preparing CSV report...',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );

      final List<List<dynamic>> rows = [];
      rows.add([
        'Order ID',
        'Device ID',
        'Device Name',
        'Hub',
        'User',
        'Amount (Rs)',
        'Final Amount (Rs)',
        'Discount (Rs)',
        'Coupon Code',
        'Date & Time',
      ]);

      for (final w in _washHistory) {
        rows.add([
          w.orderId ?? w.id,
          w.device?.deviceId ?? _deviceStringIdById(w.deviceId) ?? '-',
          w.device?.deviceName ??
              _deviceNameById(w.deviceId) ??
              w.packageName ??
              '-',
          w.hub?.hubName ?? _hubNameById(w.hubId),
          w.user?.name ?? _userNameById(w.userId) ?? '-',
          (w.amount ?? 0).toStringAsFixed(2),
          (w.finalAmount ?? w.amount ?? 0).toStringAsFixed(2),
          w.discountAmount.toStringAsFixed(2),
          w.couponCode ?? '-',
          _formatDateCsv(w.createdAt),
        ]);
      }

      final csvData = _convertToCsv(rows);
      final directory = await getTemporaryDirectory();
      final now = DateTime.now();
      final fileName =
          'wash_report_${now.year}${_pad(now.month)}${_pad(now.day)}'
          '_${_pad(now.hour)}${_pad(now.minute)}.csv';
      final file = File('${directory.path}/$fileName');
      await file.writeAsString(csvData, encoding: utf8);

      await Share.shareXFiles([
        XFile(file.path, mimeType: 'text/csv', name: fileName),
      ], subject: 'Wash Fleet Report - ${_formatDateSimple(now)}');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: _red,
            content: Text(
              'Failed to generate report: $e',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
      }
    }
  }

  String _convertToCsv(List<List<dynamic>> rows) {
    final buffer = StringBuffer();
    for (final row in rows) {
      buffer.writeln(
        row
            .map((cell) {
              final v = cell?.toString() ?? '';
              return (v.contains(',') || v.contains('"') || v.contains('\n'))
                  ? '"${v.replaceAll('"', '""')}"'
                  : v;
            })
            .join(','),
      );
    }
    return buffer.toString();
  }

  String _formatDateCsv(String? raw) {
    if (raw == null) return '-';
    try {
      final dt = DateTime.parse(raw).toLocal();
      return '${dt.day}/${dt.month}/${dt.year} '
          '${_pad(dt.hour)}:${_pad(dt.minute)}';
    } catch (_) {
      return raw;
    }
  }

  String _formatDateSimple(DateTime dt) =>
      '${dt.day}-${_pad(dt.month)}-${dt.year}';

  String _pad(int n) => n.toString().padLeft(2, '0');
}
