part of 'dashboard.dart';

mixin _AddDeviceMixin<T extends StatefulWidget> on State<T> {
  void _showAddDeviceDialog(BuildContext ctx, double ssz) {
    final deviceIdCtrl = TextEditingController();
    final sw = MediaQuery.of(ctx).size.width;

    showDialog(
      context: ctx,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (_) => Dialog(
        backgroundColor: _card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: EdgeInsets.symmetric(horizontal: sw * 0.05, vertical: 40),
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
                    onTap: () => Navigator.pop(ctx),
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
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE53935),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
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
    );
  }
}
