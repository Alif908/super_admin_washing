part of 'dashboard.dart';

mixin _AddDeviceMixin<T extends StatefulWidget> on State<T> {
  // ── live list of devices ──
  List<DeviceModel> _devices = [];

  // ── fetch all devices ──
  Future<void> _fetchDevices() async {
    try {
      final raw = await SuperAdminService.getAllDevices();
      if (raw['success'] == true) {
        final list = (raw['data'] as List? ?? raw['devices'] as List? ?? [])
            .map((e) => DeviceModel.fromJson(e))
            .toList();
        if (mounted) setState(() => _devices = list);
        debugPrint('✅ [DEVICES] total:${_devices.length}');
      }
    } catch (e) {
      debugPrint('❌ [DEVICES] $e');
    }
  }

  void _showAddDeviceDialog(BuildContext ctx, double ssz) {
    final deviceIdCtrl = TextEditingController();
    final sw = MediaQuery.of(ctx).size.width;

    bool _submitting = false;

    showDialog(
      context: ctx,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (_) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) => Dialog(
          backgroundColor: _card,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          insetPadding:
              EdgeInsets.symmetric(horizontal: sw * 0.05, vertical: 40),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Title row ──────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Add Device',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: ssz + 4,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(dialogCtx),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),

                // ── Device ID field ────────────────────────────────────
                Text(
                  'Device ID',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: ssz,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  decoration: BoxDecoration(
                    color: _field,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: TextField(
                    controller: deviceIdCtrl,
                    style: TextStyle(color: Colors.white, fontSize: ssz),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 22),

                // ── Submit ─────────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _submitting
                        ? null
                        : () async {
                            // ── validation ───────────────────────
                            final deviceId = deviceIdCtrl.text.trim();
                            if (deviceId.isEmpty) {
                              _showDeviceSnack(ctx, 'Device ID is required');
                              return;
                            }

                            // ── call API ─────────────────────────
                            setDialogState(() => _submitting = true);

                            final raw = await SuperAdminService.addDevice(
                              deviceId: deviceId,
                            );

                            setDialogState(() => _submitting = false);

                            if (raw['success'] == true) {
                              await _fetchDevices();
                              if (dialogCtx.mounted) {
                                Navigator.pop(dialogCtx);
                              }
                              _showDeviceSnack(
                                ctx,
                                raw['message'] ?? 'Device added successfully!',
                                success: true,
                              );
                            } else {
                              _showDeviceSnack(
                                ctx,
                                raw['message'] ?? 'Failed to add device',
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _submitting
                          ? Colors.grey
                          : const Color(0xFFE53935),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: _submitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Add Device',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: ssz + 1,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── snackbar helper ──────────────────────────────────────────────────────
  void _showDeviceSnack(BuildContext ctx, String msg, {bool success = false}) {
    if (!ctx.mounted) return;
    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: success ? _green : _red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}