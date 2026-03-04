part of 'dashboard.dart';

mixin _AddPackageMixin<T extends StatefulWidget> on State<T> {
  // ── live list of packages fetched from API ──
  List<PackageModel> _packages = [];

  // ── fetch all packages and refresh the dashboard list ──
  Future<void> _fetchPackages() async {
    try {
      final raw = await SuperAdminService.getAllPackages();
      if (raw['success'] == true) {
        final response = PackageResponseModel.fromJson(raw);
        if (mounted) setState(() => _packages = response.packages);
        debugPrint('✅ [PACKAGES] total:${_packages.length}');
      }
    } catch (e) {
      debugPrint('❌ [PACKAGES] $e');
    }
  }

  void _showAddPackageDialog(BuildContext ctx, double ssz) {
    final nameCtrl   = TextEditingController();
    final descCtrl   = TextEditingController();
    final priceCtrl  = TextEditingController();
    final statusCtrl = TextEditingController();
    final sw = MediaQuery.of(ctx).size.width;

    // local loading flag lives inside the dialog via StatefulBuilder
    bool _submitting = false;

    showDialog(
      context: ctx,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (_) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) => Dialog(
          backgroundColor: _card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          insetPadding:
              EdgeInsets.symmetric(horizontal: sw * 0.05, vertical: 40),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── header ──────────────────────────────────────────
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
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),

                // ── row 1: name + description ────────────────────────
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
                          _DField(
                            controller: descCtrl,
                            ssz: ssz,
                            maxLines: 3,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // ── row 2: price + status code ───────────────────────
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

                // ── submit button ────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _submitting
                        ? null
                        : () async {
                            // ── validation ──────────────────────
                            final name  = nameCtrl.text.trim();
                            final price = double.tryParse(
                              priceCtrl.text.trim(),
                            );

                            if (name.isEmpty) {
                              _showSnack(ctx, 'Package name is required');
                              return;
                            }
                            if (price == null || price <= 0) {
                              _showSnack(
                                ctx,
                                'Enter a valid price',
                              );
                              return;
                            }

                            // ── call API ─────────────────────────
                            setDialogState(() => _submitting = true);

                            final raw =
                                await SuperAdminService.addPackage(
                              packageName: name,
                              description: descCtrl.text.trim(),
                              price: price,
                              statusCode: statusCtrl.text.trim(),
                            );

                            setDialogState(() => _submitting = false);

                            if (raw['success'] == true) {
                              // refresh package list in dashboard
                              await _fetchPackages();
                              if (dialogCtx.mounted) {
                                Navigator.pop(dialogCtx);
                              }
                              _showSnack(
                                ctx,
                                raw['message'] ??
                                    'Package added successfully!',
                                success: true,
                              );
                            } else {
                              _showSnack(
                                ctx,
                                raw['message'] ?? 'Failed to add package',
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
      ),
    );
  }

  // ── small snackbar helper ───────────────────────────────────────────────
  void _showSnack(BuildContext ctx, String msg, {bool success = false}) {
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