part of 'dashboard.dart';

mixin _RegisterHubMixin<T extends StatefulWidget> on State<T> {
  // ── live list of hubs fetched from API ──
  List<HubModel> _hubs2 = [];

  // ── fetch all hubs and refresh the dashboard list ──
  Future<void> _fetchHubs() async {
    try {
      final raw = await SuperAdminService.getAllHubs();
      if (raw['success'] == true) {
        final list = (raw['data'] as List? ?? [])
            .map((e) => HubModel.fromJson(e))
            .toList();
        if (mounted) setState(() => _hubs2 = list);
        debugPrint('✅ [HUBS] total:${_hubs2.length}');
      }
    } catch (e) {
      debugPrint('❌ [HUBS] $e');
    }
  }

  void _showRegisterHubDialog(BuildContext ctx, double ssz) {
    final hubNameCtrl  = TextEditingController();
    final hubIdCtrl    = TextEditingController();
    final latCtrl      = TextEditingController();
    final lngCtrl      = TextEditingController();
    final ownerNameCtrl = TextEditingController();
    final ownerIdCtrl  = TextEditingController();
    final emailCtrl    = TextEditingController();
    final mobileCtrl   = TextEditingController();
    final addressCtrl  = TextEditingController();
    final bankNameCtrl = TextEditingController();
    final accountCtrl  = TextEditingController();
    final ifscCtrl     = TextEditingController();
    final opNameCtrl   = TextEditingController();
    final opMobileCtrl = TextEditingController();
    final sw = MediaQuery.of(ctx).size.width;

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
                // ── Title row ────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Register New Hub',
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

                // ── Hub Name / Hub ID ─────────────────────────────────
                _HRow(
                  children: [
                    _HField(label: 'Hub Name', ctrl: hubNameCtrl, ssz: ssz),
                    _HField(label: 'Hub ID', ctrl: hubIdCtrl, ssz: ssz),
                  ],
                ),
                const SizedBox(height: 14),

                // ── Latitude / Longitude ──────────────────────────────
                _HRow(
                  children: [
                    _HField(
                      label: 'Latitude',
                      ctrl: latCtrl,
                      ssz: ssz,
                      kb: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    _HField(
                      label: 'Longitude',
                      ctrl: lngCtrl,
                      ssz: ssz,
                      kb: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // ── Hub Owner Name / Owner ID ─────────────────────────
                _HRow(
                  children: [
                    _HField(
                      label: 'Hub Owner Name',
                      ctrl: ownerNameCtrl,
                      ssz: ssz,
                    ),
                    _HField(
                      label: 'Owner ID',
                      ctrl: ownerIdCtrl,
                      ssz: ssz,
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // ── Email / Mobile ────────────────────────────────────
                _HRow(
                  children: [
                    _HField(
                      label: 'Email',
                      ctrl: emailCtrl,
                      ssz: ssz,
                      kb: TextInputType.emailAddress,
                    ),
                    _HField(
                      label: 'Mobile',
                      ctrl: mobileCtrl,
                      ssz: ssz,
                      kb: TextInputType.phone,
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // ── Address / Bank Name ───────────────────────────────
                _HRow(
                  children: [
                    _HField(label: 'Address', ctrl: addressCtrl, ssz: ssz),
                    _HField(label: 'Bank Name', ctrl: bankNameCtrl, ssz: ssz),
                  ],
                ),
                const SizedBox(height: 14),

                // ── Account Number / IFSC Code ────────────────────────
                _HRow(
                  children: [
                    _HField(
                      label: 'Account Number',
                      ctrl: accountCtrl,
                      ssz: ssz,
                      kb: TextInputType.number,
                    ),
                    _HField(label: 'IFSC Code', ctrl: ifscCtrl, ssz: ssz),
                  ],
                ),
                const SizedBox(height: 14),

                // ── Operator Name / Operator Mobile ───────────────────
                _HRow(
                  children: [
                    _HField(
                      label: 'Operator Name',
                      ctrl: opNameCtrl,
                      ssz: ssz,
                    ),
                    _HField(
                      label: 'Operator Mobile',
                      ctrl: opMobileCtrl,
                      ssz: ssz,
                      kb: TextInputType.phone,
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
                            final hubName   = hubNameCtrl.text.trim();
                            final email     = emailCtrl.text.trim();
                            final mobile    = mobileCtrl.text.trim();
                            final ownerName = ownerNameCtrl.text.trim();
                            final ownerId   = int.tryParse(
                              ownerIdCtrl.text.trim(),
                            );

                            if (hubName.isEmpty) {
                              _showHubSnack(ctx, 'Hub name is required');
                              return;
                            }
                            if (email.isEmpty) {
                              _showHubSnack(ctx, 'Email is required');
                              return;
                            }
                            if (mobile.isEmpty) {
                              _showHubSnack(ctx, 'Mobile is required');
                              return;
                            }
                            if (ownerName.isEmpty) {
                              _showHubSnack(ctx, 'Owner name is required');
                              return;
                            }
                            if (ownerId == null) {
                              _showHubSnack(
                                ctx,
                                'Enter a valid numeric Owner ID',
                              );
                              return;
                            }

                            // ── call API ─────────────────────────
                            setDialogState(() => _submitting = true);

                            final raw = await SuperAdminService.registerHub(
                              hubName: hubName,
                              hubCode: hubIdCtrl.text.trim(),
                              latitude: double.tryParse(latCtrl.text.trim()),
                              longitude: double.tryParse(lngCtrl.text.trim()),
                              hubOwnerName: ownerName,
                              hubOwnerId: ownerId,
                              email: email,
                              mobile: mobile,
                              address: addressCtrl.text.trim(),
                              bankName: bankNameCtrl.text.trim(),
                              accountNumber: accountCtrl.text.trim(),
                              ifscCode: ifscCtrl.text.trim(),
                              operatorName: opNameCtrl.text.trim(),
                              operatorMobile: opMobileCtrl.text.trim(),
                            );

                            setDialogState(() => _submitting = false);

                            if (raw['success'] == true) {
                              await _fetchHubs();
                              if (dialogCtx.mounted) {
                                Navigator.pop(dialogCtx);
                              }
                              _showHubSnack(
                                ctx,
                                raw['message'] ?? 'Hub registered successfully!',
                                success: true,
                              );
                            } else {
                              _showHubSnack(
                                ctx,
                                raw['message'] ?? 'Failed to register hub',
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
                            'Add Hub',
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

  // ── snackbar helper ─────────────────────────────────────────────────────
  void _showHubSnack(BuildContext ctx, String msg, {bool success = false}) {
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

// ── Reusable row wrapper (two equal fields side by side) ──────────────────────
class _HRow extends StatelessWidget {
  final List<Widget> children;
  const _HRow({required this.children});
  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(child: children[0]),
      const SizedBox(width: 12),
      Expanded(child: children[1]),
    ],
  );
}

// ── Labelled field used inside the hub dialog ─────────────────────────────────
class _HField extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  final double ssz;
  final TextInputType kb;
  const _HField({
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