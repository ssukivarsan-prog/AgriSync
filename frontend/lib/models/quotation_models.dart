class QuotationLineItemModel {
  final String category;
  final String itemName;
  final double costPerAcre;
  final double totalCost;
  final String details;

  QuotationLineItemModel({
    required this.category,
    required this.itemName,
    required this.costPerAcre,
    required this.totalCost,
    required this.details,
  });

  factory QuotationLineItemModel.fromJson(Map<String, dynamic> json) {
    return QuotationLineItemModel(
      category: json['category'] ?? '',
      itemName: json['item_name'] ?? '',
      costPerAcre: (json['cost_per_acre'] as num?)?.toDouble() ?? 0.0,
      totalCost: (json['total_cost'] as num?)?.toDouble() ?? 0.0,
      details: json['details'] ?? '',
    );
  }
}

class CropFinancialSummaryModel {
  final String cropName;
  final int suitabilityScore;
  final String zoneCompatibility;
  final double costPerAcre;
  final double totalEstimatedCost;
  final double budgetSurplusDeficit;
  final String budgetStatus;
  final double expectedYieldQuintalsPerAcre;
  final double totalExpectedYieldQuintals;
  final double expectedMandiPricePerQuintal;
  final double projectedGrossRevenue;
  final double projectedNetProfit;
  final double projectedRoiPercent;
  final int growingCycleDays;
  final double waterRequirementMm;
  final List<QuotationLineItemModel> lineItems;
  final Map<String, dynamic> zoneIotContext;

  CropFinancialSummaryModel({
    required this.cropName,
    required this.suitabilityScore,
    required this.zoneCompatibility,
    required this.costPerAcre,
    required this.totalEstimatedCost,
    required this.budgetSurplusDeficit,
    required this.budgetStatus,
    required this.expectedYieldQuintalsPerAcre,
    required this.totalExpectedYieldQuintals,
    required this.expectedMandiPricePerQuintal,
    required this.projectedGrossRevenue,
    required this.projectedNetProfit,
    required this.projectedRoiPercent,
    required this.growingCycleDays,
    required this.waterRequirementMm,
    required this.lineItems,
    required this.zoneIotContext,
  });

  factory CropFinancialSummaryModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['line_items'] as List<dynamic>? ?? [];
    return CropFinancialSummaryModel(
      cropName: json['crop_name'] ?? 'Tomato',
      suitabilityScore: (json['suitability_score'] as num?)?.toInt() ?? 80,
      zoneCompatibility: json['zone_compatibility'] ?? '',
      costPerAcre: (json['cost_per_acre'] as num?)?.toDouble() ?? 0.0,
      totalEstimatedCost: (json['total_estimated_cost'] as num?)?.toDouble() ?? 0.0,
      budgetSurplusDeficit: (json['budget_surplus_deficit'] as num?)?.toDouble() ?? 0.0,
      budgetStatus: json['budget_status'] ?? 'Within Budget',
      expectedYieldQuintalsPerAcre: (json['expected_yield_quintals_per_acre'] as num?)?.toDouble() ?? 0.0,
      totalExpectedYieldQuintals: (json['total_expected_yield_quintals'] as num?)?.toDouble() ?? 0.0,
      expectedMandiPricePerQuintal: (json['expected_mandi_price_per_quintal'] as num?)?.toDouble() ?? 0.0,
      projectedGrossRevenue: (json['projected_gross_revenue'] as num?)?.toDouble() ?? 0.0,
      projectedNetProfit: (json['projected_net_profit'] as num?)?.toDouble() ?? 0.0,
      projectedRoiPercent: (json['projected_roi_percent'] as num?)?.toDouble() ?? 0.0,
      growingCycleDays: (json['growing_cycle_days'] as num?)?.toInt() ?? 100,
      waterRequirementMm: (json['water_requirement_mm'] as num?)?.toDouble() ?? 500.0,
      lineItems: rawItems.map((e) => QuotationLineItemModel.fromJson(e as Map<String, dynamic>)).toList(),
      zoneIotContext: (json['zone_iot_context'] as Map<String, dynamic>?) ?? {},
    );
  }
}

class CropVarianceDiffModel {
  final String suggestedCrop;
  final String selectedCrop;
  final double costDifferenceInr;
  final double costDifferencePercent;
  final double profitDifferenceInr;
  final double roiDifferencePercent;
  final double waterDemandDifferenceMm;
  final int suitabilityDropPercent;
  final List<String> keyTradeoffs;
  final String aiAgronomistVerdict;

  CropVarianceDiffModel({
    required this.suggestedCrop,
    required this.selectedCrop,
    required this.costDifferenceInr,
    required this.costDifferencePercent,
    required this.profitDifferenceInr,
    required this.roiDifferencePercent,
    required this.waterDemandDifferenceMm,
    required this.suitabilityDropPercent,
    required this.keyTradeoffs,
    required this.aiAgronomistVerdict,
  });

