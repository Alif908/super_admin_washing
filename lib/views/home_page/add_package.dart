part of 'dashboard.dart';

mixin _AddPackageMixin<T extends StatefulWidget> on State<T> {
  void _showAddPackageDialog(BuildContext ctx, double ssz) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final statusCtrl = TextEditingController();
    final sw = MediaQuery.of(ctx).size.width;

    showDialog(
      context: ctx,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (_) => Dialog(
        backgroundColor: _card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: EdgeInsets.symmetric(horizontal: sw * 0.05, vertical: 40),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _DLabel('Package Name', ssz),
                        const SizedBox(height: 6),
                        _DField(controller: nameCtrl, ssz: ssz),
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
                        _DField(controller: descCtrl, ssz: ssz, maxLines: 3),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _DLabel('Price', ssz),
                        const SizedBox(height: 6),
                        _DField(
                          controller: priceCtrl,
                          ssz: ssz,
                          keyboardType: TextInputType.number,
                        ),
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
      fontWeight: FontWeight.w500,
    ),
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
      color: _field,
      borderRadius: BorderRadius.circular(10),
    ),
    child: TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: TextStyle(color: Colors.white, fontSize: ssz),
      decoration: const InputDecoration(
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    ),
  );
}
