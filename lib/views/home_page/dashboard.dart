import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:super_admin_washing/models/superadminmodel.dart';
import 'package:super_admin_washing/services/SuperAdminApiService.dart';
import 'package:super_admin_washing/views/home_page/device/assign_device.dart';
import 'package:super_admin_washing/views/home_page/device/device_detail_page.dart';
import 'package:super_admin_washing/views/home_page/packages/edit_packages.dart';
import 'package:super_admin_washing/views/home_page/register%20hub/edit_register.dart';

part 'packages/add_package.dart';
part 'add_coupon.dart';
part 'download_report.dart';
part 'add_device.dart';

// ── Palette ──────────────────────────────────────────────────────────────────
const _bg = Color(0xFF0A0E2A);
const _card = Color(0xFF111A3A);
const _field = Color(0xFF1A2150);
const _blue = Color(0xFF4D8CFF);
const _cyan = Color(0xFF00E5FF);
const _green = Color(0xFF00E676);
const _red = Color(0xFFFF5252);
const _purple = Color(0xFFAA00FF);
const _orange = Color(0xFFFFAA00);
const _dim = Color(0xFFB0B8D4);

// ── Column widths ─────────────────────────────────────────────────────────────
const double _wId = 75.0;
const double _wName = 140.0;
const double _wOwner = 170.0;
const double _wDev = 65.0;
const double _wAction = 160.0;

const double _wPkgName = 110.0;
const double _wPkgDesc = 155.0;
const double _wPrice = 75.0;
const double _wStatus = 85.0;
const double _wAct2 = 130.0;

const double _wCode = 100.0;
const double _wDisc = 85.0;
const double _wMax = 70.0;
const double _wExpiry = 100.0;
const double _wBadge = 85.0;
const double _wAct3 = 65.0;

const double _wOrd = 80.0;
const double _wTxDev = 100.0;
const double _wTxName = 160.0;
const double _wDate = 160.0;
const double _wAmt = 95.0;
const double _wUser = 110.0;

const double _wTktId = 75.0;
const double _wSvcHub = 155.0;
const double _wSvcOwn = 120.0;
const double _wCat = 160.0;
const double _wSts = 110.0;
const double _wSvcAct = 160.0;

// ═════════════════════════════════════════════════════════════════════════════
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _State();
}

