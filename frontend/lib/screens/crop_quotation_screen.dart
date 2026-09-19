import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/farm_provider.dart';
import '../models/quotation_models.dart';
import '../models/field_zone.dart';
import '../core/theme.dart';
import '../core/app_localization.dart';
import '../widgets/language_toggle_chip.dart';

class CropQuotationScreen extends StatefulWidget {
  final String? initialZoneId;
  const CropQuotationScreen({super.key, this.initialZoneId});

  @override
  State<CropQuotationScreen> createState() => _CropQuotationScreenState();
}

class _CropQuotationScreenState extends State<CropQuotationScreen> {
  String _selectedZoneId = 'zone_4';
  double _areaAcres = 1.5;
  double _budgetInr = 100000.0;
  String _selectedSeason = 'Kharif';
  String? _customCropOverride;

  bool _isGenerating = false;
  CropQuotationResponseModel? _quotationResult;

  @override
  void initState() {
    super.initState();
    if (widget.initialZoneId != null) {
      _selectedZoneId = widget.initialZoneId!;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<FarmProvider>();
      if (provider.zones.isNotEmpty) {
        FieldZone targetZone;
        if (widget.initialZoneId != null &&
            provider.zones.any((z) => z.id.toLowerCase() == widget.initialZoneId!.toLowerCase())) {
          targetZone = provider.zones.firstWhere((z) => z.id.toLowerCase() == widget.initialZoneId!.toLowerCase());
        } else {
          // Default to empty/fallow parcel ready for sowing
          targetZone = provider.zones.firstWhere((z) => z.isEmptyPlot, orElse: () => provider.zones.first);
        }
        setState(() {
          _selectedZoneId = targetZone.id;
          _areaAcres = targetZone.areaAcres;
        });
      }
      _runQuotationEngine();
    });
  }

  Future<void> _runQuotationEngine() async {
    setState(() => _isGenerating = true);
    final provider = context.read<FarmProvider>();
    final res = await provider.generateCropQuotation(
      zoneId: _selectedZoneId,
      areaAcres: _areaAcres,
      budgetInr: _budgetInr,
      season: _selectedSeason,
      customCropSelection: _customCropOverride,
    );

    if (mounted) {
      setState(() {
        _quotationResult = res;
        _isGenerating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FarmProvider>();
    final isTamil = provider.isTamil;
    final zones = provider.zones;
    final currentZone = zones.firstWhere(
      (z) => z.id.toLowerCase() == _selectedZoneId.toLowerCase() ||
             z.name.toLowerCase().contains(_selectedZoneId.toLowerCase()),
      orElse: () => zones.isNotEmpty ? zones.first : FieldZone(
        id: "zone_1",
        name: "North Field",
        crop: "Paddy",
        variety: "Standard",
        stage: "Vegetative",
        areaAcres: 2.0,
        soilMoisturePct: 30.0,
        soilPh: 6.8,
        nitrogenKgHa: 140.0,
        phosphorusKgHa: 45.0,
        potassiumKgHa: 180.0,
        soilTempC: 28.0,
        airTempC: 32.0,
        humidityPct: 55.0,
        status: ZoneStatus.normal,
        statusHeadline: "Normal",
        statusReason: "Normal",
        recommendedAction: "Normal",
        gpsCoordinates: "18.52° N, 73.85° E",
        hardwareNode: "LoRa Gateway",
        relativeX: 0.3,
        relativeY: 0.3,
        soilTexture: "Clay Loam",
        batteryPct: 90,
        signalRssiDbm: -70,
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.primaryDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isTamil ? 'பயிர் நிதி & திட்ட மதிப்பீடு' : 'Smart Crop Financial Quotation',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryDark,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: Center(
              child: LanguageToggleChip(isCompact: true),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Zone Selection Hardware Cards
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalization.tr('select_quotation_zone', isTamil: isTamil),
                  style: GoogleFonts.outfit(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: const Color(0xFF4B5E52),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: currentZone.isEmptyPlot ? const Color(0xFFFFFBEB) : const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: currentZone.isEmptyPlot ? const Color(0xFFFDE68A) : const Color(0xFFBBF7D0),
                    ),
                  ),
                  child: Text(
                    currentZone.isEmptyPlot
                        ? AppLocalization.tr('empty_plot_active', isTamil: isTamil)
                        : AppLocalization.tr('occupied_plot_active', isTamil: isTamil),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      color: currentZone.isEmptyPlot ? const Color(0xFFB45309) : const Color(0xFF047857),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 135,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: zones.length,
                itemBuilder: (ctx, i) {
                  final z = zones[i];
                  final isSelected = z.id.toLowerCase() == _selectedZoneId.toLowerCase();
                  final isEmpty = z.isEmptyPlot;
                  final color = isEmpty
                      ? const Color(0xFFD97706)
                      : (i % 2 == 0 ? const Color(0xFF059669) : const Color(0xFF0284C7));

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedZoneId = z.id;
                        _areaAcres = z.areaAcres;
                        _customCropOverride = null;
                      });
                      _runQuotationEngine();
                    },
                    child: Container(
                      width: 245,
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? color : const Color(0xFFE5EAE5),
                          width: isSelected ? 2.2 : 1.0,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.18),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                )
                              ]
                            : AppTheme.cardShadow,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Icon(
                                      isEmpty ? Icons.landscape_rounded : Icons.grass_rounded,
                                      size: 16,
                                      color: color,
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        z.nameFor(isTamil),
                                        style: GoogleFonts.outfit(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: const Color(0xFF141F17),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected) ...[
                                const SizedBox(width: 4),
                                Icon(Icons.check_circle_rounded, size: 16, color: color),
                              ],
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                decoration: BoxDecoration(
                                  color: isEmpty ? const Color(0xFFFFFBEB) : const Color(0xFFF0FDF4),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: isEmpty ? const Color(0xFFFDE68A) : const Color(0xFFBBF7D0),
                                  ),
                                ),
                                child: Text(
                                  isEmpty
                                      ? (isTamil ? 'தரிசு • விதைக்க தயார்' : 'EMPTY • READY TO SOW')
                                      : (isTamil ? 'பயிரிடப்பட்டது • ${z.cropFor(true).split(' ')[0]}' : 'FILLED • ${z.cropFor(false).split(' ')[0]}'),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: isEmpty ? const Color(0xFFB45309) : const Color(0xFF047857),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  isTamil
                                      ? '${z.hardwareNodeLabel} • AI: ${z.tinymlEdgeDecision}'
                                      : '${z.hardwareNodeLabel} • TinyML: ${z.tinymlEdgeDecision}',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 9.5,
                                    color: const Color(0xFF5A6E61),
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${z.soilTextureFor(isTamil)} (pH ${z.soilPh}) • ${isTamil ? "ஈரப்பதம்" : "M"}: ${z.soilMoisturePct.toStringAsFixed(0)}%',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 14),

            // Dynamic Plot Cultivation Mode Banner (Empty vs Filled)
            _buildPlotContextBanner(currentZone, provider),
            const SizedBox(height: 14),


            // 2. Cultivation Area & Investment Capital Form
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE5EAE5)),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isTamil ? 'சாகுபடி பரப்பு' : 'Cultivation Area',
                        style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFD1FAE5)),
                        ),
                        child: Text(
                          '${_areaAcres.toStringAsFixed(1)} ${isTamil ? "ஏக்கர்" : "Acres"}',
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _areaAcres,
                    min: 0.5,
                    max: 10.0,
                    divisions: 19,
                    activeColor: AppTheme.primaryGreen,
                    onChanged: (val) {
                      setState(() => _areaAcres = val);
                      _runQuotationEngine();
                    },
                  ),
                  const Divider(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isTamil ? 'கிடைக்கக்கூடிய முதலீட்டுத் தொகை' : 'Available Investment Capital',
                        style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0F9FF),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFBAE6FD)),
                        ),
                        child: Text(
                          '₹${_budgetInr.toStringAsFixed(0)}',
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0284C7),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildBudgetChip(isTamil ? '₹50ஆயிரம்' : '₹50K', 50000.0),
                      const SizedBox(width: 6),
                      _buildBudgetChip(isTamil ? '₹1 லட்சம்' : '₹1 Lakh', 100000.0),
                      const SizedBox(width: 6),
                      _buildBudgetChip(isTamil ? '₹2 லட்சம்' : '₹2 Lakh', 200000.0),
                      const SizedBox(width: 6),
                      _buildBudgetChip(isTamil ? '₹3 லட்சம்' : '₹3 Lakh', 300000.0),
                    ],
                  ),
                  Slider(
                    value: _budgetInr,
                    min: 20000.0,
                    max: 400000.0,
                    divisions: 38,
                    activeColor: const Color(0xFF0284C7),
                    onChanged: (val) {
                      setState(() => _budgetInr = val);
                      _runQuotationEngine();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 3. Generated Quotation Results Card
            if (_isGenerating)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(30.0),
                  child: Column(
                    children: [
                      CircularProgressIndicator(color: AppTheme.primaryGreen),
                      SizedBox(height: 12),
                      Text('Synthesizing Zone IoT Soil Metrics & Financial Quotation...'),
                    ],
                  ),
                ),
              )
            else if (_quotationResult != null) ...[
              _buildQuotationSummaryCard(_quotationResult!.recommendedCrop, currentZone, provider),
              const SizedBox(height: 20),

              // 4. Interactive Crop Switcher & Variance Difference Engine
              _buildCropSwitcherAndDiffSection(_quotationResult!, isTamil),
              const SizedBox(height: 20),

              // 5. Itemized Expense Breakdown
              _buildItemizedExpensesList(_quotationResult!.recommendedCrop.lineItems, isTamil),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPlotContextBanner(FieldZone zone, FarmProvider provider) {
    final isEmpty = zone.isEmptyPlot;
    final color = isEmpty ? const Color(0xFFD97706) : const Color(0xFF059669);
    final bgColor = isEmpty ? const Color(0xFFFFFBEB) : const Color(0xFFF0FDF4);
    final borderColor = isEmpty ? const Color(0xFFFDE68A) : const Color(0xFFBBF7D0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isEmpty ? Icons.agriculture_rounded : Icons.sync_alt_rounded,
                  color: color,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isEmpty
                      ? (provider.isTamil ? 'தரிசு நிலம்: புதிய விதைப்பு நிதி மதிப்பீடு' : 'EMPTY PARCEL: FRESH SOWING QUOTATION')
                      : (provider.isTamil ? 'பயிரிடப்பட்ட நிலம்: அடுத்த பருவ சுழற்சி திட்டம்' : 'OCCUPIED PARCEL: NEXT-SEASON ROTATION PLAN'),
                  style: GoogleFonts.outfit(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: isEmpty ? const Color(0xFF92400E) : const Color(0xFF065F46),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isEmpty
                      ? (provider.isTamil ? 'தரிசு / தயார்' : 'FALLOW / READY')
                      : (provider.isTamil ? 'நடப்பு பயிர்' : 'STANDING CROP'),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isEmpty
                ? (provider.isTamil
                    ? 'இந்த நிலம் (${zone.nameFor(true)}) தற்போது தரிசாக உள்ளது. நில தயாரிப்பு, விதை கொள்முதல், உரச்செலவு மற்றும் பருவ கால வருவாய் கணக்கிடப்படுகிறது.'
                    : 'This parcel (${zone.nameFor(false)}) is currently fallow/tilled with no standing crop. Previous harvest: ${zone.previousHarvestedCrop}. The quotation calculates initial land preparation, seed procurement, basal NPK, nursery setup, and full-season return.')
                : (provider.isTamil
                    ? 'இந்த நிலத்தில் தற்போது ${zone.cropFor(true)} (${zone.stageFor(true)}) சாகுபடி செய்யப்பட்டுள்ளது. அறுவடைக்கு பின் மண் வளம் மீட்டெடுக்கும் அடுத்த பருவ சுழற்சி முறை கணக்கிடப்படுகிறது.'
                    : 'This parcel currently holds standing ${zone.cropFor(false)} (${zone.stageFor(false)}). Quotation operates in Next-Season Crop Rotation mode, evaluating soil replenishment after harvest and preventing mono-crop disease build-up.'),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.5,
              height: 1.45,
              color: isEmpty ? const Color(0xFF78350F) : const Color(0xFF064E3B),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                Icon(Icons.memory_rounded, size: 13, color: color),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    provider.isTamil
                        ? '📡 சென்சார்: ${zone.hardwareNodeLabel} • AI: ${zone.tinymlEdgeDecision} | NPK ${zone.nitrogenKgHa.toInt()}:${zone.phosphorusKgHa.toInt()}:${zone.potassiumKgHa.toInt()} | ஈரப்பதம் ${zone.soilMoisturePct.toStringAsFixed(1)}%'
                        : '📡 Hardware: ${zone.hardwareNodeLabel} • TinyML: ${zone.tinymlEdgeDecision} | NPK ${zone.nitrogenKgHa.toInt()}:${zone.phosphorusKgHa.toInt()}:${zone.potassiumKgHa.toInt()} | Mst ${zone.soilMoisturePct.toStringAsFixed(1)}%',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF374151),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetChip(String label, double value) {
    final isSelected = (_budgetInr - value).abs() < 1000.0;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _budgetInr = value);
          _runQuotationEngine();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF0284C7) : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : const Color(0xFF374151),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuotationSummaryCard(
    CropFinancialSummaryModel rec,
    FieldZone zone,
    FarmProvider provider,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppTheme.heroGradient,
        borderRadius: BorderRadius.circular(22),
        boxShadow: AppTheme.elevatedShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.eco_rounded, color: Color(0xFFD8F3DC), size: 18),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    provider.isTamil ? 'AI பரிந்துரைத்த பயிர்' : 'AI RECOMMENDED CROP',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFD8F3DC),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF34D399).withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF34D399)),
                ),
                child: Text(
                  '${rec.suitabilityScore}% ${provider.isTamil ? "மண் பொருத்தம்" : "SOIL MATCH"}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            provider.isTamil ? AppLocalization.cropName(rec.cropName, isTamil: true) : AppLocalization.cropName(rec.cropName, isTamil: false),
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: -0.4,
            ),
          ),
          Text(
            rec.zoneCompatibility,
            style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFFD8F3DC)),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              children: [
                const Icon(Icons.sensors_rounded, color: Color(0xFF34D399), size: 14),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    "IoT: pH ${zone.soilPh.toStringAsFixed(1)} | NPK ${zone.nitrogenKgHa.toInt()}:${zone.phosphorusKgHa.toInt()}:${zone.potassiumKgHa.toInt()} | Mst ${zone.soilMoisturePct.toStringAsFixed(1)}%  •  Weather: ${provider.weather.temperatureC.toStringAsFixed(1)}°C, ${provider.weather.humidityPct.toStringAsFixed(0)}% RH",
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFE2E8F0),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 3 Metric Pills
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(provider.isTamil ? 'மதிப்பிடப்பட்ட செலவு' : 'EST. COST', style: GoogleFonts.plusJakartaSans(fontSize: 9.5, color: const Color(0xFFD8F3DC), fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '₹${rec.totalEstimatedCost.toStringAsFixed(0)}',
                          style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(width: 1, height: 30, color: Colors.white24),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(provider.isTamil ? 'மதிப்பிடப்பட்ட லாபம்' : 'EST. PROFIT', style: GoogleFonts.plusJakartaSans(fontSize: 9.5, color: const Color(0xFFD8F3DC), fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '₹${rec.projectedNetProfit.toStringAsFixed(0)}',
                          style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF34D399)),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(width: 1, height: 30, color: Colors.white24),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(provider.isTamil ? 'லாப விகிதம்' : 'NET ROI', style: GoogleFonts.plusJakartaSans(fontSize: 9.5, color: const Color(0xFFD8F3DC), fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '+${rec.projectedRoiPercent.toStringAsFixed(0)}%',
                          style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF6EE7B7)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  provider.isTamil
                      ? 'விளைச்சல்: ${rec.totalExpectedYieldQuintals.toStringAsFixed(0)} குவிண்டால் (@ ₹${rec.expectedMandiPricePerQuintal.toStringAsFixed(0)}/கு)'
                      : 'Yield: ${rec.totalExpectedYieldQuintals.toStringAsFixed(0)} Quintals (@ ₹${rec.expectedMandiPricePerQuintal.toStringAsFixed(0)}/Q)',
                  style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: const Color(0xFFD8F3DC), fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  rec.budgetStatus,
                  style: GoogleFonts.plusJakartaSans(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCropSwitcherAndDiffSection(CropQuotationResponseModel resp, bool isTamil) {
    final crops = resp.allSupportedCrops;
    final diff = resp.comparisonIfChanged;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5EAE5), width: 1.2),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isTamil ? 'மாற்றுப் பயிர்களை ஆராய்க' : 'EXPLORE ALTERNATIVE CROPS',
                style: GoogleFonts.outfit(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: const Color(0xFF141F17),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF5FF),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isTamil ? 'ஒப்பீட்டு இயந்திரம்' : 'VARIANCE ENGINE',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF7C3AED),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Chips for Crop Overrides
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: crops.map((c) {
              final isRec = c == resp.recommendedCrop.cropName;
              final isCurrent = (_customCropOverride ?? resp.recommendedCrop.cropName) == c;
              final chipText = isRec
                  ? (isTamil ? '${AppLocalization.cropName(c, isTamil: true)} (AI தேர்வு)' : '$c (AI Choice)')
                  : (isTamil ? AppLocalization.cropName(c, isTamil: true) : c);

              return ChoiceChip(
                label: Text(
                  chipText,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                    color: isCurrent ? Colors.white : const Color(0xFF374151),
                  ),
                ),
                selected: isCurrent,
                selectedColor: isRec ? AppTheme.primaryGreen : const Color(0xFF7C3AED),
                backgroundColor: const Color(0xFFF3F4F6),
                onSelected: (selected) {
                  setState(() {
                    _customCropOverride = c;
                  });
                  _runQuotationEngine();
                },
              );
            }).toList(),
          ),

          if (diff != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF5FF),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE9D5FF)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.compare_arrows_rounded, color: Color(0xFF7C3AED), size: 18),
                      const SizedBox(width: 6),
                      Text(
                        isTamil
                            ? 'வேறுபாடு: ${AppLocalization.cropName(diff.selectedCrop, isTamil: true)} vs ${AppLocalization.cropName(diff.suggestedCrop, isTamil: true)}'
                            : 'VARIANCE: ${diff.selectedCrop.toUpperCase()} vs ${diff.suggestedCrop.toUpperCase()}',
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF581C87),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Variance Differences Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildDiffBadge(
                          isTamil ? 'செலவு வித்தியாசம்' : 'Cost Diff',
                          '${diff.costDifferenceInr >= 0 ? "+" : ""}₹${diff.costDifferenceInr.toStringAsFixed(0)}',
                          diff.costDifferenceInr <= 0 ? const Color(0xFF059669) : const Color(0xFFC2410C),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: _buildDiffBadge(
                          isTamil ? 'லாப வித்தியாசம்' : 'Profit Diff',
                          '${diff.profitDifferenceInr >= 0 ? "+" : ""}₹${diff.profitDifferenceInr.toStringAsFixed(0)}',
                          diff.profitDifferenceInr >= 0 ? const Color(0xFF059669) : const Color(0xFFC2410C),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: _buildDiffBadge(
                          isTamil ? 'நீர் தேவை மாற்றம்' : 'Water Delta',
                          '${diff.waterDemandDifferenceMm >= 0 ? "+" : ""}${diff.waterDemandDifferenceMm.toStringAsFixed(0)} mm',
                          diff.waterDemandDifferenceMm <= 0 ? const Color(0xFF0284C7) : const Color(0xFFD97706),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Key Tradeoffs
                  ...diff.keyTradeoffs.map((t) => Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF7C3AED))),
                            Expanded(
                              child: Text(
                                t,
                                style: GoogleFonts.plusJakartaSans(fontSize: 11.5, color: const Color(0xFF374151)),
                              ),
                            ),
                          ],
                        ),
                      )),
                  const SizedBox(height: 6),

                  // Agronomist Verdict Banner
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFD8B4FE)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.psychology_rounded, color: Color(0xFF7C3AED), size: 16),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            diff.aiAgronomistVerdict,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF4C1D95),
                              height: 1.35,
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
        ],
      ),
    );
  }

  Widget _buildDiffBadge(String title, String val, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(title, style: GoogleFonts.plusJakartaSans(fontSize: 9.5, color: color, fontWeight: FontWeight.bold)),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(val, style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.bold, color: color)),
          ),
        ],
      ),
    );
  }

  Widget _buildItemizedExpensesList(List<QuotationLineItemModel> items, bool isTamil) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isTamil ? 'பிரிவு வாரியான நிதி மதிப்பீடு' : 'ITEMIZED FINANCIAL QUOTATION',
          style: GoogleFonts.outfit(
            fontSize: 12.5,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.6,
            color: const Color(0xFF4B5E52),
          ),
        ),
        const SizedBox(height: 8),
        ...items.map((item) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE5EAE5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.category,
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: const Color(0xFF141F17),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '₹${item.totalCost.toStringAsFixed(0)}',
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.details,
                    style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF5A6E61)),
                  ),
                ],
              ),
            )),
      ],
    );
  }
}
