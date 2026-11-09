import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../config/theme.dart';
import '../models/delivery.dart';
import '../services/api_service.dart';
import '../services/api_exception.dart';

class RoutesPage extends StatefulWidget {
  const RoutesPage({super.key});

  @override
  State<RoutesPage> createState() => _RoutesPageState();
}

class _RoutesPageState extends State<RoutesPage> {
  final ApiService _api = ApiService();
  final MapController _mapController = MapController();

  LatLng _currentPosition = const LatLng(-6.2088, 106.8456);
  bool _isLoadingLocation = true;
  String? _locationError;

  List<Delivery> _activeDeliveries = [];
  Delivery? _selectedDelivery;
  bool _isLoadingDeliveries = true;
  bool _isCompleting = false;

  // State untuk Rute OSRM
  List<LatLng> _routePoints = [];
  bool _isLoadingRoute = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadActiveDeliveries();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _locationError = null;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Layanan lokasi tidak aktif. Aktifkan GPS.');
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Izin lokasi ditolak');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception(
          'Izin lokasi diblokir permanen. Buka pengaturan aplikasi.',
        );
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      ).timeout(const Duration(seconds: 15));

      if (!mounted) return;
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _isLoadingLocation = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _mapController.move(_currentPosition, 15);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _locationError = e.toString().replaceFirst('Exception: ', '');
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _loadActiveDeliveries() async {
    setState(() => _isLoadingDeliveries = true);

    try {
      final deliveries = await _api.getDeliveries();
      final active = deliveries
          .where(
            (d) =>
                d.claimStatus == 'completed' &&
                d.shippingLat != null &&
                d.shippingLng != null,
          )
          .toList();

      if (!mounted) return;

      setState(() {
        _activeDeliveries = active;
        if (_selectedDelivery != null &&
            active.any((d) => d.id == _selectedDelivery!.id)) {
          _selectedDelivery = active.firstWhere(
            (d) => d.id == _selectedDelivery!.id,
          );
        } else {
          _selectedDelivery = active.isNotEmpty ? active.first : null;
        }
        _isLoadingDeliveries = false;
      });

      final target = _targetLatLng;
      if (target != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _mapController.move(target, 14);
          _fetchRoute(_currentPosition, target);
        });
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingDeliveries = false);
      _showSnackBar(e.message, warningOrange);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingDeliveries = false);
      _showSnackBar('Gagal memuat rute: $e', brandRed);
    }
  }

  Future<void> _fetchRoute(LatLng start, LatLng end) async {
    setState(() {
      _isLoadingRoute = true;
      _routePoints = [];
    });

    try {
      // OSRM API
      final url = Uri.parse(
        'http://router.project-osrm.org/route/v1/driving/'
        '${start.longitude},${start.latitude};${end.longitude},${end.latitude}'
        '?overview=full&geometries=geojson',
      );

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final routes = data['routes'] as List;
        if (routes.isNotEmpty) {
          final geometry = routes[0]['geometry']['coordinates'] as List;
          final points = geometry
              .map(
                (coord) => LatLng(
                  (coord[1] as num).toDouble(),
                  (coord[0] as num).toDouble(),
                ),
              )
              .toList();

          if (!mounted) return;
          setState(() {
            _routePoints = points;
            _isLoadingRoute = false;
          });

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            _mapController.fitCamera(
              CameraFit.coordinates(
                coordinates: points,
                padding: const EdgeInsets.all(50),
              ),
            );
          });
        }
      }
    } catch (e) {
      debugPrint('[RoutesPage] Gagal fetch route: $e');
      if (mounted) {
        setState(() => _isLoadingRoute = false);
        _showSnackBar('Gagal memuat rute jalan', warningOrange);
      }
    }
  }

  LatLng? get _targetLatLng {
    final d = _selectedDelivery;
    if (d?.shippingLat == null || d?.shippingLng == null) return null;
    return LatLng(d!.shippingLat!, d.shippingLng!);
  }

  Future<void> _openNavigation() async {
    final target = _targetLatLng;
    if (target == null) {
      _showSnackBar('Belum ada tujuan aktif', warningOrange);
      return;
    }
    await _fetchRoute(_currentPosition, target);
  }

  Future<void> _showDeliveryPicker() async {
    if (_activeDeliveries.isEmpty) return;

    final selected = await showModalBottomSheet<Delivery>(
      context: context,
      backgroundColor: surfaceDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: surfaceLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.list, color: brandRed),
                  const SizedBox(width: 8),
                  Text(
                    'Pilih Pengantaran (${_activeDeliveries.length})',
                    style: const TextStyle(
                      color: textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(color: surfaceLight, height: 1),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: _activeDeliveries.length,
                separatorBuilder: (_, index) =>
                    const Divider(color: surfaceLight, height: 1),
                itemBuilder: (_, i) {
                  final d = _activeDeliveries[i];
                  final isSelected = d.id == _selectedDelivery?.id;
                  return ListTile(
                    onTap: () => Navigator.pop(ctx, d),
                    leading: Icon(
                      Icons.delivery_dining,
                      color: isSelected ? courierGreen : brandRed,
                    ),
                    title: Text(
                      d.orderNumber.isNotEmpty
                          ? d.orderNumber
                          : 'Delivery #${d.id}',
                      style: TextStyle(
                        color: textPrimary,
                        fontWeight: isSelected
                            ? FontWeight.w900
                            : FontWeight.w600,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (d.receiverName != null &&
                            d.receiverName!.isNotEmpty)
                          Text(
                            'Penerima: ${d.receiverName}',
                            style: const TextStyle(
                              color: textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        if (d.address != null && d.address!.isNotEmpty)
                          Text(
                            d.address!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        Text(
                          '${d.shippingDistanceKm.toStringAsFixed(1)} km'
                          '${d.city != null && d.city!.isNotEmpty ? ' • ${d.city}' : ''}',
                          style: const TextStyle(
                            color: textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle, color: courierGreen)
                        : null,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );

    if (selected == null || !mounted) return;

    setState(() {
      _selectedDelivery = selected;
      _routePoints = [];
    });

    final lat = selected.shippingLat;
    final lng = selected.shippingLng;
    if (lat != null && lng != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _mapController.move(LatLng(lat, lng), 15);
        _fetchRoute(_currentPosition, LatLng(lat, lng));
      });
    }
  }

  Future<void> _completeDelivery() async {
    final target = _selectedDelivery;
    if (target == null) {
      _showSnackBar('Belum ada pengantaran terpilih', warningOrange);
      return;
    }

    final orderLabel = target.orderNumber.isNotEmpty
        ? target.orderNumber
        : 'Delivery #${target.id}';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: surfaceDark,
        title: const Text(
          'Selesaikan Pengantaran?',
          style: TextStyle(color: textPrimary),
        ),
        content: Text(
          'Order $orderLabel akan ditandai selesai.',
          style: const TextStyle(color: textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('BATAL', style: TextStyle(color: textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('SELESAIKAN', style: TextStyle(color: brandRed)),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _isCompleting = true);

    try {
      await _api.completeRoute(target.publicId);
      if (!mounted) return;
      _showSnackBar('Pengantaran $orderLabel selesai', courierGreen);
      await _loadActiveDeliveries();
    } on ApiException catch (e) {
      debugPrint('[RoutesPage] completeRoute ApiException: ${e.message}');
      if (!mounted) return;
      setState(() {
        _activeDeliveries.removeWhere((d) => d.id == target.id);
        _selectedDelivery = _activeDeliveries.isNotEmpty
            ? _activeDeliveries.first
            : null;
        _routePoints = [];
      });
      _showSnackBar('Pengantaran $orderLabel selesai (lokal)', courierGreen);
    } catch (e) {
      debugPrint('[RoutesPage] completeRoute error: $e');
      if (!mounted) return;
      setState(() {
        _activeDeliveries.removeWhere((d) => d.id == target.id);
        _selectedDelivery = _activeDeliveries.isNotEmpty
            ? _activeDeliveries.first
            : null;
        _routePoints = [];
      });
      _showSnackBar('Pengantaran $orderLabel selesai (lokal)', courierGreen);
    } finally {
      if (mounted) setState(() => _isCompleting = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        title: const Text(
          'NAVIGASI RUTE',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1),
        ),
        backgroundColor: bgDark,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: textPrimary),
            tooltip: 'Muat ulang',
            onPressed: () async {
              await Future.wait([
                _getCurrentLocation(),
                _loadActiveDeliveries(),
              ]);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_locationError != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: brandRed.withValues(alpha: 0.15),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: brandRed, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _locationError!,
                      style: const TextStyle(color: textPrimary, fontSize: 12),
                    ),
                  ),
                  if (_locationError!.toLowerCase().contains('diblokir'))
                    TextButton(
                      onPressed: Geolocator.openAppSettings,
                      child: const Text(
                        'PENGATURAN',
                        style: TextStyle(
                          color: brandRed,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: surfaceLight),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _currentPosition,
                        initialZoom: 14,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                          userAgentPackageName: 'com.nusadhipa.courier',
                        ),

                        // GARIS RUTE OSRM (Diperbaiki untuk Flutter Map v8)
                        if (_routePoints.isNotEmpty)
                          PolylineLayer<Object>(
                            polylines: [
                              Polyline(
                                points: _routePoints,
                                strokeWidth: 6,
                                color: courierBlue,
                              ),
                            ],
                          )
                        else if (_targetLatLng != null)
                          PolylineLayer<Object>(
                            polylines: [
                              Polyline(
                                points: [_currentPosition, _targetLatLng!],
                                strokeWidth: 3,
                                color: brandRed.withValues(alpha: 0.5),
                              ),
                            ],
                          ),

                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _currentPosition,
                              width: 80,
                              height: 80,
                              child: const Icon(
                                Icons.location_on,
                                color: brandRed,
                                size: 40,
                              ),
                            ),
                            ..._activeDeliveries.map((d) {
                              final lat = d.shippingLat!;
                              final lng = d.shippingLng!;
                              final isSelected = d.id == _selectedDelivery?.id;
                              return Marker(
                                point: LatLng(lat, lng),
                                width: 80,
                                height: 80,
                                alignment: Alignment.topCenter,
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    setState(() => _selectedDelivery = d);
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                          if (!mounted) return;
                                          _mapController.move(
                                            LatLng(lat, lng),
                                            15,
                                          );
                                          _fetchRoute(
                                            _currentPosition,
                                            LatLng(lat, lng),
                                          );
                                        });
                                  },
                                  child: Icon(
                                    Icons.flag,
                                    color: isSelected
                                        ? courierGreen
                                        : warningOrange,
                                    size: isSelected ? 44 : 36,
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                      ],
                    ),
                    Positioned(
                      top: 16,
                      left: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: surfaceDark.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: surfaceLight),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _activeDeliveries.isEmpty
                                  ? Icons.info_outline
                                  : Icons.delivery_dining,
                              color: _activeDeliveries.isEmpty
                                  ? warningOrange
                                  : brandRed,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Rute Aktif',
                                    style: TextStyle(
                                      color: textSecondary,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    _isLoadingDeliveries
                                        ? 'Memuat...'
                                        : _activeDeliveries.isEmpty
                                        ? 'Belum ada pengantaran'
                                        : '${_activeDeliveries.length} Pesanan Siap Diantar',
                                    style: const TextStyle(
                                      color: textPrimary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_isLoadingDeliveries)
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: brandRed,
                                ),
                              )
                            else if (_activeDeliveries.isNotEmpty)
                              IconButton(
                                icon: const Icon(Icons.list, color: brandRed),
                                tooltip: 'Pilih pengantaran',
                                onPressed: _showDeliveryPicker,
                              ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 16,
                      bottom: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: surfaceDark.withValues(alpha: 0.92),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: surfaceLight),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.gps_fixed,
                              color: courierGreen,
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${_currentPosition.latitude.toStringAsFixed(4)}, ${_currentPosition.longitude.toStringAsFixed(4)}',
                              style: const TextStyle(
                                color: textPrimary,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_isLoadingLocation)
                      Container(
                        color: Colors.black.withValues(alpha: 0.5),
                        child: const Center(
                          child: CircularProgressIndicator(color: brandRed),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed:
                        _targetLatLng == null ||
                            _isCompleting ||
                            _isLoadingDeliveries ||
                            _isLoadingRoute
                        ? null
                        : _openNavigation,
                    icon: _isLoadingRoute
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.navigation, color: Colors.white),
                    label: Text(
                      _isLoadingRoute ? 'MEMUAT RUTE...' : 'TAMPILKAN RUTE',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: courierBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: _isCompleting
                              ? null
                              : () async {
                                  await Future.wait([
                                    _getCurrentLocation(),
                                    _loadActiveDeliveries(),
                                  ]);
                                  if (!mounted) return;
                                  _showSnackBar(
                                    'Lokasi & rute diperbarui',
                                    courierGreen,
                                  );
                                },
                          icon: const Icon(Icons.update, color: Colors.white),
                          label: const Text(
                            'UPDATE',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: warningOrange,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: _selectedDelivery == null || _isCompleting
                              ? null
                              : _completeDelivery,
                          icon: _isCompleting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(
                                  Icons.check_circle,
                                  color: Colors.white,
                                ),
                          label: Text(
                            _isCompleting ? 'PROSES...' : 'SELESAIKAN',
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: courierGreen,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