  factory CropVarianceDiffModel.fromJson(Map<String, dynamic> json) {
    final rawTradeoffs = json['key_tradeoffs'] as List<dynamic>? ?? [];
    return CropVarianceDiffModel(
      suggestedCrop: json['suggested_crop'] ?? '',
      selectedCrop: json['selected_crop'] ?? '',
      costDifferenceInr: (json['cost_difference_inr'] as num?)?.toDouble() ?? 0.0,
      costDifferencePercent: (json['cost_difference_percent'] as num?)?.toDouble() ?? 0.0,
      profitDifferenceInr: (json['profit_difference_inr'] as num?)?.toDouble() ?? 0.0,
      roiDifferencePercent: (json['roi_difference_percent'] as num?)?.toDouble() ?? 0.0,
      waterDemandDifferenceMm: (json['water_demand_difference_mm'] as num?)?.toDouble() ?? 0.0,
      suitabilityDropPercent: (json['suitability_drop_percent'] as num?)?.toInt() ?? 0,
      keyTradeoffs: rawTradeoffs.map((e) => e.toString()).toList(),
      aiAgronomistVerdict: json['ai_agronomist_verdict'] ?? '',
    );
  }
}

class CropQuotationResponseModel {
  final String zoneId;
  final String zoneName;
  final String zoneHardwareType;
  final double areaAcres;
  final double budgetInr;
  final CropFinancialSummaryModel recommendedCrop;
  final CropFinancialSummaryModel? alternativeCrop;
  final CropVarianceDiffModel? comparisonIfChanged;
  final List<String> allSupportedCrops;
  final String timestamp;
  final String? tinymlDecision;

  CropQuotationResponseModel({
    required this.zoneId,
    required this.zoneName,
    required this.zoneHardwareType,
    required this.areaAcres,
    required this.budgetInr,
    required this.recommendedCrop,
    this.alternativeCrop,
    this.comparisonIfChanged,
    required this.allSupportedCrops,
    required this.timestamp,
    this.tinymlDecision,
  });

  factory CropQuotationResponseModel.fromJson(Map<String, dynamic> json) {
    final cropsList = (json['all_supported_crops'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
    return CropQuotationResponseModel(
      zoneId: json['zone_id'] ?? 'zone_a',
      zoneName: json['zone_name'] ?? 'Zone A',
      zoneHardwareType: json['zone_hardware_type'] ?? 'Master LoRaWAN Gateway',
      areaAcres: (json['area_acres'] as num?)?.toDouble() ?? 1.0,
      budgetInr: (json['budget_inr'] as num?)?.toDouble() ?? 50000.0,
      recommendedCrop: CropFinancialSummaryModel.fromJson(json['recommended_crop'] ?? {}),
      alternativeCrop: json['alternative_crop'] != null
          ? CropFinancialSummaryModel.fromJson(json['alternative_crop'])
          : null,
      comparisonIfChanged: json['comparison_if_changed'] != null
          ? CropVarianceDiffModel.fromJson(json['comparison_if_changed'])
          : null,
      allSupportedCrops: cropsList,
      timestamp: json['timestamp'] ?? DateTime.now().toIso8601String(),
      tinymlDecision: json['tinyml_decision'] ?? json['tinyml_edge_decision'],
    );
  }
}

class IoTZoneModel {
  final String id;
  final String name;
  final String hardware;
  final String soilType;
  final double soilPh;
  final double soilNKgHa;
  final double soilPKgHa;
  final double soilKKgHa;
  final double soilMoisturePct;
  final double canopyTempC;
  final double humidityPct;
  final List<String> preferredCrops;

  IoTZoneModel({
    required this.id,
    required this.name,
    required this.hardware,
    required this.soilType,
    required this.soilPh,
    required this.soilNKgHa,
    required this.soilPKgHa,
    required this.soilKKgHa,
    required this.soilMoisturePct,
    required this.canopyTempC,
    required this.humidityPct,
    required this.preferredCrops,
  });

  factory IoTZoneModel.fromJson(Map<String, dynamic> json) {
    final crops = (json['preferred_crops'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
    return IoTZoneModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      hardware: json['hardware'] ?? '',
      soilType: json['soil_type'] ?? '',
      soilPh: (json['soil_ph'] as num?)?.toDouble() ?? 6.8,
      soilNKgHa: (json['soil_n_kg_ha'] as num?)?.toDouble() ?? 140.0,
      soilPKgHa: (json['soil_p_kg_ha'] as num?)?.toDouble() ?? 45.0,
      soilKKgHa: (json['soil_k_kg_ha'] as num?)?.toDouble() ?? 180.0,
      soilMoisturePct: (json['soil_moisture_pct'] as num?)?.toDouble() ?? 30.0,
      canopyTempC: (json['canopy_temp_c'] as num?)?.toDouble() ?? 30.0,
      humidityPct: (json['humidity_pct'] as num?)?.toDouble() ?? 55.0,
      preferredCrops: crops,
    );
  }
}
