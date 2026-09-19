import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/farmer_profile.dart';
import '../models/field_zone.dart';
import '../models/context_fusion_risk.dart';
import '../models/quotation_models.dart';

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1. Farmer Profile Sync
  static Future<void> saveFarmerProfile({
    required String uid,
    required FarmerProfile profile,
  }) async {
    try {
      await _db.collection('farmers').doc(uid).set({
        'name': profile.name,
        'farm_name': profile.farmName,
        'current_season': profile.currentSeason,
        'previous_crop': profile.previousCrop,
        'soil_type': profile.soilType,
        'water_availability': profile.waterAvailability,
        'district_tamil_nadu': profile.districtTamilNadu,
        'agro_climatic_zone': profile.agroClimaticZone,
        'last_updated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Firestore: saveFarmerProfile error: $e');
    }
  }

  static Future<Map<String, dynamic>?> getFarmerProfile(String uid) async {
    try {
      final doc = await _db.collection('farmers').doc(uid).get();
      return doc.data();
    } catch (e) {
      debugPrint('Firestore: getFarmerProfile error: $e');
      return null;
    }
  }

  // 2. Real-time Field Zones & TinyML Telemetry Sync
  static Future<void> syncFieldZones({
    required String uid,
    required List<FieldZone> zones,
  }) async {
    try {
      final batch = _db.batch();
      for (final zone in zones) {
        final docRef = _db.collection('farmers').doc(uid).collection('field_zones').doc(zone.id);
        batch.set(docRef, {
          'id': zone.id,
          'name': zone.name,
          'crop': zone.crop,
          'variety': zone.variety,
          'stage': zone.stage,
          'area_acres': zone.areaAcres,
          'soil_moisture_pct': zone.soilMoisturePct,
          'soil_ph': zone.soilPh,
          'nitrogen_kg_ha': zone.nitrogenKgHa,
          'phosphorus_kg_ha': zone.phosphorusKgHa,
          'potassium_kg_ha': zone.potassiumKgHa,
          'soil_temp_c': zone.soilTempC,
          'air_temp_c': zone.airTempC,
          'humidity_pct': zone.humidityPct,
          'status': zone.status.name,
          'status_headline': zone.statusHeadline,
          'status_reason': zone.statusReason,
          'recommended_action': zone.recommendedAction,
          'gps_coordinates': zone.gpsCoordinates,
          'hardware_node': zone.hardwareNode,
          'tinyml_edge_decision': zone.tinymlEdgeDecision,
          'battery_pct': zone.batteryPct,
          'signal_rssi_dbm': zone.signalRssiDbm,
          'is_fallow': zone.isFallow,
          'previous_harvested_crop': zone.previousHarvestedCrop,
          'updated_at': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }
      await batch.commit();
    } catch (e) {
      debugPrint('Firestore: syncFieldZones error: $e');
    }
  }

  // 3. Log Diagnostic Scan (Photo / Video Fusion)
  static Future<String?> logDiagnosticScan({
    required String uid,
    required ContextFusionAssessment assessment,
    String? mediaUrl,
  }) async {
    try {
      final docRef = _db.collection('farmers').doc(uid).collection('diagnoses').doc();
      await docRef.set({
        'id': docRef.id,
        'cv_observation': assessment.cvObservation,
        'tamil_diagnosis_name': assessment.tamilDiagnosisName,
        'severity': assessment.severity,
        'overall_risk_title': assessment.finalRiskTitle,
        'scientific_explanation': assessment.scientificExplanation,
        'immediate_action': assessment.immediateAction,
        'tnau_treatment_protocol': assessment.tnauTreatmentProtocol,
        'preventative_steps': assessment.preventativeSteps,
        'is_video': assessment.isVideo,
        'district_location': assessment.districtLocation,
        'media_url': mediaUrl,
        'created_at': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      debugPrint('Firestore: logDiagnosticScan error: $e');
      return null;
    }
  }

  // 4. Save Sowing Quotation
  static Future<String?> saveQuotation({
    required String uid,
    required CropQuotationResponseModel quotation,
  }) async {
    try {
      final docRef = _db.collection('farmers').doc(uid).collection('quotations').doc();
      await docRef.set({
        'id': docRef.id,
        'zone_id': quotation.zoneId,
        'zone_name': quotation.zoneName,
        'zone_hardware_type': quotation.zoneHardwareType,
        'tinyml_decision': quotation.tinymlDecision,
        'area_acres': quotation.areaAcres,
        'budget_inr': quotation.budgetInr,
        'recommended_crop_name': quotation.recommendedCrop.cropName,
        'suitability_score': quotation.recommendedCrop.suitabilityScore,
        'total_estimated_cost': quotation.recommendedCrop.totalEstimatedCost,
        'projected_net_profit': quotation.recommendedCrop.projectedNetProfit,
        'projected_roi_percent': quotation.recommendedCrop.projectedRoiPercent,
        'created_at': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      debugPrint('Firestore: saveQuotation error: $e');
      return null;
    }
  }
}
