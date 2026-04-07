part of 'dashboard.dart';

mixin _AddCouponMixin<T extends StatefulWidget> on State<T> {
  // Implemented by _State in dashboard.dart
  Future<void> _loadAll();

  void _showAddCouponDialog(BuildContext ctx, double ssz) {
    final codeCtrl = TextEditingController();
    final discountCtrl = TextEditingController();
    final maxUsageCtrl = TextEditingController();
    final dateCtrl = TextEditingController();
    DateTime? selectedDate;
    bool isLoading = false;
    String? errorMsg;
    final sw = MediaQuery.of(ctx).size.width;

    showDialog(
      context: ctx,
      barrierColor: Colors.black.withOpacity(0.7),
      barrierDismissible: false,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) {
          Future<void> submit() async {
            // ── Validation ────────────────────────────────────────────
            final code = codeCtrl.text.trim().toUpperCase();
            final discount = double.tryParse(discountCtrl.text.trim());
            final maxUsage = int.tryParse(maxUsageCtrl.text.trim());

            if (code.isEmpty) {
              setDialogState(() => errorMsg = 'Coupon code is required.');
              return;
            }
            if (discount == null || discount <= 0 || discount > 100) {
              setDialogState(
                () => errorMsg = 'Enter a valid discount (1–100).',
              );
              return;
            }
            if (maxUsage == null || maxUsage <= 0) {
              setDialogState(() => errorMsg = 'Enter a valid max usage (≥ 1).');
              return;
            }
            if (selectedDate == null) {
              setDialogState(() => errorMsg = 'Please select an expiry date.');
              return;
            }

            setDialogState(() {
              isLoading = true;
              errorMsg = null;
            });

            // ── API call ──────────────────────────────────────────────
            final res = await SuperAdminService.addCoupon(
              couponCode: code,
              discountPercentage: discount,
              maxUsagePerUser: maxUsage,
              expiryDate: selectedDate!,
            );

            if (!dialogCtx.mounted) return;

            if (res['success'] == true) {
              // Reload the full list so the new coupon appears
              Navigator.pop(dialogCtx);
              await _loadAll();
            } else {
              setDialogState(() {
                isLoading = false;
                errorMsg = res['message'] ?? 'Failed to add coupon.';
              });
            }
          }

          return Dialog(
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
                  // ── Title row ──────────────────────────────────────
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
                        onTap: isLoading
                            ? null
                            : () => Navigator.pop(dialogCtx),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),

                  // ── Coupon Code / Discount ─────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _CouponField(
                          label: 'Coupon Code',
                          ctrl: codeCtrl,
                          ssz: ssz,
                          enabled: !isLoading,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _CouponField(
                          label: 'Discount Percentage (%)',
                          ctrl: discountCtrl,
                          ssz: ssz,
                          kb: TextInputType.number,
                          enabled: !isLoading,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // ── Max Usage / Expiry Date ────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _CouponField(
                          label: 'Max Usage Per User',
                          ctrl: maxUsageCtrl,
                          ssz: ssz,
                          kb: TextInputType.number,
                          enabled: !isLoading,
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
                              onTap: isLoading
                                  ? null
                                  : () async {
                                      final picked = await showDatePicker(
                                        context: dialogCtx,
                                        initialDate:
                                            selectedDate ?? DateTime.now(),
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
                                          selectedDate = picked;
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
                  const SizedBox(height: 14),

                  // ── Error message ──────────────────────────────────
                  if (errorMsg != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: _red.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _red.withOpacity(0.4)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: _red,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              errorMsg!,
                              style: TextStyle(color: _red, fontSize: ssz - 1),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // ── Submit button ──────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE53935),
                        disabledBackgroundColor: const Color(
                          0xFFE53935,
                        ).withOpacity(0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: isLoading
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
          );
        },
      ),
    );
  }
}

// ── Labelled field ─────────────────────────────────────────────────────────────
class _CouponField extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  final double ssz;
  final TextInputType kb;
  final bool enabled;

  const _CouponField({
    required this.label,
    required this.ctrl,
    required this.ssz,
    this.kb = TextInputType.text,
    this.enabled = true,
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
          enabled: enabled,
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
