import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// COLOURS  (matches dashboard theme)
// ─────────────────────────────────────────────────────────────────────────────
const _bg = Color(0xFF0A0E2A);
const _card = Color(0xFF111A3A);
const _field = Color(0xFF1A2150);
const _blue = Color(0xFF4D8CFF);
const _green = Color(0xFF00E676);
const _red = Color(0xFFFF5252);
const _dim = Color(0xFFB0B8D4);

// ─────────────────────────────────────────────────────────────────────────────
// PUBLIC HELPER  – call this from dashboard instead of Navigator.push
// ─────────────────────────────────────────────────────────────────────────────
Future<void> showEditPackageDialog(
  BuildContext context, {
  required Map<String, String> pkg,
  required ValueChanged<Map<String, String>> onSave,
}) {
  return showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.6),
    builder: (_) => EditPackageDialog(pkg: pkg, onSave: onSave),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// DIALOG WIDGET
// ─────────────────────────────────────────────────────────────────────────────
class EditPackageDialog extends StatefulWidget {
  final Map<String, String> pkg;
  final ValueChanged<Map<String, String>> onSave;

  const EditPackageDialog({super.key, required this.pkg, required this.onSave});

  @override
  State<EditPackageDialog> createState() => _EditPackageDialogState();
}

class _EditPackageDialogState extends State<EditPackageDialog> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _codeCtrl;

  bool _loading = false;
  String? _nameErr;
  String? _priceErr;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.pkg['name'] ?? '');
    _descCtrl = TextEditingController(text: widget.pkg['desc'] ?? '');
    _priceCtrl = TextEditingController(text: widget.pkg['price'] ?? '');
    _codeCtrl = TextEditingController(text: widget.pkg['code'] ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }

  bool _validate() {
    setState(() {
      _nameErr = _nameCtrl.text.trim().isEmpty ? 'Required' : null;
      _priceErr = _priceCtrl.text.trim().isEmpty
          ? 'Required'
          : double.tryParse(_priceCtrl.text.trim()) == null
          ? 'Invalid number'
          : null;
    });
    return _nameErr == null && _priceErr == null;
  }

  Future<void> _save() async {
    if (!_validate()) return;
    setState(() => _loading = true);

    await Future.delayed(const Duration(milliseconds: 400));

    final updated = {
      'name': _nameCtrl.text.trim(),
      'desc': _descCtrl.text.trim(),
      'price': double.parse(_priceCtrl.text.trim()).toStringAsFixed(2),
      'code': _codeCtrl.text.trim(),
    };

    widget.onSave(updated);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('✅  Package updated successfully'),
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
    final sw = MediaQuery.of(context).size.width;
    // Dialog width: 90% of screen, max 520
    final dialogW = (sw * 0.90).clamp(0.0, 520.0);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        width: dialogW,
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _field, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header ──────────────────────────────────────
            _DialogHeader(onClose: () => Navigator.pop(context)),

            // ── Body ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 4, 22, 22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row 1: Package Name | Description
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _FormGroup(
                          label: 'Package Name',
                          child: _DialogField(
                            ctrl: _nameCtrl,
                            hint: 'e.g. Deep Clean',
                            errorText: _nameErr,
                            onChanged: (_) {
                              if (_nameErr != null)
                                setState(() => _nameErr = null);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _FormGroup(
                          label: 'Description',
                          child: _DialogField(
                            ctrl: _descCtrl,
                            hint: 'e.g. 50-min deep clean',
                            maxLines: 3,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Row 2: Price | Status Code
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _FormGroup(
                          label: 'Price',
                          child: _DialogField(
                            ctrl: _priceCtrl,
                            hint: '0.00',
                            errorText: _priceErr,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            onChanged: (_) {
                              if (_priceErr != null)
                                setState(() => _priceErr = null);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _FormGroup(
                          label: 'Status Code',
                          child: _DialogField(
                            ctrl: _codeCtrl,
                            hint: 'e.g. 1001',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Update Button
                  _UpdateBtn(loading: _loading, onTap: _save),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DIALOG HEADER  — "Edit Package"  +  X button
// ─────────────────────────────────────────────────────────────────────────────
class _DialogHeader extends StatelessWidget {
  final VoidCallback onClose;
  const _DialogHeader({required this.onClose});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(22, 20, 16, 14),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Edit Package',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            fontFamily: 'Poppins',
          ),
        ),
        GestureDetector(
          onTap: onClose,
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
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// FORM GROUP  — label + field
// ─────────────────────────────────────────────────────────────────────────────
class _FormGroup extends StatelessWidget {
  final String label;
  final Widget child;
  const _FormGroup({required this.label, required this.child});

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
      const SizedBox(height: 8),
      child,
    ],
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// TEXT FIELD
// ─────────────────────────────────────────────────────────────────────────────
class _DialogField extends StatelessWidget {
  final TextEditingController ctrl;
  final String hint;
  final String? errorText;
  final int maxLines;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;

  const _DialogField({
    required this.ctrl,
    required this.hint,
    this.errorText,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final hasErr = errorText != null && errorText!.isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: _field,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: hasErr ? _red : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: TextField(
            controller: ctrl,
            maxLines: maxLines,
            keyboardType: keyboardType,
            onChanged: onChanged,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontFamily: 'Poppins',
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: Color(0xFF4A5580),
                fontSize: 13,
                fontFamily: 'Poppins',
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 13,
              ),
              border: InputBorder.none,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _blue, width: 1.5),
              ),
              enabledBorder: InputBorder.none,
            ),
          ),
        ),
        if (hasErr) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.error_outline, color: _red, size: 12),
              const SizedBox(width: 3),
              Text(
                errorText!,
                style: const TextStyle(
                  color: _red,
                  fontSize: 11,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// UPDATE BUTTON
// ─────────────────────────────────────────────────────────────────────────────
class _UpdateBtn extends StatelessWidget {
  final bool loading;
  final VoidCallback onTap;
  const _UpdateBtn({required this.loading, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: loading ? null : onTap,
    child: Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        color: loading ? const Color(0xFF9E2020) : const Color(0xFFE53935),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : const Text(
                'Update Package',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Poppins',
                  letterSpacing: 0.3,
                ),
              ),
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// KEEP EditPackageScreen for backward-compat (wraps the dialog on push)
// ─────────────────────────────────────────────────────────────────────────────
class EditPackageScreen extends StatelessWidget {
  final Map<String, String> pkg;
  final ValueChanged<Map<String, String>> onSave;

  const EditPackageScreen({super.key, required this.pkg, required this.onSave});

  @override
  Widget build(BuildContext context) {
    // Auto-show dialog when pushed as a route, then pop back
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showEditPackageDialog(context, pkg: pkg, onSave: onSave).then((_) {
        if (context.mounted) Navigator.pop(context);
      });
    });
    return const Scaffold(backgroundColor: _bg);
  }
}
