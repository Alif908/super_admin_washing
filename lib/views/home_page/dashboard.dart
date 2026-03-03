import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:super_admin_washing/models/superadminmodel.dart';
import 'package:super_admin_washing/services/SuperAdminApiService.dart';

part 'add_package.dart';
part 'register_hub.dart';
part 'add_coupon.dart';
part 'add_device.dart';
part 'download_report.dart';

void main() => runApp(const _App());

class _App extends StatelessWidget {
  const _App();
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      fontFamily: 'Poppins',
      scaffoldBackgroundColor: const Color(0xFF0A0E2A),
    ),
    home: const FleetDashboardScreen(),
  );
}

const _bg = Color(0xFF0A0E2A);
const _card = Color(0xFF111A3A);
const _field = Color(0xFF1A2150);
const _blue = Color(0xFF4D8CFF);
const _cyan = Color(0xFF00E5FF);
const _green = Color(0xFF00E676);
const _red = Color(0xFFFF5252);
const _purple = Color(0xFFAA00FF);
const _dim = Color(0xFFB0B8D4);

class FleetDashboardScreen extends StatefulWidget {
  const FleetDashboardScreen({super.key});
  @override
  State<FleetDashboardScreen> createState() => _State();
}

class _State extends State<FleetDashboardScreen>
    with
        _AddPackageMixin,
        _RegisterHubMixin,
        _AddCouponMixin,
        _AddDeviceMixin,
        _DownloadReportMixin {
  // ── UI state ──────────────────────────────────────────────────────────
  String _role = 'Super Admin';
  int _tab = 0;
  String _monHub = '-- All Hubs --';
  String _useHub = '-- All Hubs --';
  String _useUser = '-- All Users --';
  String _svcHub = '-- Select Hub --';

  final _roles = ['Super Admin', 'Admin', 'Manager', 'Operator'];
  final _hubs = ['-- All Hubs --', 'Calicut Express Wash Hub'];

  // ── API data state ────────────────────────────────────────────────────
  bool _loadingStats = true;
  double _totalRevenue = 0;
  double _todayRevenue = 0;
  int _openTickets = 0;
  int _highPriority = 0;
  int _newOwners = 0;
  List<WashHistoryModel> _washHistory = [];
  List<ServiceRequestModel> _serviceRequests = [];

  // ── Lifecycle ─────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _fetchAll();
  }

  // ── Fetch all — with timeout + error safety ───────────────────────────
  Future<void> _fetchAll() async {
    setState(() => _loadingStats = true);
    try {
      await Future.wait([
        _fetchRevenue(),
        _fetchTodayRevenue(),
        _fetchServiceRequests(),
        _fetchNewHubOwners(),
        _fetchWashHistory(),
      ]).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          debugPrint(
            '⚠️ [DASHBOARD] _fetchAll timed out — showing UI with defaults',
          );
          return <void>[];
        },
      );
    } catch (e) {
      debugPrint('❌ [DASHBOARD] _fetchAll error: $e');
    } finally {
      if (mounted) setState(() => _loadingStats = false);
    }
  }

  Future<void> _fetchRevenue() async {
    try {
      final raw = await SuperAdminService.getTotalRevenue();
      final m = RevenueModel.fromJson(raw);
      if (m.success) setState(() => _totalRevenue = m.totalRevenue);
      debugPrint('✅ [REVENUE] ${m.totalRevenue}');
    } catch (e) {
      debugPrint('❌ [REVENUE] $e');
    }
  }

  Future<void> _fetchTodayRevenue() async {
    try {
      final raw = await SuperAdminService.getTodayRevenue();
      final m = RevenueModel.fromJson(raw);
      if (m.success) setState(() => _todayRevenue = m.totalRevenue);
      debugPrint('✅ [TODAY_REVENUE] ${m.totalRevenue}');
    } catch (e) {
      debugPrint('❌ [TODAY_REVENUE] $e');
    }
  }

  Future<void> _fetchServiceRequests() async {
    try {
      final raw = await SuperAdminService.getAllServiceRequests();
      if (raw['success'] == true) {
        final stats = ServiceRequestStats.fromJson(raw['stats'] ?? {});
        final list = (raw['data'] as List? ?? [])
            .map((e) => ServiceRequestModel.fromJson(e))
            .toList();
        setState(() {
          _openTickets = stats.pending + stats.inProgress;
          _highPriority = stats.pending;
          _serviceRequests = list;
        });
        debugPrint('✅ [SERVICE_REQUESTS] total:${stats.total}');
      }
    } catch (e) {
      debugPrint('❌ [SERVICE_REQUESTS] $e');
    }
  }

  Future<void> _fetchNewHubOwners() async {
    try {
      final raw = await SuperAdminService.getNewHubOwnersLast30Days();
      final m = NewHubOwnersStatsModel.fromJson(raw);
      if (m.success) setState(() => _newOwners = m.totalNewHubOwners);
      debugPrint('✅ [HUB_OWNERS] ${m.totalNewHubOwners}');
    } catch (e) {
      debugPrint('❌ [HUB_OWNERS] $e');
    }
  }

  Future<void> _fetchWashHistory() async {
    try {
      final raw = await SuperAdminService.getAllWashHistory();
      if (raw['success'] == true) {
        setState(() {
          _washHistory = (raw['data'] as List? ?? [])
              .map((e) => WashHistoryModel.fromJson(e))
              .toList();
        });
        debugPrint('✅ [WASH_HISTORY] total:${_washHistory.length}');
      }
    } catch (e) {
      debugPrint('❌ [WASH_HISTORY] $e');
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final sw = mq.size.width;
    final sh = mq.size.height;
    final hp = sw * 0.04;

    final tsz = sw < 360
        ? 18.0
        : sw < 400
        ? 20.0
        : 24.0;
    final ssz = sw < 360
        ? 11.0
        : sw < 400
        ? 12.0
        : 13.0;
    final lsz = sw < 360
        ? 9.0
        : sw < 400
        ? 10.0
        : 11.0;
    final vsz = sw < 360
        ? 24.0
        : sw < 400
        ? 28.0
        : 32.0;
    final gap = sh * 0.015;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: _loadingStats
            ? const Center(child: CircularProgressIndicator(color: _blue))
            : RefreshIndicator(
                // ← pull to refresh
                onRefresh: _fetchAll,
                color: _blue,
                backgroundColor: _card,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(hp, gap, hp, gap * 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── HEADER ─────────────────────────────────────────
                      Text(
                        'Wash Fleet Management',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: tsz,
                          fontWeight: FontWeight.w900,
                          height: 1.2,
                        ),
                      ),
                      SizedBox(height: gap),
                      Row(
                        children: [
                          Text(
                            'View As:',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: ssz,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          _BorderDrop(
                            value: _role,
                            items: _roles,
                            fsz: ssz,
                            onChanged: (v) {
                              if (v != null) setState(() => _role = v);
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: gap),

                      // ── FLEET OVERVIEW ROW + REFRESH BUTTON ────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$_role - Fleet Overview',
                            style: TextStyle(
                              color: _cyan,
                              fontSize: ssz,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          GestureDetector(
                            onTap: _fetchAll, // ← tap refresh button
                            child: const Icon(
                              Icons.refresh,
                              color: _cyan,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: gap),

                      // ── STAT CARDS ────────────────────────────────────
                      _StatCard(
                        bar: _green,
                        label: 'Total Lifetime Revenue',
                        icon: Icons.currency_rupee,
                        iconColor: _green,
                        value: '₹ ${_totalRevenue.toStringAsFixed(0)}',
                        sub: 'Today: ₹ ${_todayRevenue.toStringAsFixed(0)}',
                        subColor: _green,
                        lsz: lsz,
                        vsz: vsz,
                        ssz: ssz,
                      ),
                      SizedBox(height: gap),
                      _StatCard(
                        bar: _blue,
                        label: 'Total Active Units',
                        value: '103 / 110',
                        sub: '7 Units Offline',
                        subColor: _red,
                        lsz: lsz,
                        vsz: vsz,
                        ssz: ssz,
                      ),
                      SizedBox(height: gap),
                      _StatCard(
                        bar: _red,
                        label: 'Open Service Tickets',
                        icon: Icons.notifications,
                        iconColor: _red,
                        value: '$_openTickets',
                        sub: '$_highPriority are High Priority',
                        subColor: _dim,
                        lsz: lsz,
                        vsz: vsz,
                        ssz: ssz,
                      ),
                      SizedBox(height: gap),
                      _StatCard(
                        bar: _purple,
                        label: 'New Owners (30 Days)',
                        icon: Icons.people,
                        iconColor: _purple,
                        value: '$_newOwners',
                        sub: 'Avg time to onboard: 7 days',
                        subColor: _dim,
                        lsz: lsz,
                        vsz: vsz,
                        ssz: ssz,
                      ),
                      SizedBox(height: gap * 1.4),

                      // ── ALL PACKAGES ───────────────────────────────────
                      _Card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _CTitle('All Packages', ssz),
                            SizedBox(height: gap),
                            _InfoBox('Total Packages: 2', ssz),
                            SizedBox(height: gap * 0.6),
                            _THead(
                              cols: const ['PACKAGE NAME', 'DESCRIPTION'],
                              flex: const [2, 3],
                              lsz: lsz,
                            ),
                            _TRow(
                              cells: const [
                                'Deep Clean',
                                'High pressure 50-min deep clean',
                              ],
                              flex: const [2, 3],
                              ssz: ssz,
                              bold: const [true, false],
                            ),
                            _TRow(
                              cells: const [
                                'Deep Clean',
                                'High pressure 50-min deep clean',
                              ],
                              flex: const [2, 3],
                              ssz: ssz,
                              bold: const [true, false],
                            ),
                            SizedBox(height: gap * 0.5),
                            const _SBar(),
                            SizedBox(height: gap),
                            _Btn(
                              label: '+ Add Package',
                              onTap: () => _showAddPackageDialog(context, ssz),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: gap),

                      // ── HUB LISTS ──────────────────────────────────────
                      _Card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _CTitle('Hub Lists', ssz),
                            SizedBox(height: gap),
                            _THead(
                              cols: const ['HUB ID', 'HUB NAME', 'OWNER'],
                              flex: const [2, 3, 2],
                              lsz: lsz,
                            ),
                            _TRow(
                              cells: const [
                                'HUB001',
                                'Calicut Express Wash Hub',
                                'Vimal',
                              ],
                              flex: const [2, 3, 2],
                              ssz: ssz,
                              bold: const [true, false, false],
                            ),
                            SizedBox(height: gap * 0.5),
                            const _SBar(),
                            SizedBox(height: gap),
                            _Btn(
                              label: '+ Register New Hub',
                              onTap: () => _showRegisterHubDialog(context, ssz),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: gap),

                      // ── COUPONS ────────────────────────────────────────
                      _Card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _CTitle('Coupons', ssz),
                            SizedBox(height: gap),
                            _THead(
                              cols: const [
                                'COUPON CODE',
                                'DISCOUNT (%)',
                                'MAX / USER',
                              ],
                              flex: const [3, 3, 2],
                              lsz: lsz,
                            ),
                            _TRow(
                              cells: const ['NEW30', '30%', '1'],
                              flex: const [3, 3, 2],
                              ssz: ssz,
                              bold: const [true, false, false],
                            ),
                            SizedBox(height: gap * 0.5),
                            const _SBar(),
                            SizedBox(height: gap),
                            _Btn(
                              label: '+ Add Coupon',
                              onTap: () => _showAddCouponDialog(context, ssz),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: gap * 1.4),

                      // ── TAB SELECTOR ───────────────────────────────────
                      Row(
                        children: [
                          _TabBox(
                            icon: Icons.monitor,
                            label: 'Monitoring',
                            selected: _tab == 0,
                            onTap: () => setState(() => _tab = 0),
                          ),
                          SizedBox(width: sw * 0.02),
                          _TabBox(
                            icon: Icons.history,
                            label: 'Usage\nHistory',
                            selected: _tab == 1,
                            onTap: () => setState(() => _tab = 1),
                          ),
                          SizedBox(width: sw * 0.02),
                          _TabBox(
                            icon: Icons.confirmation_number_outlined,
                            label: 'Service\nTickets',
                            selected: _tab == 2,
                            onTap: () => setState(() => _tab = 2),
                          ),
                        ],
                      ),
                      SizedBox(height: gap),

                      // ── TAB CONTENT ────────────────────────────────────
                      if (_tab == 0)
                        _Card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _CTitle('Device Unit Monitoring', ssz),
                              SizedBox(height: gap),
                              _FieldDrop(
                                value: _monHub,
                                items: _hubs,
                                fsz: ssz,
                                onChanged: (v) {
                                  if (v != null) setState(() => _monHub = v);
                                },
                              ),
                              SizedBox(height: gap),
                              _THead(
                                cols: const [
                                  'DEVICE ID',
                                  'DEVICE NAME',
                                  'COND.',
                                ],
                                flex: const [2, 4, 2],
                                lsz: lsz,
                              ),
                              _TRow(
                                cells: const [
                                  'DEV001',
                                  'Pressure Washer Pro 4000',
                                  'Good',
                                ],
                                flex: const [2, 4, 2],
                                ssz: ssz,
                                bold: const [true, false, false],
                              ),
                              SizedBox(height: gap * 0.5),
                              const _SBar(),
                              SizedBox(height: gap),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: GestureDetector(
                                      onTap: () {},
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.show_chart,
                                            color: _blue,
                                            size: 15,
                                          ),
                                          const SizedBox(width: 4),
                                          Flexible(
                                            child: Text(
                                              'Fleet Uptime Report',
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                color: _blue,
                                                fontSize: ssz,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  _Btn(
                                    label: '+ Add Device',
                                    onTap: () =>
                                        _showAddDeviceDialog(context, ssz),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      else if (_tab == 1)
                        _Card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Global Transaction History (Last 100)',
                                style: TextStyle(
                                  color: _cyan,
                                  fontSize: ssz + 1,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: gap),
                              _FieldDrop(
                                value: _useHub,
                                items: _hubs,
                                fsz: ssz,
                                onChanged: (v) {
                                  if (v != null) setState(() => _useHub = v);
                                },
                              ),
                              SizedBox(height: gap * 0.6),
                              _FieldDrop(
                                value: _useUser,
                                items: const ['-- All Users --', 'User A'],
                                fsz: ssz,
                                onChanged: (v) {
                                  if (v != null) setState(() => _useUser = v);
                                },
                              ),
                              SizedBox(height: gap),
                              _THead(
                                cols: const [
                                  'ORDER ID',
                                  'DEVICE ID',
                                  'DEVICE NAME',
                                ],
                                flex: const [2, 3, 4],
                                lsz: lsz,
                              ),
                              if (_washHistory.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                  child: Text(
                                    'No wash history found',
                                    style: TextStyle(
                                      color: _dim,
                                      fontSize: ssz,
                                    ),
                                  ),
                                )
                              else
                                ..._washHistory
                                    .take(100)
                                    .map(
                                      (w) => _TRow(
                                        cells: [
                                          '${w.id}',
                                          w.device?.deviceId ?? '-',
                                          w.device?.deviceName ?? '-',
                                        ],
                                        flex: const [2, 3, 4],
                                        ssz: ssz,
                                        bold: const [false, true, true],
                                      ),
                                    ),
                              SizedBox(height: gap * 0.5),
                              const _SBar(),
                              SizedBox(height: gap),
                              Center(
                                child: _OutlineBtn(
                                  label: '⬇  Download Full Report (CSV)',
                                  onTap: _downloadFullReport,
                                  fsz: ssz,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        _Card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Open Service Requests\n(Action Required)',
                                style: TextStyle(
                                  color: _red,
                                  fontSize: ssz + 1,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: gap),
                              _FieldDrop(
                                value: _svcHub,
                                items: const [
                                  '-- Select Hub --',
                                  'Calicut Express Wash Hub',
                                ],
                                fsz: ssz,
                                onChanged: (v) {
                                  if (v != null) setState(() => _svcHub = v);
                                },
                              ),
                              SizedBox(height: gap),
                              _THead(
                                cols: const ['TICKET ID', 'HUB', 'OWNER'],
                                flex: const [2, 4, 3],
                                lsz: lsz,
                              ),
                              if (_serviceRequests.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 10,
                                  ),
                                  child: Text(
                                    'No open service requests',
                                    style: TextStyle(
                                      color: _dim,
                                      fontSize: ssz,
                                    ),
                                  ),
                                )
                              else
                                ..._serviceRequests.map(
                                  (sr) => _TRow(
                                    cells: [
                                      '${sr.id}',
                                      sr.hub?.hubName ?? '-',
                                      sr.hubOwner?.mobile ?? '-',
                                    ],
                                    flex: const [2, 4, 3],
                                    ssz: ssz,
                                    bold: const [false, false, false],
                                  ),
                                ),
                              SizedBox(height: gap * 0.5),
                              const _SBar(),
                            ],
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

// ─────────────────────────────────────────────────────────────────────────────
// TAB BOX
// ─────────────────────────────────────────────────────────────────────────────
class _TabBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TabBox({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final fsz = sw < 360
        ? 9.5
        : sw < 400
        ? 10.5
        : 11.5;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: sw < 360 ? 10 : 13),
          decoration: BoxDecoration(
            color: selected ? _blue : _card,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: sw < 360 ? 20 : 22),
              SizedBox(height: sw < 360 ? 4 : 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: fsz,
                  fontWeight: FontWeight.w600,
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
// SHARED WIDGETS
// ─────────────────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final Color bar;
  final String label;
  final IconData? icon;
  final Color? iconColor;
  final String value, sub;
  final Color subColor;
  final double lsz, vsz, ssz;
  const _StatCard({
    required this.bar,
    required this.label,
    this.icon,
    this.iconColor,
    required this.value,
    required this.sub,
    required this.subColor,
    required this.lsz,
    required this.vsz,
    required this.ssz,
  });

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: _card,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 3,
          decoration: BoxDecoration(
            color: bar,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: _dim, fontSize: lsz),
                    ),
                  ),
                  if (icon != null) Icon(icon, color: iconColor, size: lsz + 8),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: vsz,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                sub,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: subColor,
                  fontSize: ssz - 1,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: _card,
      borderRadius: BorderRadius.circular(14),
    ),
    child: child,
  );
}

class _CTitle extends StatelessWidget {
  final String text;
  final double ssz;
  const _CTitle(this.text, this.ssz);
  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(
      color: Colors.white,
      fontSize: ssz + 2,
      fontWeight: FontWeight.bold,
    ),
  );
}

class _InfoBox extends StatelessWidget {
  final String text;
  final double ssz;
  const _InfoBox(this.text, this.ssz);
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 12),
    decoration: BoxDecoration(
      color: _field,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(color: Colors.white, fontSize: ssz),
    ),
  );
}

class _THead extends StatelessWidget {
  final List<String> cols;
  final List<int> flex;
  final double lsz;
  const _THead({required this.cols, required this.flex, required this.lsz});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
    decoration: BoxDecoration(
      color: _field,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: List.generate(
        cols.length,
        (i) => Expanded(
          flex: flex[i],
          child: Text(
            cols[i],
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            style: TextStyle(
              color: _dim,
              fontSize: lsz,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    ),
  );
}

class _TRow extends StatelessWidget {
  final List<String> cells;
  final List<int> flex;
  final double ssz;
  final List<bool> bold;
  const _TRow({
    required this.cells,
    required this.flex,
    required this.ssz,
    required this.bold,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
    decoration: const BoxDecoration(
      border: Border(bottom: BorderSide(color: _field, width: 1)),
    ),
    child: Row(
      children: List.generate(
        cells.length,
        (i) => Expanded(
          flex: flex[i],
          child: Text(
            cells[i],
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            style: TextStyle(
              color: Colors.white,
              fontSize: ssz - 1,
              fontWeight: bold[i] ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    ),
  );
}

class _SBar extends StatelessWidget {
  const _SBar();
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        flex: 2,
        child: Container(
          height: 4,
          decoration: BoxDecoration(
            color: _blue,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
      Expanded(
        flex: 3,
        child: Container(
          height: 4,
          decoration: BoxDecoration(
            color: _field,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    ],
  );
}

class _Btn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _Btn({required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final fs = sw < 360
        ? 10.0
        : sw < 400
        ? 11.5
        : 13.0;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: sw < 360 ? 12 : 14,
          vertical: sw < 360 ? 8 : 10,
        ),
        decoration: BoxDecoration(
          color: _blue,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: fs,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _OutlineBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final double fsz;
  const _OutlineBtn({
    required this.label,
    required this.onTap,
    required this.fsz,
  });
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
      decoration: BoxDecoration(
        color: _field,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _blue, width: 1),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: fsz,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  );
}

class _BorderDrop extends StatelessWidget {
  final String value;
  final List<String> items;
  final double fsz;
  final ValueChanged<String?> onChanged;
  const _BorderDrop({
    required this.value,
    required this.items,
    required this.fsz,
    required this.onChanged,
  });
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.white, width: 1.5),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: value,
        dropdownColor: _field,
        style: TextStyle(
          color: Colors.white,
          fontSize: fsz,
          fontWeight: FontWeight.w500,
          fontFamily: 'Poppins',
        ),
        icon: const Icon(
          Icons.keyboard_arrow_down,
          color: Colors.white,
          size: 16,
        ),
        isDense: true,
        onChanged: onChanged,
        items: items
            .map((r) => DropdownMenuItem(value: r, child: Text(r)))
            .toList(),
      ),
    ),
  );
}

class _FieldDrop extends StatelessWidget {
  final String value;
  final List<String> items;
  final double fsz;
  final ValueChanged<String?> onChanged;
  const _FieldDrop({
    required this.value,
    required this.items,
    required this.fsz,
    required this.onChanged,
  });
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: _field,
      borderRadius: BorderRadius.circular(10),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        dropdownColor: _field,
        style: TextStyle(
          color: Colors.white,
          fontSize: fsz,
          fontFamily: 'Poppins',
        ),
        icon: const Icon(
          Icons.keyboard_arrow_down,
          color: Colors.white,
          size: 16,
        ),
        isDense: true,
        onChanged: onChanged,
        items: items
            .map((i) => DropdownMenuItem(value: i, child: Text(i)))
            .toList(),
      ),
    ),
  );
}