class _State extends State<DashboardScreen>
    with
        _AddPackageMixin,
        _AddCouponMixin,
        _AddDeviceMixin,
        _DownloadReportMixin {
  String _role = 'Super Admin';
  int _tab = 0;

  HubModel? _monHubFilter;
  HubModel? _useHubFilter;
  UserModel? _useUserFilter;
  HubModel? _svcHubFilter;

  // _loading is true ONLY during the very first load.
  // The 4-second timer runs completely silently — no spinner, no flicker.
  bool _loading = true;
  String? _error;

  // Fingerprint of the last fetched data.
  // When the timer fires and nothing changed, setState is skipped entirely.
  Object? _lastDataHash;

  List<PackageModel> _packages = [];
  List<HubModel> _hubList = [];
  List<CouponModel> _coupons = [];
  List<DeviceModel> _devices = [];
  List<WashHistoryModel> _washHistory = [];
  List<ServiceRequestModel> _svcRequests = [];
  List<UserModel> _users = [];

  double _totalRevenue = 0;
  double _todayRevenue = 0;
  int _openTickets = 0;
  int _highPriority = 0;
  int _newOwners = 0;

  final Set<int> _svcLoadingIds = {};

  final ScrollController _monScrollCtrl = ScrollController();
  double _monThumbFraction = 0.0;
  double _monThumbOffset = 0.0;

  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _monScrollCtrl.addListener(_onMonScroll);

    _loadAll(); // first load  → shows spinner once

    _refreshTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (mounted) _loadAll(silent: true); // background → zero UI change
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _monScrollCtrl.removeListener(_onMonScroll);
    _monScrollCtrl.dispose();
    super.dispose();
  }

  void _onMonScroll() {
    if (!_monScrollCtrl.hasClients) return;
    final max = _monScrollCtrl.position.maxScrollExtent;
    final view = _monScrollCtrl.position.viewportDimension;
    final total = max + view;
    setState(() {
      _monThumbFraction = total > 0 ? (view / total).clamp(0.0, 1.0) : 1.0;
      _monThumbOffset = max > 0
          ? (_monScrollCtrl.offset / max * (1.0 - _monThumbFraction)).clamp(
              0.0,
              1.0 - _monThumbFraction,
            )
          : 0.0;
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  KEY METHOD
  //  silent = false  → shows full-screen spinner (first load / pull-to-refresh)
  //  silent = true   → fetches quietly; only calls setState if data changed
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> _loadAll({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final results = await Future.wait([
        SuperAdminService.getAllPackages(),
        SuperAdminService.getAllHubs(),
        SuperAdminService.getAllCoupons(),
        SuperAdminService.getAllDevices(),
        SuperAdminService.getAllWashHistory(),
        SuperAdminService.getAllServiceRequests(),
        SuperAdminService.getTotalRevenue(),
        SuperAdminService.getTodayRevenue(),
        SuperAdminService.getAllUsers(),
        SuperAdminService.getNewHubOwnersLast30Days(),
      ]);

      if (!mounted) return;

      final pkgRes = results[0] as PackageListResponse;
      final hubRes = results[1] as HubListResponse;
      final cupRes = results[2] as CouponListResponse;
      final devRes = results[3] as DeviceListResponse;
      final washRes = results[4] as WashHistoryListResponse;
      final svcRes = results[5] as ServiceRequestListResponse;
      final revRes = results[6] as RevenueModel;
      final todRes = results[7] as RevenueModel;
      final usrRes = results[8] as UserListResponse;
      final ownRes = results[9] as GrowthStatsResponse;

      // Build a quick fingerprint of all relevant data.
      // If nothing changed on a silent tick, we return early with zero rebuilds.
      final newHash = Object.hashAll([
        pkgRes.packages.length,
        hubRes.hubs.length,
        cupRes.coupons.length,
        devRes.devices.length,
        washRes.history.length,
        svcRes.stats.openCount,
        svcRes.stats.pending,
        revRes.totalRevenue.toStringAsFixed(0),
        todRes.totalRevenue.toStringAsFixed(0),
        usrRes.users.length,
        ownRes.total,
        devRes.devices.map((d) => '${d.id}:${d.condition}').join(','),
        svcRes.requests.map((r) => '${r.id}:${r.status}').join(','),
      ]);

      // ← This is the key line: no setState = no rebuild = no flicker
      if (silent && newHash == _lastDataHash) return;
      _lastDataHash = newHash;

      setState(() {
        _packages = pkgRes.packages;
        _hubList = hubRes.hubs;
        _coupons = cupRes.coupons;
        _devices = devRes.devices;
        _washHistory = washRes.history;
        _svcRequests = svcRes.requests;
        _users = usrRes.users;
        _totalRevenue = revRes.totalRevenue;
        _todayRevenue = todRes.totalRevenue;
        _openTickets = svcRes.stats.openCount;
        _highPriority = svcRes.stats.pending;
        _newOwners = ownRes.total;
        _loading = false;
        _useUserFilter = null;
      });

      for (final h in hubRes.hubs) {
        debugPrint(
          'HUB[${h.id}] name=${h.hubName} '
          'ownerId=${h.hubOwnerId} ownerName=${h.hubOwnerName} '
          'accountNumber=${h.accountNumber} ifscCode=${h.ifscCode} '
          'bankName=${h.bankName} address=${h.address} '
          'mobile=${h.mobile} email=${h.email} '
          'lat=${h.latitude} lng=${h.longitude} '
          'operatorName=${h.operatorName} operatorMobile=${h.operatorMobile}',
        );
      }
    } catch (e) {
      if (!mounted) return;
      if (silent)
        return; // swallow background errors — never show error screen during timer
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  // ── Derived helpers ───────────────────────────────────────────────────────
  List<String> get _hubNames => [
    '-- All Hubs --',
    ..._hubList.map((h) => h.hubName),
  ];

  String _userDisplayName(UserModel u) =>
      (u.name.isEmpty || u.name == 'User') ? u.mobile : u.name;

  List<WashHistoryModel> get _filteredWash {
    var list = _washHistory.take(100).toList();
    if (_useHubFilter != null)
      list = list.where((w) => w.hubId == _useHubFilter!.id).toList();
    if (_useUserFilter != null)
      list = list.where((w) => w.userId == _useUserFilter!.id).toList();
    return list;
  }

  List<DeviceModel> get _filteredDevices {
    if (_monHubFilter == null) return _devices;
    return _devices
        .where(
          (d) =>
              d.hubId != null &&
              d.hubId.toString() == _monHubFilter!.id.toString(),
        )
        .toList();
  }

  List<ServiceRequestModel> get _filteredSvcRequests {
    if (_svcHubFilter == null) return _svcRequests;
    return _svcRequests.where((r) => r.hubId == _svcHubFilter!.id).toList();
  }

  String _hubNameById(int? id) {
    if (id == null || id == 0) return '—';
    return _hubList
        .firstWhere(
          (h) => h.id.toString() == id.toString(),
          orElse: () => HubModel(id: 0, hubName: '—'),
        )
        .hubName;
  }

  String? _deviceStringIdById(int? numericId) {
    if (numericId == null) return null;
    try {
      return _devices.firstWhere((d) => d.id == numericId).deviceId;
    } catch (_) {
      return 'DEV${numericId.toString().padLeft(3, '0')}';
    }
  }

  String? _deviceNameById(int? numericId) {
    if (numericId == null) return null;
    try {
      return _devices.firstWhere((d) => d.id == numericId).deviceName;
    } catch (_) {
      return null;
    }
  }

  String? _userNameById(int? userId) {
    if (userId == null) return null;
    try {
      final u = _users.firstWhere((u) => u.id == userId);
      return _userDisplayName(u);
    } catch (_) {
      return null;
    }
  }

  void _navigateToEditPackage(BuildContext ctx, int index, PackageModel pkg) {
    Navigator.push(
      ctx,
      MaterialPageRoute(
        builder: (_) => EditPackageScreen(
          pkg: {
            'name': pkg.packageName,
            'desc': pkg.description ?? '',
            'price': pkg.price.toStringAsFixed(2),
            'code': pkg.statusCode ?? '',
          },
          onSave: (updated) {
            setState(() {
              _packages[index] = PackageModel(
                id: pkg.id,
                packageName: updated['name'] ?? pkg.packageName,
                description: updated['desc'],
                price: double.tryParse(updated['price'] ?? '') ?? pkg.price,
                statusCode: updated['code'],
                createdAt: pkg.createdAt,
                updatedAt: pkg.updatedAt,
              );
            });
          },
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext ctx, String title, VoidCallback onConfirm) {
    bool tapped = false;
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: _card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(
          'Delete $title?',
          style: const TextStyle(color: Colors.white, fontFamily: 'Poppins'),
        ),
        content: Text(
          'This action cannot be undone.',
          style: TextStyle(color: _dim, fontFamily: 'Poppins'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: _dim)),
          ),
          TextButton(
            onPressed: () {
              if (tapped) return;
              tapped = true;
              Navigator.pop(ctx);
              onConfirm();
            },
            child: const Text('Delete', style: TextStyle(color: _red)),
          ),
        ],
      ),
    );
  }

  void _showBlockedDeleteDialog(BuildContext ctx, String message) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: _card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: _orange, size: 22),
            SizedBox(width: 8),
            Flexible(
              child: Text(
                'Cannot Delete Device',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(color: _dim, fontSize: 13, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Got it', style: TextStyle(color: _blue)),
          ),
        ],
      ),
    );
  }

  Future<void> _updateSvcStatus(
    ServiceRequestModel req,
    String newStatus,
  ) async {
    if (_svcLoadingIds.contains(req.id)) return;
    setState(() => _svcLoadingIds.add(req.id));
    try {
      final res = await SuperAdminService.updateServiceRequestStatus(
        hubId: req.hubId ?? 0,
        requestId: req.id,
        status: newStatus,
      );
      if (!mounted) return;
      if (res['success'] == true) {
        setState(() {
          final idx = _svcRequests.indexWhere((r) => r.id == req.id);
          if (idx != -1) _svcRequests[idx] = req.withStatus(newStatus);
          _openTickets = _svcRequests
              .where((r) => r.isPending || r.isInProgress)
              .length;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: _green,
            content: Text(
              'Ticket #${req.id} → ${_statusLabel(newStatus)}',
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: _red,
            content: Text(res['message'] ?? 'Update failed'),
          ),
        );
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: _red, content: Text('Error: $e')),
        );
    } finally {
      if (mounted) setState(() => _svcLoadingIds.remove(req.id));
    }
  }

  String _statusLabel(String raw) {
    switch (raw.toLowerCase().replaceAll('_', '')) {
      case 'pending':
        return 'Pending';
      case 'inprogress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      default:
        return raw;
    }
  }

  Color _statusColor(ServiceRequestModel sr) {
    if (sr.isCompleted) return _green;
    if (sr.isInProgress) return _blue;
    return _orange;
  }

  // ═══════════════════════════════════════════════════════════════════════════
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
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: _cyan))
            : _error != null
            ? _ErrorView(error: _error!, onRetry: _loadAll)
            : RefreshIndicator(
                color: _cyan,
                backgroundColor: _card,
                onRefresh: () => _loadAll(), // non-silent
                child: _buildBody(hp, gap, tsz, ssz, lsz, vsz),
              ),
      ),
    );
  }

  Widget _buildBody(
    double hp,
    double gap,
    double tsz,
    double ssz,
    double lsz,
    double vsz,
  ) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: ClampingScrollPhysics(),
      ),
      padding: EdgeInsets.fromLTRB(hp, gap, hp, gap * 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Wash Fleet Management',
            style: TextStyle(
              color: Colors.white,
              fontSize: tsz,
              fontWeight: FontWeight.w900,
              height: 1.2,
            ),
          ),
          SizedBox(height: gap * 0.7),
          Row(
            children: [
              Text(
                'View As:',
                style: TextStyle(
                  color: _dim,
                  fontSize: ssz,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(color: _dim, width: 1.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _role,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: ssz,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: gap * 0.7),
          Text(
            '$_role - Fleet Overview',
            style: TextStyle(
              color: _cyan,
              fontSize: ssz,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
            ),
          ),
          SizedBox(height: gap),
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
            value:
                '${_devices.where((d) => d.isGoodCondition).length} / ${_devices.length}',
            sub:
                '${_devices.where((d) => !d.isGoodCondition).length} Units Offline',
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
          _Card(child: _buildPackagesSection(gap, ssz, lsz)),
          SizedBox(height: gap),
          _Card(child: _buildHubsSection(gap, ssz, lsz)),
          SizedBox(height: gap),
          _Card(child: _buildCouponsSection(gap, ssz, lsz)),
          SizedBox(height: gap * 1.4),
          Row(
            children: [
              _TabBox(
                icon: Icons.monitor,
                label: 'Monitoring',
                selected: _tab == 0,
                onTap: () => setState(() => _tab = 0),
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.02),
              _TabBox(
                icon: Icons.history,
                label: 'Usage\nHistory',
                selected: _tab == 1,
                onTap: () => setState(() => _tab = 1),
              ),
              SizedBox(width: MediaQuery.of(context).size.width * 0.02),
              _TabBox(
                icon: Icons.confirmation_number_outlined,
                label: 'Service\nTickets',
                selected: _tab == 2,
                onTap: () => setState(() => _tab = 2),
              ),
            ],
          ),
          SizedBox(height: gap),
          if (_tab == 0)
            _buildMonitoring(context, gap, ssz, lsz)
          else if (_tab == 1)
            _buildHistory(context, gap, ssz, lsz)
          else
            _buildTickets(context, gap, ssz, lsz),
        ],
      ),
    );
  }

  // ── Packages ──────────────────────────────────────────────────────────────
  Widget _buildPackagesSection(double gap, double ssz, double lsz) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _CTitle('All Packages', ssz),
      SizedBox(height: gap),
      _InfoBox('Total Packages: ${_packages.length}', ssz),
      SizedBox(height: gap * 0.6),
      _HScroll(
        totalWidth: _wPkgName + _wPkgDesc + _wPrice + _wStatus + _wAct2 + 32,
        header: _hrow(lsz, [
          _hc('PACKAGE NAME', _wPkgName),
          _hc('DESCRIPTION', _wPkgDesc),
          _hc('PRICE', _wPrice),
          _hc('STATUS CODE', _wStatus),
          _hc('ACTION', _wAct2),
        ]),
        rows: List.generate(_packages.length, (i) {
          final p = _packages[i];
          return _drow(ssz, [
            _dc(p.packageName, _wPkgName, bold: true),
            _dc(p.description ?? '—', _wPkgDesc),
            _dc('₹${p.price.toStringAsFixed(2)}', _wPrice),
            SizedBox(
              width: _wStatus,
              child: Text(
                p.statusCode ?? '—',
                style: TextStyle(
                  color: _red,
                  fontSize: ssz - 1,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              width: _wAct2,
              child: Row(
                children: [
                  _ActBtn(
                    'Edit',
                    _green,
                    Icons.edit,
                    () => _navigateToEditPackage(context, i, p),
                  ),
                  const SizedBox(width: 6),
                  _ActBtn(
                    'Delete',
                    _red,
                    Icons.delete,
                    () => _confirmDelete(context, 'Package', () async {
                      final removed = _packages[i];
                      setState(() => _packages.removeAt(i));
                      final res = await SuperAdminService.deletePackage(
                        removed.id,
                      );
                      if (res['success'] != true) {
                        setState(() => _packages.insert(i, removed));
                        if (mounted)
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                res['message'] ?? 'Failed to delete package',
                              ),
                            ),
                          );
                      }
                    }),
                  ),
                ],
              ),
            ),
          ]);
        }),
      ),
      SizedBox(height: gap),
      _Btn(
        label: '+ Add Package',
        onTap: () => _showAddPackageDialog(
          context,
          ssz,
          onAdd: (map) async {
            final res = await SuperAdminService.addPackage(
              packageName: map['name'] ?? '',
              description: map['desc'],
              price: double.tryParse(map['price'] ?? '0') ?? 0,
              statusCode: map['code'],
            );
            if (res.success && res.package != null) {
              setState(() => _packages.add(res.package!));
            } else if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(res.message ?? 'Failed to add')),
              );
            }
          },
        ),
      ),
    ],
  );

  // ── Hubs ──────────────────────────────────────────────────────────────────
  Widget _buildHubsSection(double gap, double ssz, double lsz) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _CTitle('Hub Lists', ssz),
      SizedBox(height: gap),
      _HScroll(
        totalWidth: _wId + _wName + _wOwner + _wDev + _wAction + 32,
        header: _hrow(lsz, [
          _hc('HUB ID', _wId),
          _hc('HUB NAME', _wName),
          _hc('OWNER/LOCATION', _wOwner),
          _hc('DEVICES', _wDev),
          _hc('ACTION', _wAction),
        ]),
        rows: List.generate(_hubList.length, (i) {
          final h = _hubList[i];
          final devCount = _devices.any((d) => d.hubId != null)
              ? _devices
                    .where(
                      (d) =>
                          d.hubId != null &&
                          d.hubId.toString() == h.id.toString(),
                    )
                    .length
              : (h.deviceCount ?? 0);
          return _drow(ssz, [
            _dc('HUB${h.id.toString().padLeft(3, '0')}', _wId, bold: true),
            _dc(h.hubName, _wName),
            _dc('${h.hubOwnerName ?? '—'} / ${h.address ?? '—'}', _wOwner),
            _dc('$devCount', _wDev),
            SizedBox(
              width: _wAction,
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  _ActBtn(
                    'Edit',
                    _green,
                    Icons.edit,
                    () => showEditHubDialog(
                      context,
                      existing: {
                        'hubName': h.hubName,
                        'hubCode': h.hubCode ?? '',
                        'latitude': h.latitude?.toString() ?? '',
                        'longitude': h.longitude?.toString() ?? '',
                        'hubOwnerName': h.hubOwnerName ?? '',
                        'hubOwnerId': h.hubOwnerId?.toString() ?? '',
                        'email': h.email ?? '',
                        'mobile': h.mobile ?? '',
                        'address': h.address ?? '',
                        'bankName': h.bankName ?? '',
                        'accountNumber': h.accountNumber ?? '',
                        'ifscCode': h.ifscCode ?? '',
                        'operatorName': h.operatorName ?? '',
                        'operatorMobile': h.operatorMobile ?? '',
                      },
                      onSave: (updated) async {
                        final res = await SuperAdminService.updateHub(
                          hubId: h.id,
                          fields: {
                            'hubName': updated['hubName'],
                            'hubOwnerName': updated['hubOwnerName'],
                            'ownerId':
                                int.tryParse(updated['hubOwnerId'] ?? '') ??
                                h.hubOwnerId ??
                                0,
                            'email': updated['email'],
                            'mobile': updated['mobile'],
                            if ((updated['hubCode'] ?? '').isNotEmpty)
                              'hubId': updated['hubCode'],
                            if ((updated['address'] ?? '').isNotEmpty)
                              'address': updated['address'],
                            if ((updated['bankName'] ?? '').isNotEmpty)
                              'bankName': updated['bankName'],
                            if ((updated['accountNumber'] ?? '').isNotEmpty)
                              'acNumber': updated['accountNumber'],
                            if ((updated['ifscCode'] ?? '').isNotEmpty)
                              'ifscCode': updated['ifscCode'],
                            if ((updated['operatorName'] ?? '').isNotEmpty)
                              'operatorName': updated['operatorName'],
                            if ((updated['operatorMobile'] ?? '').isNotEmpty)
                              'operatorMobile': updated['operatorMobile'],
                            if ((updated['latitude'] ?? '').isNotEmpty)
                              'latitude': double.tryParse(updated['latitude']!),
                            if ((updated['longitude'] ?? '').isNotEmpty)
                              'longitude': double.tryParse(
                                updated['longitude']!,
                              ),
                          },
                        );
                        if (res['success'] == true) {
                          await _loadAll();
                        } else if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(res['message'] ?? 'Update failed'),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                  _ActBtn('View', _blue, Icons.remove_red_eye, () {}),
                  _ActBtn(
                    'Delete',
                    _red,
                    Icons.delete,
                    () => _confirmDelete(context, 'Hub', () async {
                      final removed = _hubList[i];
                      setState(() => _hubList.removeAt(i));
                      final res = await SuperAdminService.deleteHub(removed.id);
                      if (res['success'] != true) {
                        setState(() => _hubList.insert(i, removed));
                        if (mounted)
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                res['message'] ?? 'Failed to delete hub',
                              ),
                            ),
                          );
                      }
                    }),
                  ),
                ],
              ),
            ),
          ]);
        }),
      ),
      SizedBox(height: gap),
      _Btn(
        label: '+ Register New Hub',
        onTap: () => showEditHubDialog(
          context,
          onSave: (map) async {
            final res = await SuperAdminService.registerHub(
              hubName: map['hubName'] ?? '',
              hubOwnerName: map['hubOwnerName'] ?? '',
              hubOwnerId: int.tryParse(map['hubOwnerId'] ?? '0') ?? 0,
              email: map['email'] ?? '',
              mobile: map['mobile'] ?? '',
              address: map['address'],
              hubCode: map['hubCode'],
              bankName: map['bankName'],
              accountNumber: map['accountNumber'],
              ifscCode: map['ifscCode'],
              operatorName: map['operatorName'],
              operatorMobile: map['operatorMobile'],
              latitude: double.tryParse(map['latitude'] ?? ''),
              longitude: double.tryParse(map['longitude'] ?? ''),
            );
            if (res['success'] == true) {
              await _loadAll();
            } else if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(res['message'] ?? 'Failed')),
              );
            }
          },
        ),
      ),
    ],
  );

  // ── Coupons ───────────────────────────────────────────────────────────────
  Widget _buildCouponsSection(double gap, double ssz, double lsz) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _CTitle('Coupons', ssz),
      SizedBox(height: gap),
      _HScroll(
        totalWidth: _wCode + _wDisc + _wMax + _wExpiry + _wBadge + _wAct3 + 40,
        header: _hrow(lsz, [
          _hc('COUPON CODE', _wCode),
          _hc('DISCOUNT (%)', _wDisc),
          _hc('MAX / USER', _wMax),
          _hc('EXPIRY DATE', _wExpiry),
          _hc('STATUS', _wBadge),
          _hc('ACTION', _wAct3),
        ]),
        rows: List.generate(_coupons.length, (i) {
          final c = _coupons[i];
          final expired = c.isExpired;
          return _drow(ssz, [
            _dc(c.couponCode, _wCode, bold: true),
            _dc('${c.discountPercentage.toStringAsFixed(0)}%', _wDisc),
            _dc('${c.maxUsagePerUser}', _wMax),
            _dc(c.expiryDateDisplay, _wExpiry),
            SizedBox(
              width: _wBadge,
              child: _StatusBadge(
                expired ? 'EXPIRED' : 'ACTIVE',
                expired ? _red : _green,
                ssz - 2,
              ),
            ),
            SizedBox(
              width: _wAct3,
              child: _ActBtn(
                'Delete',
                _red,
                Icons.delete,
                () => _confirmDelete(context, 'Coupon', () async {
                  final removed = _coupons[i];
                  setState(() => _coupons.removeAt(i));
                  final res = await SuperAdminService.deleteCoupon(removed.id);
                  if (res['success'] != true) {
                    setState(() => _coupons.insert(i, removed));
                    if (mounted)
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            res['message'] ?? 'Failed to delete coupon',
                          ),
                        ),
                      );
                  }
                }),
              ),
            ),
          ]);
        }),
      ),
      SizedBox(height: gap),
      _Btn(
        label: '+ Add Coupon',
        onTap: () => _showAddCouponDialog(context, ssz),
      ),
    ],
  );

  // ── Monitoring ────────────────────────────────────────────────────────────
  Widget _buildMonitoring(
    BuildContext ctx,
    double gap,
    double ssz,
    double lsz,
  ) {
    const wId = 90.0, wName = 160.0, wCond = 90.0, wHub = 160.0, wAct = 220.0;
    const totalW = wId + wName + wCond + wHub + wAct + 32.0 + 20.0;

    Widget buildRow(List<Widget> cells) => Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: cells.expand((w) => [w, const SizedBox(width: 8)]).toList()
        ..removeLast(),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_monScrollCtrl.hasClients && _monThumbFraction == 0.0) _onMonScroll();
    });

    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CTitle('Device Unit Monitoring', ssz),
          SizedBox(height: gap),
          _FieldDrop(
            value: _monHubFilter?.hubName ?? '-- All Hubs --',
            items: _hubNames,
            fsz: ssz,
            onChanged: (v) => setState(() {
              _monHubFilter = v == '-- All Hubs --'
                  ? null
                  : _hubList.firstWhere(
                      (h) => h.hubName == v,
                      orElse: () => HubModel(id: 0, hubName: v ?? ''),
                    );
            }),
          ),
          SizedBox(height: gap),
          SingleChildScrollView(
            controller: _monScrollCtrl,
            scrollDirection: Axis.horizontal,
            physics: const ClampingScrollPhysics(),
            child: SizedBox(
              width: totalW,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 10,
                    ),
                    decoration: BoxDecoration(
                      color: _field,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: buildRow([
                      _thc('DEVICE ID', wId),
                      _thc('DEVICE NAME', wName),
                      _thc('CONDITION', wCond),
                      _thc('ASSIGNED HUB', wHub),
                      _thc('ACTION', wAct),
                    ]),
                  ),
                  if (_filteredDevices.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: Text(
                          'No devices found',
                          style: TextStyle(color: _dim, fontSize: ssz),
                        ),
                      ),
                    )
                  else
                    ...List.generate(_filteredDevices.length, (i) {
                      final d = _filteredDevices[i];
                      final cColor = d.isGoodCondition ? _green : _red;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 10,
                        ),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: _field, width: 1),
                          ),
                        ),
                        child: buildRow([
                          SizedBox(
                            width: wId,
                            child: Text(
                              d.deviceId,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: ssz,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: wName,
                            child: Text(
                              d.deviceName ?? d.deviceId,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: ssz,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: wCond,
                            child: Text(
                              d.condition ?? '—',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: cColor,
                                fontSize: ssz,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: wHub,
                            child: Text(
                              _hubNameById(d.hubId),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: ssz,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: wAct,
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                _ActBtn(
                                  'Edit',
                                  _green,
                                  Icons.edit,
                                  () => showEditDeviceDialog(
                                    ctx,
                                    existing: d.toJson().map(
                                      (k, v) =>
                                          MapEntry(k, v?.toString() ?? ''),
                                    ),
                                    onSave: (updated) async {
                                      final ri = _devices.indexWhere(
                                        (x) => x.id == d.id,
                                      );
                                      if (ri != -1)
                                        setState(
                                          () => _devices[ri] = d.copyWith(
                                            deviceName: updated['deviceName'],
                                            condition: updated['condition'],
                                          ),
                                        );
                                      try {
                                        final res =
                                            await SuperAdminService.updateDevice(
                                              deviceId: d.id,
                                              deviceName:
                                                  updated['deviceName'] ?? '',
                                              condition:
                                                  updated['condition'] ?? '',
                                            );
                                        if (res['success'] == true) {
                                          await _loadAll();
                                          if (mounted)
                                            ScaffoldMessenger.of(
                                              ctx,
                                            ).showSnackBar(
                                              const SnackBar(
                                                backgroundColor: _green,
                                                content: Text(
                                                  'Device updated successfully',
                                                  style: TextStyle(
                                                    color: Colors.black,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                duration: Duration(seconds: 2),
                                              ),
                                            );
                                        } else {
                                          if (ri != -1)
                                            setState(() => _devices[ri] = d);
                                          if (mounted)
                                            ScaffoldMessenger.of(
                                              ctx,
                                            ).showSnackBar(
                                              SnackBar(
                                                backgroundColor: _red,
                                                content: Text(
                                                  res['message'] ??
                                                      'Update failed',
                                                ),
                                              ),
                                            );
                                        }
                                      } catch (e) {
                                        if (ri != -1)
                                          setState(() => _devices[ri] = d);
                                        if (mounted)
                                          ScaffoldMessenger.of(
                                            ctx,
                                          ).showSnackBar(
                                            SnackBar(
                                              backgroundColor: _red,
                                              content: Text('Error: $e'),
                                            ),
                                          );
                                      }
                                    },
                                  ),
                                ),
                                _ActBtn(
                                  'View',
                                  _blue,
                                  Icons.remove_red_eye,
                                  () => Navigator.push(
                                    ctx,
                                    MaterialPageRoute(
                                      builder: (_) => DeviceDetailsScreen(
                                        device: d.toJson().map(
                                          (k, v) =>
                                              MapEntry(k, v?.toString() ?? ''),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                _ActBtn(
                                  'Assign',
                                  _orange,
                                  Icons.link,
                                  () => showAssignDeviceDialog(
                                    ctx,
                                    hubs: _hubList
                                        .map((h) => h.hubName)
                                        .toList(),
                                    onAssign: (hubName) async {
                                      final hub = _hubList.firstWhere(
                                        (h) => h.hubName == hubName,
                                        orElse: () =>
                                            HubModel(id: 0, hubName: hubName),
                                      );
                                      if (hub.id != 0) {
                                        final res =
                                            await SuperAdminService.assignDeviceToHub(
                                              hubId: hub.id,
                                              deviceId: d.deviceId,
                                            );
                                        final ri = _devices.indexWhere(
                                          (x) => x.id == d.id,
                                        );
                                        if (res.success && ri != -1) {
                                          setState(
                                            () => _devices[ri] = d.withHub(
                                              hub.id,
                                            ),
                                          );
                                        } else if (mounted) {
                                          ScaffoldMessenger.of(
                                            ctx,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                res.message ?? 'Assign failed',
                                              ),
                                            ),
                                          );
                                        }
                                      }
                                    },
                                  ),
                                ),
                                _ActBtn(
                                  'Delete',
                                  _red,
                                  Icons.delete,
                                  () => _confirmDelete(ctx, 'Device', () async {
                                    final ci = _devices.indexWhere(
                                      (x) => x.id == d.id,
                                    );
                                    if (ci == -1) return;
                                    final removed = _devices[ci];
                                    setState(() => _devices.removeAt(ci));
                                    final res =
                                        await SuperAdminService.deleteDevice(
                                          removed.id,
                                        );
                                    if (res['success'] != true) {
                                      setState(
                                        () => _devices.insert(ci, removed),
                                      );
                                      if (mounted) {
                                        final raw =
                                            res['message']?.toString() ?? '';
                                        final isFK =
                                            raw.toLowerCase().contains(
                                              'foreign key',
                                            ) ||
                                            raw.toLowerCase().contains(
                                              'wash',
                                            ) ||
                                            raw.toLowerCase().contains(
                                              'constraint',
                                            );
                                        _showBlockedDeleteDialog(
                                          ctx,
                                          isFK
                                              ? 'This device has wash history records and cannot be deleted.\n\n'
                                                    'Remove or reassign its wash history from the Usage History tab first.'
                                              : (raw.isNotEmpty
                                                    ? raw
                                                    : 'Failed to delete device.'),
                                        );
                                      }
                                    }
                                  }),
                                ),
                              ],
                            ),
                          ),
                        ]),
                      );
                    }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          LayoutBuilder(
            builder: (context, constraints) {
              final tw = constraints.maxWidth;
              final thumbW = (_monThumbFraction * tw).clamp(20.0, tw);
              final thumbL = _monThumbOffset * tw;
              return GestureDetector(
                onTapDown: (d) {
                  if (!_monScrollCtrl.hasClients) return;
                  final max = _monScrollCtrl.position.maxScrollExtent;
                  _monScrollCtrl.jumpTo(
                    ((d.localPosition.dx / tw).clamp(0.0, 1.0) * max).clamp(
                      0.0,
                      max,
                    ),
                  );
                },
                onHorizontalDragUpdate: (d) {
                  if (!_monScrollCtrl.hasClients) return;
                  final max = _monScrollCtrl.position.maxScrollExtent;
                  final delta =
                      d.delta.dx /
                      tw *
                      max /
                      (1.0 - _monThumbFraction).clamp(0.001, 1.0);
                  _monScrollCtrl.jumpTo(
                    (_monScrollCtrl.offset + delta).clamp(0.0, max),
                  );
                },
                child: SizedBox(
                  height: 4,
                  width: tw,
                  child: Stack(
                    children: [
                      Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: _field,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      Positioned(
                        left: thumbL,
                        child: Container(
                          width: thumbW,
                          height: 4,
                          decoration: BoxDecoration(
                            color: _blue,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          SizedBox(height: gap),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {},
                child: Row(
                  children: [
                    const Icon(Icons.show_chart, color: _blue, size: 15),
                    const SizedBox(width: 4),
                    Text(
                      'Fleet Uptime Report',
                      style: TextStyle(color: _blue, fontSize: ssz),
                    ),
                  ],
                ),
              ),
              _Btn(
                label: '+ Add Device',
                onTap: () => _showAddDeviceDialog(
                  ctx,
                  ssz,
                  onAdd: (map) async {
                    final res = await SuperAdminService.addDevice(
                      deviceId: map['deviceId'] ?? '',
                    );
                    if (res['success'] == true) {
                      await _loadAll();
                    } else if (mounted) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(
                          content: Text(
                            res['message'] ?? 'Failed to add device',
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── History ───────────────────────────────────────────────────────────────
  Widget _buildHistory(
    BuildContext ctx,
    double gap,
    double ssz,
    double lsz,
  ) => _Card(
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
          value: _useHubFilter?.hubName ?? '-- All Hubs --',
          items: _hubNames,
          fsz: ssz,
          onChanged: (v) => setState(() {
            _useHubFilter = v == '-- All Hubs --'
                ? null
                : _hubList.firstWhere(
                    (h) => h.hubName == v,
                    orElse: () => HubModel(id: 0, hubName: v ?? ''),
                  );
          }),
        ),
        SizedBox(height: gap * 0.6),
        DropdownButtonHideUnderline(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: _field,
              borderRadius: BorderRadius.circular(10),
            ),
            child: DropdownButton<String?>(
              value: _useUserFilter?.id.toString(),
              isExpanded: true,
              dropdownColor: _field,
              style: TextStyle(
                color: Colors.white,
                fontSize: ssz,
                fontFamily: 'Poppins',
              ),
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white,
                size: 16,
              ),
              isDense: true,
              onChanged: (v) => setState(() {
                _useUserFilter = (v == null)
                    ? null
                    : _users.firstWhere(
                        (u) => u.id.toString() == v,
                        orElse: () => UserModel(id: 0, name: '', mobile: ''),
                      );
              }),
              items: [
                DropdownMenuItem<String?>(
                  value: null,
                  child: Text(
                    '-- All Users --',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: ssz,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
                ..._users.map(
                  (u) => DropdownMenuItem<String?>(
                    value: u.id.toString(),
                    child: Text(
                      _userDisplayName(u),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: ssz,
                        fontFamily: 'Poppins',
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: gap),
        _HScroll(
          totalWidth: _wOrd + _wTxDev + _wTxName + _wDate + _wAmt + _wUser + 40,
          header: _hrow(lsz, [
            _hc('ORDER ID', _wOrd),
            _hc('DEVICE ID', _wTxDev),
            _hc('DEVICE NAME', _wTxName),
            _hc('TIME / DATE', _wDate),
            _hc('AMOUNT', _wAmt),
            _hc('USER NAME', _wUser),
          ]),
          rows: _filteredWash
              .map(
                (w) => _drow(ssz, [
                  _dc('${w.orderId ?? w.id}', _wOrd),
                  _dc(
                    w.device?.deviceId ??
                        _deviceStringIdById(w.deviceId) ??
                        '—',
                    _wTxDev,
                    bold: true,
                  ),
                  _dc(
                    w.device?.deviceName ??
                        _deviceNameById(w.deviceId) ??
                        w.packageName ??
                        '—',
                    _wTxName,
                    bold: true,
                  ),
                  _dc(_formatDate(w.createdAt), _wDate),
                  SizedBox(
                    width: _wAmt,
                    child: Text(
                      '₹ ${(w.finalAmount ?? w.amount ?? 0).toStringAsFixed(2)}',
                      style: TextStyle(
                        color: _green,
                        fontSize: ssz,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _dc(w.user?.name ?? _userNameById(w.userId) ?? '—', _wUser),
                ]),
              )
              .toList(),
        ),
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
  );

  // ── Tickets ───────────────────────────────────────────────────────────────
  Widget _buildTickets(BuildContext ctx, double gap, double ssz, double lsz) =>
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
              value: _svcHubFilter?.hubName ?? '-- All Hubs --',
              items: ['-- All Hubs --', ..._hubList.map((h) => h.hubName)],
              fsz: ssz,
              onChanged: (v) => setState(() {
                _svcHubFilter = (v == null || v == '-- All Hubs --')
                    ? null
                    : _hubList.firstWhere(
                        (h) => h.hubName == v,
                        orElse: () => HubModel(id: 0, hubName: v),
                      );
              }),
            ),
            SizedBox(height: gap),
            if (_filteredSvcRequests.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'No service requests found',
                    style: TextStyle(color: _dim, fontSize: ssz),
                  ),
                ),
              )
            else
              _HScroll(
                totalWidth:
                    _wTktId +
                    _wSvcHub +
                    _wSvcOwn +
                    _wCat +
                    _wSts +
                    _wSvcAct +
                    40,
                header: _hrow(lsz, [
                  _hc('TICKET ID', _wTktId),
                  _hc('HUB', _wSvcHub),
                  _hc('OWNER', _wSvcOwn),
                  _hc('CATEGORY', _wCat),
                  _hc('STATUS', _wSts),
                  _hc('ACTION', _wSvcAct),
                ]),
                rows: _filteredSvcRequests.map((sr) {
                  final isLoading = _svcLoadingIds.contains(sr.id);
                  return _drow(ssz, [
                    _dc('${sr.id}', _wTktId),
                    _dc(sr.hub?.hubName ?? _hubNameById(sr.hubId), _wSvcHub),
                    _dc(
                      sr.hubOwner?.mobile ??
                          (sr.ownerId != null ? 'Owner #${sr.ownerId}' : '—'),
                      _wSvcOwn,
                    ),
                    _dc(
                      sr.issueCategory ?? sr.description ?? '—',
                      _wCat,
                      bold: true,
                    ),
                    SizedBox(
                      width: _wSts,
                      child: _StatusBadge(
                        _statusLabel(sr.status),
                        _statusColor(sr),
                        ssz - 2,
                      ),
                    ),
                    SizedBox(
                      width: _wSvcAct,
                      child: isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: _cyan,
                                strokeWidth: 2,
                              ),
                            )
                          : Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: [
                                if (sr.isPending) ...[
                                  _SvcBtn(
                                    'Start',
                                    _cyan,
                                    () => _updateSvcStatus(sr, 'in_progress'),
                                  ),
                                  _SvcBtn(
                                    'Complete',
                                    _green,
                                    () => _updateSvcStatus(sr, 'completed'),
                                  ),
                                ],
                                if (sr.isInProgress)
                                  _SvcBtn(
                                    'Complete',
                                    _green,
                                    () => _updateSvcStatus(sr, 'completed'),
                                  ),
                                if (sr.isCompleted)
                                  Text(
                                    '✓ Done',
                                    style: TextStyle(
                                      color: _green,
                                      fontSize: ssz - 1,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                              ],
                            ),
                    ),
                  ]);
                }).toList(),
              ),
          ],
        ),
      );

  String _formatDate(String? raw) {
    if (raw == null) return '—';
    try {
      final dt = DateTime.parse(raw).toLocal();
      final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      final m = dt.minute.toString().padLeft(2, '0');
      final ap = dt.hour >= 12 ? 'pm' : 'am';
      return '${dt.day}/${dt.month}/${dt.year}, $h:$m $ap';
    } catch (_) {
      return raw;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  ERROR VIEW
// ─────────────────────────────────────────────────────────────────────────────
class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off, color: _red, size: 48),
          const SizedBox(height: 16),
          Text(
            error,
            textAlign: TextAlign.center,
            style: const TextStyle(color: _dim, fontSize: 13),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: _blue),
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Retry'),
          ),
        ],
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
//  TABLE HELPERS
// ─────────────────────────────────────────────────────────────────────────────
Widget _hrow(double lsz, List<Widget> cells) => Container(
  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
  decoration: BoxDecoration(
    color: _field,
    borderRadius: BorderRadius.circular(8),
  ),
  child: Row(
    children: cells.expand((w) => [w, const SizedBox(width: 8)]).toList()
      ..removeLast(),
  ),
);

Widget _hc(String text, double width) => SizedBox(
  width: width,
  child: Text(
    text,
    overflow: TextOverflow.ellipsis,
    maxLines: 2,
    style: const TextStyle(
      color: _dim,
      fontSize: 11,
      fontWeight: FontWeight.bold,
      letterSpacing: 0.3,
    ),
  ),
);

Widget _thc(String text, double width) => SizedBox(
  width: width,
  child: Text(
    text,
    overflow: TextOverflow.ellipsis,
    maxLines: 2,
    style: const TextStyle(
      color: _dim,
      fontSize: 11,
      fontWeight: FontWeight.bold,
      letterSpacing: 0.3,
    ),
  ),
);

Widget _drow(double ssz, List<Widget> cells) => Container(
  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
  decoration: const BoxDecoration(
    border: Border(bottom: BorderSide(color: _field, width: 1)),
  ),
  child: Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: cells.expand((w) => [w, const SizedBox(width: 8)]).toList()
      ..removeLast(),
  ),
);

Widget _dc(String text, double width, {bool bold = false}) => SizedBox(
  width: width,
  child: Text(
    text,
    overflow: TextOverflow.ellipsis,
    maxLines: 2,
    style: TextStyle(
      color: Colors.white,
      fontSize: 12,
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
    ),
  ),
);

// ─────────────────────────────────────────────────────────────────────────────
//  _HScroll
// ─────────────────────────────────────────────────────────────────────────────
class _HScroll extends StatefulWidget {
  final double totalWidth;
  final Widget header;
  final List<Widget> rows;
  const _HScroll({
    required this.totalWidth,
    required this.header,
    required this.rows,
  });

  @override
  State<_HScroll> createState() => _HScrollState();
}

class _HScrollState extends State<_HScroll> {
  final ScrollController _ctrl = ScrollController();
  double _thumbFraction = 0.0;
  double _thumbOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _onScroll());
  }

  void _onScroll() {
    if (!_ctrl.hasClients) return;
    final max = _ctrl.position.maxScrollExtent;
    final view = _ctrl.position.viewportDimension;
    final total = max + view;
    if (!mounted) return;
    setState(() {
      _thumbFraction = total > 0 ? (view / total).clamp(0.0, 1.0) : 1.0;
      _thumbOffset = max > 0
          ? (_ctrl.offset / max * (1.0 - _thumbFraction)).clamp(
              0.0,
              1.0 - _thumbFraction,
            )
          : 0.0;
    });
  }

  @override
  void dispose() {
    _ctrl.removeListener(_onScroll);
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final needsScroll = widget.totalWidth > sw - 56;

    if (!needsScroll) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [widget.header, ...widget.rows],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          controller: _ctrl,
          scrollDirection: Axis.horizontal,
          physics: const ClampingScrollPhysics(),
          child: SizedBox(
            width: widget.totalWidth + 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [widget.header, ...widget.rows],
            ),
          ),
        ),
        const SizedBox(height: 6),
        LayoutBuilder(
          builder: (context, constraints) {
            final tw = constraints.maxWidth;
            final thumbW = (_thumbFraction * tw).clamp(20.0, tw);
            final thumbL = _thumbOffset * tw;
            return GestureDetector(
              onTapDown: (d) {
                if (!_ctrl.hasClients) return;
                final max = _ctrl.position.maxScrollExtent;
                _ctrl.jumpTo(
                  ((d.localPosition.dx / tw).clamp(0.0, 1.0) * max).clamp(
                    0.0,
                    max,
                  ),
                );
              },
              onHorizontalDragUpdate: (d) {
                if (!_ctrl.hasClients) return;
                final max = _ctrl.position.maxScrollExtent;
                final delta =
                    d.delta.dx /
                    tw *
                    max /
                    (1.0 - _thumbFraction).clamp(0.001, 1.0);
                _ctrl.jumpTo((_ctrl.offset + delta).clamp(0.0, max));
              },
              child: SizedBox(
                height: 4,
                width: tw,
                child: Stack(
                  children: [
                    Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: _field,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    Positioned(
                      left: thumbL,
                      child: Container(
                        width: thumbW,
                        height: 4,
                        decoration: BoxDecoration(
                          color: _blue,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  REUSABLE WIDGETS
// ─────────────────────────────────────────────────────────────────────────────
class _ActBtn extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;
  const _ActBtn(this.label, this.color, this.icon, this.onTap);

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 12),
        const SizedBox(width: 2),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            decoration: TextDecoration.underline,
            decorationColor: color,
          ),
        ),
      ],
    ),
  );
}

class _SvcBtn extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _SvcBtn(this.label, this.color, this.onTap);

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _bg,
        border: Border.all(color: color, width: 1.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}

class _StatusBadge extends StatelessWidget {
  final String text;
  final Color color;
  final double fsz;
  const _StatusBadge(this.text, this.color, this.fsz);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(6),
    ),
    child: Text(
      text,
      textAlign: TextAlign.center,
      maxLines: 1,
      overflow: TextOverflow.visible,
      style: TextStyle(
        color: Colors.white,
        fontSize: fsz - 1,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.3,
      ),
    ),
  );
}

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
        child: Container(
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
