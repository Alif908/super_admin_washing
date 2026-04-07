part of 'dashboard.dart';

mixin _AddDeviceMixin<T extends StatefulWidget> on State<T> {
  /// ── ADD ──────────────────────────────────────────────────────────────────
  void _showAddDeviceDialog(
    BuildContext ctx,
    double ssz, {
    required void Function(Map<String, String>) onAdd,
  }) {
    showEditDeviceDialog(ctx, existing: null, onSave: onAdd);
  }

  /// ── EDIT / ADD (core dialog) ──────────────────────────────────────────
  /// • existing == null  → "Add Device" mode  (shows Device ID field only)
  /// • existing != null  → "Edit Device" mode (shows Name + Condition fields)
  void showEditDeviceDialog(
    BuildContext ctx, {
    Map<String, String>? existing,
    required void Function(Map<String, String>) onSave,
  }) {
    final isEdit = existing != null;

    final deviceIdCtrl = TextEditingController(
      text: existing?['deviceId'] ?? '',
    );
    final deviceNameCtrl = TextEditingController(
      text: existing?['deviceName'] ?? '',
    );
    final conditionCtrl = TextEditingController(
      text: existing?['condition'] ?? '',
    );

    final sw = MediaQuery.of(ctx).size.width;
    final ssz = sw < 360
        ? 11.0
        : sw < 400
        ? 12.0
        : 13.0;

    showDialog(
      context: ctx,
      barrierColor: Colors.black.withOpacity(0.75),
      builder: (_) => Dialog(
        backgroundColor: const Color(0xFF111827),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: EdgeInsets.symmetric(horizontal: sw * 0.05, vertical: 60),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Title row ────────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isEdit ? 'Edit Device' : 'Add Device',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.2,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white70,
                      size: 22,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // ── Add mode: single Device ID field ────────────────────
              if (!isEdit) ...[
                _fieldLabel('Device ID', ssz),
                const SizedBox(height: 8),
                _inputBox(
                  controller: deviceIdCtrl,
                  hint: 'Scan or type device ID',
                  ssz: ssz,
                ),
                const SizedBox(height: 24),
              ],

              // ── Edit mode: side-by-side Device Name + Condition ─────
              if (isEdit) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Device Name
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _fieldLabel('Device Name', ssz),
                          const SizedBox(height: 8),
                          _inputBox(
                            controller: deviceNameCtrl,
                            hint: 'Device Name',
                            ssz: ssz,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Condition
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _fieldLabel('Condition', ssz),
                          const SizedBox(height: 8),
                          _inputBox(
                            controller: conditionCtrl,
                            hint: 'Good / Bad',
                            ssz: ssz,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
              ],

              // ── Submit button ────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isEdit ? const Color(0xFFE53935) : _blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    final id = deviceIdCtrl.text.trim();

                    if (!isEdit && id.isEmpty) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(
                          backgroundColor: _red,
                          content: Text('Device ID cannot be empty'),
                        ),
                      );
                      return;
                    }

                    Navigator.pop(ctx);
                    onSave({
                      'deviceId': id,
                      'deviceName': deviceNameCtrl.text.trim(),
                      'condition': conditionCtrl.text.trim(),
                    });
                  },
                  child: Text(
                    isEdit ? 'Update Device' : 'Add Device',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.4,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Shared field helpers ───────────────────────────────────────────────────
Widget _fieldLabel(String text, double ssz) => Text(
  text,
  style: TextStyle(
    color: Colors.white,
    fontSize: ssz,
    fontWeight: FontWeight.w500,
  ),
);

Widget _inputBox({
  required TextEditingController controller,
  required String hint,
  required double ssz,
}) => Container(
  decoration: BoxDecoration(
    color: const Color(0xFF1E2A45),
    borderRadius: BorderRadius.circular(10),
  ),
  child: TextField(
    controller: controller,
    style: TextStyle(color: Colors.white, fontSize: ssz),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: _dim, fontSize: ssz),
      border: InputBorder.none,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    ),
  ),
);
