import 'package:flutter/material.dart';

const _card = Color(0xFF111A3A);
const _field = Color(0xFF1A2150);
const _blue = Color(0xFF4D8CFF);
const _green = Color(0xFF00E676);
const _red = Color(0xFFFF5252);
const _dim = Color(0xFFB0B8D4);

// ─────────────────────────────────────────────────────────────────────────────
// PUBLIC HELPER
// Usage in dashboard _buildMonitoring:
//
//   _ActBtn('Assign', _orange, Icons.link, () => showAssignDeviceDialog(
//     ctx,
//     hubs: _hubs.where((h) => h != '-- All Hubs --').toList(),
//     onAssign: (hubName) => setState(() => _devices[i]['hub'] = hubName),
//   )),
// ─────────────────────────────────────────────────────────────────────────────
Future<void> showAssignDeviceDialog(
  BuildContext context, {
  required List<String> hubs,
  ValueChanged<String>? onAssign,
}) {
  return showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.6),
    builder: (_) => AssignDeviceDialog(hubs: hubs, onAssign: onAssign),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// DIALOG WIDGET
// ─────────────────────────────────────────────────────────────────────────────
class AssignDeviceDialog extends StatefulWidget {
  final List<String> hubs;
  final ValueChanged<String>? onAssign;

  const AssignDeviceDialog({super.key, required this.hubs, this.onAssign});

  @override
  State<AssignDeviceDialog> createState() => _AssignDeviceDialogState();
}

class _AssignDeviceDialogState extends State<AssignDeviceDialog> {
  String? _selected;
  bool _loading = false;
  bool _showErr = false;

  Future<void> _submit() async {
    if (_selected == null) {
      setState(() => _showErr = true);
      return;
    }
    setState(() {
      _loading = true;
      _showErr = false;
    });
    await Future.delayed(const Duration(milliseconds: 400));

    widget.onAssign?.call(_selected!);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅  Device assigned to $_selected'),
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
    const placeholder = '-- Select Hub --';
    final dropItems = [placeholder, ...widget.hubs];

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        width: 480,
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _field, width: 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Header ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Assign Device to Hub',
                    style: TextStyle(
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

            // ── Select Hub ───────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Hub',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _field,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: _showErr ? _red : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selected ?? placeholder,
                        isExpanded: true,
                        dropdownColor: _field,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontFamily: 'Poppins',
                        ),
                        icon: const Icon(
                          Icons.keyboard_arrow_down,
                          color: _dim,
                          size: 18,
                        ),
                        isDense: true,
                        onChanged: (v) {
                          setState(() {
                            _selected = v == placeholder ? null : v;
                            _showErr = false;
                          });
                        },
                        items: dropItems
                            .map(
                              (h) => DropdownMenuItem(
                                value: h,
                                child: Text(
                                  h,
                                  style: TextStyle(
                                    color: h == placeholder
                                        ? const Color(0xFF4A5580)
                                        : Colors.white,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                  if (_showErr) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: const [
                        Icon(Icons.error_outline, color: _red, size: 12),
                        SizedBox(width: 3),
                        Text(
                          'Please select a hub',
                          style: TextStyle(
                            color: _red,
                            fontSize: 11,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // ── Assign Button ────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
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
                        : const Text(
                            'Assign Device',
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
