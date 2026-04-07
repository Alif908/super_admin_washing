import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// COLOURS
// ─────────────────────────────────────────────────────────────────────────────
const _card = Color(0xFF111A3A);
const _field = Color(0xFF1A2150);
const _blue = Color(0xFF4D8CFF);
const _green = Color(0xFF00E676);
const _red = Color(0xFFFF5252);
const _dim = Color(0xFFB0B8D4);

Future<void> showEditHubDialog(
  BuildContext context, {
  Map<String, String>? existing,
  ValueChanged<Map<String, String>>? onSave,
}) {
  return showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.6),
    builder: (_) => EditHubDialog(existing: existing, onSave: onSave),
  );
}

class EditHubDialog extends StatefulWidget {
  final Map<String, String>? existing;
  final ValueChanged<Map<String, String>>? onSave;

  const EditHubDialog({super.key, this.existing, this.onSave});

  @override
  State<EditHubDialog> createState() => _EditHubDialogState();
}

class _EditHubDialogState extends State<EditHubDialog> {
  late final TextEditingController _hubName;
  late final TextEditingController _hubId;
  late final TextEditingController _lat;
  late final TextEditingController _lng;
  late final TextEditingController _ownerName;
  late final TextEditingController _ownerId;
  late final TextEditingController _email;
  late final TextEditingController _mobile;
  late final TextEditingController _address;
  late final TextEditingController _bankName;
  late final TextEditingController _accountNo;
  late final TextEditingController _ifsc;
  late final TextEditingController _operatorName;
  late final TextEditingController _operatorMobile;

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing ?? {};

    _hubName = TextEditingController(text: e['hubName'] ?? '');
    _hubId = TextEditingController(text: e['hubCode'] ?? '');
    _lat = TextEditingController(text: e['latitude'] ?? '');
    _lng = TextEditingController(text: e['longitude'] ?? '');
    _ownerName = TextEditingController(text: e['hubOwnerName'] ?? '');

    // ✅ FIX: try all possible keys for owner ID
    final ownerIdValue = e['hubOwnerId'] ?? e['ownerId'] ?? '';
    _ownerId = TextEditingController(text: ownerIdValue);

    _email = TextEditingController(text: e['email'] ?? '');
    _mobile = TextEditingController(text: e['mobile'] ?? '');
    _address = TextEditingController(text: e['address'] ?? '');
    _bankName = TextEditingController(text: e['bankName'] ?? '');
    _accountNo = TextEditingController(text: e['accountNumber'] ?? '');
    _ifsc = TextEditingController(text: e['ifscCode'] ?? '');
    _operatorName = TextEditingController(text: e['operatorName'] ?? '');
    _operatorMobile = TextEditingController(text: e['operatorMobile'] ?? '');

