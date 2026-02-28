part of 'dashboard.dart';

mixin _RegisterHubMixin<T extends StatefulWidget> on State<T> {
  void _showRegisterHubDialog(BuildContext ctx, double ssz) {
    final hubNameCtrl = TextEditingController();
    final hubIdCtrl = TextEditingController();
    final latCtrl = TextEditingController();
    final lngCtrl = TextEditingController();
    final ownerNameCtrl = TextEditingController();
    final ownerIdCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final mobileCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    final bankNameCtrl = TextEditingController();
    final accountCtrl = TextEditingController();
    final ifscCtrl = TextEditingController();
    final opNameCtrl = TextEditingController();
    final opMobileCtrl = TextEditingController();
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
              // ── Title row ──────────────────────────────────────────
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

              // ── Hub Name / Hub ID ──────────────────────────────────
              _HRow(
                children: [
                  _HField(label: 'Hub Name', ctrl: hubNameCtrl, ssz: ssz),
                  _HField(label: 'Hub ID', ctrl: hubIdCtrl, ssz: ssz),
                ],
              ),
              const SizedBox(height: 14),

              // ── Latitude / Longitude ───────────────────────────────
              _HRow(
                children: [
                  _HField(
                    label: 'Latitude',
                    ctrl: latCtrl,
                    ssz: ssz,
                    kb: TextInputType.numberWithOptions(decimal: true),
                  ),
                  _HField(
                    label: 'Longitude',
                    ctrl: lngCtrl,
                    ssz: ssz,
                    kb: TextInputType.numberWithOptions(decimal: true),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // ── Hub Owner Name / Owner ID ──────────────────────────
              _HRow(
                children: [
                  _HField(
                    label: 'Hub Owner Name',
                    ctrl: ownerNameCtrl,
                    ssz: ssz,
                  ),
                  _HField(label: 'Owner ID', ctrl: ownerIdCtrl, ssz: ssz),
                ],
              ),
              const SizedBox(height: 14),

              // ── Email / Mobile ─────────────────────────────────────
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

              // ── Address / Bank Name ────────────────────────────────
              _HRow(
                children: [
                  _HField(label: 'Address', ctrl: addressCtrl, ssz: ssz),
                  _HField(label: 'Bank Name', ctrl: bankNameCtrl, ssz: ssz),
                ],
              ),
              const SizedBox(height: 14),

              // ── Account Number / IFSC Code ─────────────────────────
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
                  _HField(label: 'Operator Name', ctrl: opNameCtrl, ssz: ssz),
                  _HField(
                    label: 'Operator Mobile',
                    ctrl: opMobileCtrl,
                    ssz: ssz,
                    kb: TextInputType.phone,
                  ),
                ],
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
