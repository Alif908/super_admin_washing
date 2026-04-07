import 'package:flutter/material.dart';

const _bg = Color(0xFF0A0E2A);
const _card = Color(0xFF111A3A);
const _dim = Color(0xFFB0B8D4);
const _green = Color(0xFF00E676);
const _red = Color(0xFFFF5252);

class DeviceDetailsScreen extends StatelessWidget {
  final Map<String, String> device;
  final String? hubName;

  const DeviceDetailsScreen({super.key, required this.device, this.hubName});

  String _get(List<String> keys) {
    for (final k in keys) {
      final v = device[k];
      if (v != null && v.isNotEmpty && v != 'null') return v;
    }
    return '—';
  }

  Color _conditionColor(String cond) {
    final l = cond.toLowerCase();
    if (l.contains('good')) return _green;
    if (l.contains('bad') || l.contains('fault') || l.contains('offline'))
      return _red;
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final hp = sw * 0.06;

    final deviceId = _get(['deviceId', 'device_id', 'id']);
    final deviceName = _get(['deviceName', 'device_name', 'name']);
    final condition = _get(['condition', 'cond', 'status']);

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ──────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: hp, vertical: 18),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.chevron_left,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Device Details',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: sw < 360 ? 17 : 20,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 28),
                ],
              ),
            ),

            // ── Card ────────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: hp),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  horizontal: sw * 0.06,
                  vertical: 28,
                ),
                decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FieldTile(label: 'DEVICE ID', value: deviceId),
                    _FieldTile(label: 'DEVICE NAME', value: deviceName),
                    _FieldTile(
                      label: 'CONDITION',
                      value: condition,
                      valueColor: _conditionColor(condition),
                      isLast: true,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Field tile ────────────────────────────────────────────────────────────────
class _FieldTile extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final bool isLast;

  const _FieldTile({
    required this.label,
    required this.value,
    this.valueColor = Colors.white,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final vsz = sw < 360
        ? 14.0
        : sw < 400
        ? 15.0
        : 16.0;

    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: _dim,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: vsz,
              fontWeight: FontWeight.w700,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}