    // DEBUG — remove after confirming fix
    debugPrint('EditHubDialog existing keys: ${e.keys.toList()}');
    debugPrint(
      'hubOwnerId=${e['hubOwnerId']} ownerId=${e['ownerId']} resolved=$ownerIdValue',
    );
  }

  @override
  void dispose() {
    for (final c in [
      _hubName,
      _hubId,
      _lat,
      _lng,
      _ownerName,
      _ownerId,
      _email,
      _mobile,
      _address,
      _bankName,
      _accountNo,
      _ifsc,
      _operatorName,
      _operatorMobile,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (_hubName.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hub name is required'),
          backgroundColor: _red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 500));

    final saved = {
      'hubName': _hubName.text.trim(),
      'hubCode': _hubId.text.trim(),
      'latitude': _lat.text.trim(),
      'longitude': _lng.text.trim(),
      'hubOwnerName': _ownerName.text.trim(),
      'hubOwnerId': _ownerId.text.trim(),
      'email': _email.text.trim(),
      'mobile': _mobile.text.trim(),
      'address': _address.text.trim(),
      'bankName': _bankName.text.trim(),
      'accountNumber': _accountNo.text.trim(),
      'ifscCode': _ifsc.text.trim(),
      'operatorName': _operatorName.text.trim(),
      'operatorMobile': _operatorMobile.text.trim(),
    };

    widget.onSave?.call(saved);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.existing != null
                ? '✅  Hub updated successfully'
                : '✅  Hub registered successfully',
          ),
          backgroundColor: _green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      // ✅ FIX: wrap in Scaffold so resizeToAvoidBottomInset works
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Scaffold(
          backgroundColor: _card,
          resizeToAvoidBottomInset: true,
          body: Column(
            children: [
              // ── Header ────────────────────────────────────────────
              Container(
                decoration: const BoxDecoration(
                  color: _card,
                  border: Border(bottom: BorderSide(color: _field, width: 1)),
                ),
                padding: const EdgeInsets.fromLTRB(22, 20, 16, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEdit ? 'Edit Hub Details' : 'Register New Hub',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: _field,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.close, color: _dim, size: 18),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Scrollable form ──────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(22, 14, 22, 4),
                  child: Column(
                    children: [
                      _HubRow(
                        left: _HubField(label: 'Hub Name', ctrl: _hubName),
                        right: _HubField(label: 'Hub ID', ctrl: _hubId),
                      ),
                      _HubRow(
                        left: _HubField(
                          label: 'Latitude',
                          ctrl: _lat,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                        right: _HubField(
                          label: 'Longitude',
                          ctrl: _lng,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                      ),
                      _HubRow(
                        left: _HubField(
                          label: 'Hub Owner Name',
                          ctrl: _ownerName,
                        ),
                        right: _HubField(
                          label: 'Owner ID',
                          ctrl: _ownerId,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      _HubRow(
                        left: _HubField(
                          label: 'Email',
                          ctrl: _email,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        right: _HubField(
                          label: 'Mobile',
                          ctrl: _mobile,
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                      _HubRow(
                        left: _HubField(label: 'Address', ctrl: _address),
                        right: _HubField(label: 'Bank Name', ctrl: _bankName),
                      ),
                      _HubRow(
                        left: _HubField(
                          label: 'Account Number',
                          ctrl: _accountNo,
                          keyboardType: TextInputType.number,
                        ),
                        right: _HubField(label: 'IFSC Code', ctrl: _ifsc),
                      ),
                      _HubRow(
                        left: _HubField(
                          label: 'Operator Name',
                          ctrl: _operatorName,
                        ),
                        right: _HubField(
                          label: 'Operator Mobile',
                          ctrl: _operatorMobile,
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),

              // ── Submit button ────────────────────────────────────
              Container(
                color: _card,
                padding: const EdgeInsets.fromLTRB(22, 12, 22, 22),
                child: GestureDetector(
                  onTap: _loading ? null : _submit,
                  child: Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      color: _loading
                          ? const Color(0xFF9E2020)
                          : const Color(0xFFE53935),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: _loading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Text(
                              isEdit ? 'Update Hub' : 'Register Hub',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Poppins',
                                letterSpacing: 0.3,
                              ),
                            ),
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

// ─────────────────────────────────────────────────────────────────────────────
// ROW  – two fields side by side
// ─────────────────────────────────────────────────────────────────────────────
class _HubRow extends StatelessWidget {
  final Widget left;
  final Widget right;
  const _HubRow({required this.left, required this.right});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        const SizedBox(width: 14),
        Expanded(child: right),
      ],
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// FIELD  – label + text input
// ─────────────────────────────────────────────────────────────────────────────
class _HubField extends StatelessWidget {
  final String label;
  final TextEditingController ctrl;
  final TextInputType keyboardType;

  const _HubField({
    required this.label,
    required this.ctrl,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          fontFamily: 'Poppins',
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
          keyboardType: keyboardType,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontFamily: 'Poppins',
          ),
          decoration: const InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            border: InputBorder.none,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(color: _blue, width: 1.5),
            ),
            enabledBorder: InputBorder.none,
          ),
        ),
      ),
    ],
  );
}
