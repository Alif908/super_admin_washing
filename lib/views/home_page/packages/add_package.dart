part of '../dashboard.dart';

mixin _AddPackageMixin<T extends StatefulWidget> on State<T> {
  /// [onAdd] is called with the new package map when the user taps "Add Package".
  void _showAddPackageDialog(
    BuildContext ctx,
    double ssz, {
    required ValueChanged<Map<String, String>> onAdd,
  }) {
    final nameCtrl   = TextEditingController();
    final descCtrl   = TextEditingController();
    final priceCtrl  = TextEditingController();
    final statusCtrl = TextEditingController();
    final sw = MediaQuery.of(ctx).size.width;

    showDialog(
      context: ctx,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (_) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) {
          // Local error strings
          String? nameErr;
          String? priceErr;

          void submit() {
            // ── Validate ───────────────────────────────────────
            final name  = nameCtrl.text.trim();
            final price = priceCtrl.text.trim();

            nameErr  = name.isEmpty  ? 'Package name is required' : null;
            priceErr = price.isEmpty
                ? 'Price is required'
                : (double.tryParse(price) == null ? 'Enter a valid number' : null);

            setDialogState(() {}); // Refresh error display

            if (nameErr != null || priceErr != null) return;

            // ── Build the new package map ──────────────────────
            final newPkg = <String, String>{
              'name':  name,
              'desc':  descCtrl.text.trim(),
              'price': double.parse(price).toStringAsFixed(2),
              'code':  statusCtrl.text.trim(),
            };

            onAdd(newPkg); // ✅ Notify dashboard to add to list

            Navigator.pop(dialogCtx);

            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(
                content: const Text(
                  '✅  Package added successfully',
                  style: TextStyle(fontFamily: 'Poppins'),
                ),
                backgroundColor: const Color(0xFF00E676),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                duration: const Duration(seconds: 2),
              ),
            );
          }

          return Dialog(
            backgroundColor: _card,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            insetPadding:
                EdgeInsets.symmetric(horizontal: sw * 0.05, vertical: 40),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ──────────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Add New Package',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: ssz + 4,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(dialogCtx),
                        child: const Icon(Icons.close,
                            color: Colors.white, size: 22),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),

                  // ── Row 1: Name + Description ────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _DLabel('Package Name *', ssz),
                            const SizedBox(height: 6),
                            _DField(controller: nameCtrl, ssz: ssz),
                            if (nameErr != null) ...[
                              const SizedBox(height: 4),
                              _DError(nameErr!),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _DLabel('Description', ssz),
                            const SizedBox(height: 6),
                            _DField(
                                controller: descCtrl,
                                ssz: ssz,
                                maxLines: 3),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // ── Row 2: Price + Status Code ───────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _DLabel('Price (₹) *', ssz),
                            const SizedBox(height: 6),
                            _DField(
                              controller: priceCtrl,
                              ssz: ssz,
                              keyboardType: TextInputType.number,
                            ),
                            if (priceErr != null) ...[
                              const SizedBox(height: 4),
                              _DError(priceErr!),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _DLabel('Status Code', ssz),
                            const SizedBox(height: 6),
                            _DField(controller: statusCtrl, ssz: ssz),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),

                  // ── Submit ───────────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE53935),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      child: Text(
                        'Add Package',
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
          );
        },
      ),
    );
  }
}

// ── Dialog helper widgets ─────────────────────────────────────────────────────
class _DLabel extends StatelessWidget {
  final String text;
  final double ssz;
  const _DLabel(this.text, this.ssz);
  @override
  Widget build(BuildContext context) => Text(
        text,
        style: TextStyle(
            color: Colors.white,
            fontSize: ssz,
            fontWeight: FontWeight.w500),
      );
}

class _DField extends StatelessWidget {
  final TextEditingController controller;
  final double ssz;
  final int maxLines;
  final TextInputType keyboardType;
  const _DField({
    required this.controller,
    required this.ssz,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
  });
  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
            color: _field, borderRadius: BorderRadius.circular(10)),
        child: TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: TextStyle(color: Colors.white, fontSize: ssz),
          decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding:
                EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      );
}

class _DError extends StatelessWidget {
  final String text;
  const _DError(this.text);
  @override
  Widget build(BuildContext context) => Row(
        children: [
          const Icon(Icons.error_outline, color: Color(0xFFFF5252), size: 12),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
                  color: Color(0xFFFF5252),
                  fontSize: 10,
                  fontFamily: 'Poppins'),
            ),
          ),
        ],
      );
}