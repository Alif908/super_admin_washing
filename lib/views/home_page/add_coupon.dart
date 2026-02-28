part of 'dashboard.dart';

mixin _AddCouponMixin<T extends StatefulWidget> on State<T> {
  void _showAddCouponDialog(BuildContext ctx, double ssz) {
    final codeCtrl = TextEditingController();
    final discountCtrl = TextEditingController();
    final maxUsageCtrl = TextEditingController();
    DateTime? _selectedDate;
    final dateCtrl = TextEditingController(text: '');
    final sw = MediaQuery.of(ctx).size.width;

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
                    onPressed: () => Navigator.pop(dialogCtx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE53935),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
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
}

// ── Labelled text field used inside the coupon dialog ─────────────────────────
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
