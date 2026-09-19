import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/field_zone.dart';
import '../core/theme.dart';
import '../screens/crop_quotation_screen.dart';

class InteractiveFieldMap extends StatefulWidget {
  final List<FieldZone> zones;
  final int selectedIndex;
  final ValueChanged<int> onZoneSelected;
  final double totalFarmAcres;

  const InteractiveFieldMap({
    super.key,
    required this.zones,
    required this.selectedIndex,
    required this.onZoneSelected,
    this.totalFarmAcres = 8.5,
  });

  @override
  State<InteractiveFieldMap> createState() => _InteractiveFieldMapState();
}

class _InteractiveFieldMapState extends State<InteractiveFieldMap> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _showHeatmap = true;
  bool _showNodes = true;
  bool _isGpsStandHereActive = false;
  int _standingZoneIndex = 1; // Default standing in South Field (Zone 2)
  String _mapStatusMessage = "Touch any acre parcel or tap 'Stand Here' to map metrics.";

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _onTapParcel(int index) {
    widget.onZoneSelected(index);
    setState(() {
      _mapStatusMessage = "Selected: ${widget.zones[index].name} • Telemetry mapped below";
    });
  }

  void _locateFarmerPosition() {
    // Simulates GPS locking to the farmer's standing position in the field
    setState(() {
      _isGpsStandHereActive = true;
      _standingZoneIndex = widget.selectedIndex;
      _mapStatusMessage = "GPS Locked: You are standing in ${widget.zones[_standingZoneIndex].name}";
    });

    widget.onZoneSelected(_standingZoneIndex);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.my_location_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Mapped 8.5-Acre field telemetry to your standing position: ${widget.zones[_standingZoneIndex].name}',
                style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF065F46),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Color _getMoistureColor(double moisture, ZoneStatus status) {
    if (status == ZoneStatus.critical || moisture < 26.0) {
      return const Color(0xFFF59E0B); // Arid amber / water stress
    } else if (moisture > 35.0) {
      return const Color(0xFF0284C7); // High moisture / retentive
    } else {
      return const Color(0xFF10B981); // Healthy emerald vegetative moisture
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeZone = widget.zones[widget.selectedIndex.clamp(0, widget.zones.length - 1)];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE5EAE5)),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Map Header & Controls
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.map_rounded, size: 16, color: AppTheme.primaryGreen),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'INTERACTIVE ACREAGE MAP',
                              style: GoogleFonts.outfit(
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                                color: const Color(0xFF141F17),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Total Holding: ${widget.totalFarmAcres} Acres • 3 Monitored Plots',
                        style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF5A6E61)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Stand Here / GPS Locate Button
                ElevatedButton.icon(
                  onPressed: _locateFarmerPosition,
                  icon: Icon(
                    _isGpsStandHereActive ? Icons.my_location_rounded : Icons.location_searching_rounded,
                    size: 14,
                    color: Colors.white,
                  ),
                  label: Text(
                    _isGpsStandHereActive ? 'Standing Here' : 'Stand Here (GPS)',
                    style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isGpsStandHereActive ? const Color(0xFF0284C7) : AppTheme.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ),

          // 2. Interactive Graphical Map Canvas
          Container(
            height: 250,
            margin: const EdgeInsets.symmetric(horizontal: 12),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: const Color(0xFF1E2922),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFF2D3E33), width: 1.5),
            ),
            child: Stack(
              children: [
                // Topographic grid lines
                Positioned.fill(
                  child: CustomPaint(
                    painter: _FarmGridPainter(),
                  ),
                ),

                // Plot Layout: 3 Acres Sectors
                Positioned.fill(
                  child: Row(
                    children: [
                      // Left Column: North Field (Top) & South Field (Bottom)
                      Expanded(
                        flex: 6,
                        child: Column(
                          children: [
                            // North Field (3.5 Acres)
                            Expanded(
                              flex: 5,
                              child: _buildParcelTile(
                                index: 0,
                                zone: widget.zones[0],
                                shapeRadius: const BorderRadius.only(topLeft: Radius.circular(16)),
                              ),
                            ),
                            const Divider(height: 2, thickness: 2, color: Color(0xFF22382B)),
                            // South Field (2.5 Acres)
                            Expanded(
                              flex: 5,
                              child: _buildParcelTile(
                                index: 1,
                                zone: widget.zones[1],
                                shapeRadius: const BorderRadius.only(bottomLeft: Radius.circular(16)),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Irrigation Canal & Farm Trail Divider
                      Container(
                        width: 14,
                        color: const Color(0xFF0F1B14),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const Icon(Icons.water_rounded, size: 10, color: Color(0xFF38BDF8)),
                            RotatedBox(
                              quarterTurns: 3,
                              child: Text(
                                'IRRIGATION LINE',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 6.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.0,
                                  color: const Color(0xFF38BDF8).withValues(alpha: 0.7),
                                ),
                              ),
                            ),
                            const Icon(Icons.water_rounded, size: 10, color: Color(0xFF38BDF8)),
                          ],
                        ),
                      ),

                      // Right Column: East Field (Top) & West Plot (Bottom - Fallow)
                      Expanded(
                        flex: 5,
                        child: Column(
                          children: [
                            // East Field (2.5 Acres)
                            Expanded(
                              flex: 5,
                              child: _buildParcelTile(
                                index: 2,
                                zone: widget.zones[2],
                                shapeRadius: const BorderRadius.only(topRight: Radius.circular(16)),
                              ),
                            ),
                            const Divider(height: 2, thickness: 2, color: Color(0xFF22382B)),
                            // West Plot (1.5 Acres - Empty / Fallow) or fallback
                            Expanded(
                              flex: 5,
                              child: widget.zones.length > 3
                                  ? _buildParcelTile(
                                      index: 3,
                                      zone: widget.zones[3],
                                      shapeRadius: const BorderRadius.only(bottomRight: Radius.circular(16)),
                                    )
                                  : Container(
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF14241B),
                                        borderRadius: BorderRadius.only(bottomRight: Radius.circular(16)),
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // LoRa Master Central Gateway Badge
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.wifi_tethering_rounded, size: 11, color: Color(0xFF34D399)),
                        const SizedBox(width: 4),
                        Text(
                          'LoRa Mesh: 868 MHz',
                          style: GoogleFonts.plusJakartaSans(fontSize: 9, color: Colors.white70, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),

                // Layer Toggle Pills (Heatmap / Nodes)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => _showHeatmap = !_showHeatmap),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: _showHeatmap ? AppTheme.primaryGreen : Colors.black.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Heatmap',
                            style: GoogleFonts.plusJakartaSans(fontSize: 8.5, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => setState(() => _showNodes = !_showNodes),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: _showNodes ? const Color(0xFF0284C7) : Colors.black.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'IoT Nodes',
                            style: GoogleFonts.plusJakartaSans(fontSize: 8.5, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Standing Farmer GPS Pin Indicator
                if (_isGpsStandHereActive)
                  _buildFarmerStandingMarker(widget.zones[_standingZoneIndex]),
              ],
            ),
          ),

          // 3. Status Guidance Banner
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(
              children: [
                const Icon(Icons.touch_app_rounded, size: 15, color: AppTheme.primaryGreen),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _mapStatusMessage,
                    style: GoogleFonts.plusJakartaSans(fontSize: 12.5, fontWeight: FontWeight.w700, color: const Color(0xFF1F2937)),
                  ),
                ),
              ],
            ),
          ),

          // 4. Selected Acre Parcel Intelligence Card
          Container(
            margin: const EdgeInsets.fromLTRB(12, 6, 12, 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAF9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5EAE5)),
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: _getMoistureColor(activeZone.soilMoisturePct, activeZone.status).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.grass_rounded,
                    color: _getMoistureColor(activeZone.soilMoisturePct, activeZone.status),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              activeZone.name,
                              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF141F17)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: _getMoistureColor(activeZone.soilMoisturePct, activeZone.status).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              activeZone.statusHeadline.split('—').last.trim(),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: _getMoistureColor(activeZone.soilMoisturePct, activeZone.status),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        "${activeZone.crop} (${activeZone.variety}) • ${activeZone.stage} • ${activeZone.gpsCoordinates}",
                        style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w500, color: const Color(0xFF4B5E52)),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          _buildMiniMetric("Moisture", "${activeZone.soilMoisturePct.toStringAsFixed(1)}%"),
                          _buildMiniMetric("pH", activeZone.soilPh.toStringAsFixed(1)),
                          _buildMiniMetric("NPK", "${activeZone.nitrogenKgHa.toInt()}:${activeZone.phosphorusKgHa.toInt()}:${activeZone.potassiumKgHa.toInt()}"),
                          _buildMiniMetric("TinyML", activeZone.tinymlEdgeDecision.contains('Stress') ? 'Stress Alert' : (activeZone.tinymlEdgeDecision.contains('Fungal') ? 'Fungal Risk' : 'Normal')),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CropQuotationScreen(initialZoneId: activeZone.id),
                              ),
                            );
                          },
                          icon: const Icon(Icons.calculate_rounded, size: 16, color: Colors.white),
                          label: Text(
                            activeZone.isEmptyPlot
                                ? 'AI Sowing Quotation for Empty Plot →'
                                : 'Plan Crop Rotation / Financial Budget →',
                            style: GoogleFonts.outfit(
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: activeZone.isEmptyPlot ? const Color(0xFFD97706) : AppTheme.primaryGreen,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParcelTile({
    required int index,
    required FieldZone zone,
    required BorderRadius shapeRadius,
  }) {
    final isSelected = index == widget.selectedIndex;
    final isStanding = _isGpsStandHereActive && _standingZoneIndex == index;
    final moistureColor = _getMoistureColor(zone.soilMoisturePct, zone.status);

    return InkWell(
      onTap: () => _onTapParcel(index),
      borderRadius: shapeRadius,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          borderRadius: shapeRadius,
          color: _showHeatmap
              ? moistureColor.withValues(alpha: isSelected ? 0.38 : 0.22)
              : (isSelected ? const Color(0xFF065F46).withValues(alpha: 0.35) : const Color(0xFF14241B)),
          border: Border.all(
            color: isSelected ? const Color(0xFF34D399) : (isStanding ? const Color(0xFF38BDF8) : Colors.white24),
            width: isSelected ? 2.5 : 1.0,
          ),
        ),
        padding: const EdgeInsets.all(8),
        child: Stack(
          children: [
            // Parcel Details Label
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        "${zone.areaAcres.toStringAsFixed(1)} Ac",
                        style: GoogleFonts.outfit(fontSize: 10.5, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    if (isSelected)
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(color: Color(0xFF34D399), shape: BoxShape.circle),
                        child: const Icon(Icons.check, size: 10, color: Colors.black),
                      ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      zone.name.split('(')[0].trim(),
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: const [Shadow(blurRadius: 3, color: Colors.black)],
                      ),
                    ),
                    Text(
                      zone.isEmptyPlot
                          ? "EMPTY • Ready to Sow"
                          : "${zone.crop} • ${zone.soilMoisturePct.toStringAsFixed(0)}% Mst",
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: zone.isEmptyPlot ? const Color(0xFFFBBF24) : moistureColor,
                        shadows: const [Shadow(blurRadius: 3, color: Colors.black)],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // IoT Sensor Node Icon
            if (_showNodes)
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white30),
                  ),
                  child: Icon(
                    index == 0 ? Icons.settings_input_antenna_rounded : Icons.sensors_rounded,
                    size: 13,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFarmerStandingMarker(FieldZone zone) {
    // Places farmer marker based on parcel
    double top = 40;
    double left = 40;

    if (zone.id == "zone_1") {
      top = 50;
      left = 60;
    } else if (zone.id == "zone_2") {
      top = 160;
      left = 60;
    } else {
      top = 100;
      left = 220;
    }

    return Positioned(
      top: top,
      left: left,
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          final scale = 1.0 + (_pulseController.value * 0.25);
          return Transform.scale(
            scale: scale,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF0284C7),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0284C7).withValues(alpha: 0.5),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(Icons.person_pin_circle_rounded, size: 18, color: Colors.white),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMiniMetric(String label, String value) {
    return Row(
      children: [
        Text('$label: ', style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w600, color: const Color(0xFF4B5E52))),
        Text(value, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.w800, color: const Color(0xFF141F17))),
      ],
    );
  }
}

class _FarmGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2B3A30).withValues(alpha: 0.3)
      ..strokeWidth = 0.8;

    const step = 24.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
