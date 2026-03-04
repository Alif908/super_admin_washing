part of 'dashboard.dart';

mixin _AddCouponMixin<T extends StatefulWidget> on State<T> {
  // ── live list of coupons fetched from API ──
  List<CouponModel> _coupons = [];

  // ── fetch all coupons ──
  Future<void> _fetchCoupons() async {
    try {
      final raw = await SuperAdminService.getAllCoupons();
      if (raw['success'] == true) {
        final list = (raw['data'] as List? ?? raw['coupons'] as List? ?? [])
            .map((e) => CouponModel.fromJson(e))
            .toList();
        if (mounted) setState(() => _coupons = list);
        debugPrint('✅ [COUPONS] total:${_coupons.length}');
      }
    } catch (e) {
      debugPrint('❌ [COUPONS] $e');
    }
  }

  void _showAddCouponDialog(BuildContext ctx, double ssz) {
    final codeCtrl     = TextEditingController();
    final discountCtrl = TextEditingController();
    final maxUsageCtrl = TextEditingController();
    DateTime? _selectedDate;
    final dateCtrl = TextEditingController(text: '');
    final sw = MediaQuery.of(ctx).size.width;

    bool _submitting = false;

    showDialog(
      context: ctx,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (dialogCtx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) => Dialog(
          backgroundColor: _card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          insetPadding: EdgeInsets.symmetric(
            horizontal: sw * 0.05,
            vertical: 40,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Title row ────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Add New Coupon',
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

                // ── Coupon Code / Discount Percentage ────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _CouponField(
                        label: 'Coupon Code',
                        ctrl: codeCtrl,
                        ssz: ssz,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _CouponField(
                        label: 'Discount Percentage (%)',
                        ctrl: discountCtrl,
                        ssz: ssz,
                        kb: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // ── Max Usage Per User / Expiry Date ─────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _CouponField(
                        label: 'Max Usage Per User',
                        ctrl: maxUsageCtrl,
                        ssz: ssz,
                        kb: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Expiry Date',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: ssz,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 6),
                          GestureDetector(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: dialogCtx,
                                initialDate: _selectedDate ?? DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2100),
                                builder: (c, child) => Theme(
                                  data: ThemeData.dark().copyWith(
                                    colorScheme: const ColorScheme.dark(
                                      primary: _blue,
                                      surface: _card,
                                    ),
                                    dialogBackgroundColor: _card,
                                  ),
                                  child: child!,
                                ),
                              );
                              if (picked != null) {
                                setDialogState(() {
                                  _selectedDate = picked;
                                  dateCtrl.text =
                                      '${picked.day.toString().padLeft(2, '0')}-'
                                      '${picked.month.toString().padLeft(2, '0')}-'
                                      '${picked.year}';
                                });
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: _field,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      dateCtrl.text.isEmpty
                                          ? 'dd-mm-yyyy'
                                          : dateCtrl.text,
                                      style: TextStyle(
                                        color: dateCtrl.text.isEmpty
                                            ? _dim
                                            : Colors.white,
                                        fontSize: ssz,
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.calendar_month,
                                    color: _dim,
                                    size: 18,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),

                // ── Submit ────────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _submitting
                        ? null
                        : () async {
                            // ── validation ───────────────────────
                            final code     = codeCtrl.text.trim();
                            final discount = double.tryParse(
                              discountCtrl.text.trim(),
                            );
                            final maxUsage = int.tryParse(
                              maxUsageCtrl.text.trim(),
                            );

                            if (code.isEmpty) {
                              _showCouponSnack(ctx, 'Coupon code is required');
                              return;
                            }
                            if (discount == null ||
                                discount <= 0 ||
                                discount > 100) {
                              _showCouponSnack(
                                ctx,
                                'Enter a valid discount (1–100)',
                              );
                              return;
                            }
                            if (maxUsage == null || maxUsage < 1) {
                              _showCouponSnack(
                                ctx,
                                'Enter a valid max usage per user',
                              );
                              return;
                            }
                            if (_selectedDate == null) {
                              _showCouponSnack(ctx, 'Please select an expiry date');
                              return;
                            }

                            // ── call API ─────────────────────────
                            setDialogState(() => _submitting = true);

                            final raw = await SuperAdminService.addCoupon(
                              couponCode: code,
                              discountPercentage: discount,
                              maxUsagePerUser: maxUsage,
                              expiryDate: _selectedDate!,
                            );

                            setDialogState(() => _submitting = false);

                            if (raw['success'] == true) {
                              await _fetchCoupons();
                              if (dialogCtx.mounted) {
                                Navigator.pop(dialogCtx);
                              }
                              _showCouponSnack(
                                ctx,
                                raw['message'] ?? 'Coupon added successfully!',
                                success: true,
                              );
                            } else {
                              _showCouponSnack(
                                ctx,
                                raw['message'] ?? 'Failed to add coupon',
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
                            'Add Coupon',
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
  void _showCouponSnack(BuildContext ctx, String msg, {bool success = false}) {
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

// ── Labelled text field used inside the coupon dialog ────────────────────────
class _CouponField extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  final double ssz;
  final TextInputType kb;
  const _CouponField({
    required this.label,
    required this.ctrl,
    required this.ssz,
    this.kb = TextInputType.text,
  });
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
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
          controller: ctrl,
          keyboardType: kb,
          style: TextStyle(color: Colors.white, fontSize: ssz),
          decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ),
    ],
  );
}