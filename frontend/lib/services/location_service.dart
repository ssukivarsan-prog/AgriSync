import 'dart:convert';
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class TamilNaduDistrictProfile {
  final String id;
  final String name;
  final String tamilName;
  final String zoneName;
  final String tamilZoneName;
  final double latitude;
  final double longitude;
  final String typicalSoilType;
  final double typicalPh;
  final double typicalMoisturePct;
  final List<String> majorCrops;
  final List<String> majorCropsTamil;
  final String activeSeason;
  final String seasonTamil;
  final double avgTempC;
  final double avgHumidityPct;
  final double avgRainfallMm;
  final String weatherForecast;
  final String primaryMandi;

  const TamilNaduDistrictProfile({
    required this.id,
    required this.name,
    required this.tamilName,
    required this.zoneName,
    required this.tamilZoneName,
    required this.latitude,
    required this.longitude,
    required this.typicalSoilType,
    required this.typicalPh,
    required this.typicalMoisturePct,
    required this.majorCrops,
    required this.majorCropsTamil,
    required this.activeSeason,
    required this.seasonTamil,
    required this.avgTempC,
    required this.avgHumidityPct,
    required this.avgRainfallMm,
    required this.weatherForecast,
    required this.primaryMandi,
  });
}

class LocationService {
  /// Complete dataset of all 38 Tamil Nadu districts categorized into
  /// 7 official agro-climatic zones as defined by the Tamil Nadu Agricultural University (TNAU).
  static const List<TamilNaduDistrictProfile> tamilNaduDistricts = [
    // =========================================================================
    // 1. Cauvery Delta Agro-Climatic Zone (Granary of Tamil Nadu)
    // =========================================================================
    TamilNaduDistrictProfile(
      id: "thanjavur",
      name: "Thanjavur",
      tamilName: "தஞ்சாவூர்",
      zoneName: "Cauvery Delta Agro-Climatic Zone",
      tamilZoneName: "காவிரி டெல்டா மண்டலம்",
      latitude: 10.7870,
      longitude: 79.1378,
      typicalSoilType: "Cauvery Alluvial Clay Loam (வண்டல் மண்)",
      typicalPh: 6.8,
      typicalMoisturePct: 34.0,
      majorCrops: ["Paddy (Rice)", "Black Gram (Ulundu)", "Banana", "Coconut", "Sugarcane"],
      majorCropsTamil: ["நெல் (ADT-45/CR-1009)", "உளுந்து (வம்பன்-8)", "வாழை (பூவன்)", "தென்னை", "கரும்பு"],
      activeSeason: "Samba / Thaladi Season (சம்பா / தாளடி பருவம்)",
      seasonTamil: "சம்பா பருவம் (ஆகஸ்ட் - ஜனவரி)",
      avgTempC: 31.5,
      avgHumidityPct: 78.0,
      avgRainfallMm: 2.5,
      weatherForecast: "Humid coastal breeze, light evening delta showers forecast",
      primaryMandi: "Thanjavur Direct Purchase Centre (DPC) & Kumbakonam Mandi",
    ),
    TamilNaduDistrictProfile(
      id: "tiruvarur",
      name: "Tiruvarur",
      tamilName: "திருவாரூர்",
      zoneName: "Cauvery Delta Agro-Climatic Zone",
      tamilZoneName: "காவிரி டெல்டா மண்டலம்",
      latitude: 10.7725,
      longitude: 79.6365,
      typicalSoilType: "Deep Deltaic Alluvium (ஆற்று வண்டல்)",
      typicalPh: 6.9,
      typicalMoisturePct: 36.0,
      majorCrops: ["Paddy (Rice)", "Green Gram", "Black Gram", "Cotton"],
      majorCropsTamil: ["நெல்", "பாசிப்பயறு", "உளுந்து", "பருத்தி"],
      activeSeason: "Samba Season",
      seasonTamil: "சம்பா பருவம்",
      avgTempC: 31.0,
      avgHumidityPct: 80.0,
      avgRainfallMm: 3.0,
      weatherForecast: "Overcast skies with delta moisture condensation",
      primaryMandi: "Tiruvarur Regulated Market",
    ),
    TamilNaduDistrictProfile(
      id: "nagapattinam",
      name: "Nagapattinam",
      tamilName: "நாகப்பட்டினம்",
      zoneName: "Cauvery Delta Agro-Climatic Zone",
      tamilZoneName: "காவிரி டெல்டா மண்டலம்",
      latitude: 10.7672,
      longitude: 79.8449,
      typicalSoilType: "Coastal Alluvial Sandy Loam",
      typicalPh: 7.2,
      typicalMoisturePct: 32.5,
      majorCrops: ["Paddy (Rice)", "Groundnut", "Casuarina", "Pulses"],
      majorCropsTamil: ["நெல்", "நிலக்கடலை", "சவுக்கு", "பயறு வகைகள்"],
      activeSeason: "Thaladi Season",
      seasonTamil: "தாளடி பருவம்",
      avgTempC: 32.0,
      avgHumidityPct: 82.0,
      avgRainfallMm: 4.0,
      weatherForecast: "Coastal humid air, North-East monsoon squalls expected",
      primaryMandi: "Nagapattinam Coastal Regulated Market",
    ),
    TamilNaduDistrictProfile(
      id: "mayiladuthurai",
      name: "Mayiladuthurai",
      tamilName: "மயிலாடுதுறை",
      zoneName: "Cauvery Delta Agro-Climatic Zone",
      tamilZoneName: "காவிரி டெல்டா மண்டலம்",
      latitude: 11.1075,
      longitude: 79.6524,
      typicalSoilType: "Rich Deltaic Clay Loam",
      typicalPh: 6.7,
      typicalMoisturePct: 35.0,
      majorCrops: ["Paddy (Rice)", "Sugarcane", "Black Gram", "Banana"],
      majorCropsTamil: ["நெல்", "கரும்பு", "உளுந்து", "வாழை"],
      activeSeason: "Kuruvai / Samba Season",
      seasonTamil: "குறுவை / சம்பா பருவம்",
      avgTempC: 31.2,
      avgHumidityPct: 79.0,
      avgRainfallMm: 1.8,
      weatherForecast: "Mild humid winds with moderate cloud cover",
      primaryMandi: "Mayiladuthurai Regulated Agricultural Market",
    ),
    TamilNaduDistrictProfile(
      id: "tiruchirappalli",
      name: "Tiruchirappalli",
      tamilName: "திருச்சிராப்பள்ளி",
      zoneName: "Cauvery Delta Agro-Climatic Zone",
      tamilZoneName: "காவிரி டெல்டா மண்டலம்",
      latitude: 10.7905,
      longitude: 78.7047,
      typicalSoilType: "Riverbank Alluvial & Red Sandy Soil",
      typicalPh: 6.9,
      typicalMoisturePct: 30.0,
      majorCrops: ["Banana (Grand Naine / Poovan)", "Paddy", "Sugarcane", "Onion"],
      majorCropsTamil: ["வாழை (நேந்திரன்/பூவன்)", "நெல்", "கரும்பு", "சின்ன வெங்காயம்"],
      activeSeason: "All Season Banana Plantation",
      seasonTamil: "வாழை சாகுபடி பருவம்",
      avgTempC: 33.4,
      avgHumidityPct: 65.0,
      avgRainfallMm: 0.5,
      weatherForecast: "Warm bright sunshine, optimal for banana canopy photosynthesis",
      primaryMandi: "Trichy Gandhi Market & National Research Centre for Banana (NRCB)",
    ),
    TamilNaduDistrictProfile(
      id: "karur",
      name: "Karur",
      tamilName: "கரூர்",
      zoneName: "Cauvery Delta Agro-Climatic Zone",
      tamilZoneName: "காவிரி டெல்டா மண்டலம்",
      latitude: 10.9601,
      longitude: 78.0766,
      typicalSoilType: "Amaravathi Alluvium & Red Loamy Soil",
      typicalPh: 7.1,
      typicalMoisturePct: 27.0,
      majorCrops: ["Sugarcane", "Paddy", "Banana", "Moringa (Murungai)"],
      majorCropsTamil: ["கரும்பு", "நெல்", "வாழை", "முருங்கை"],
      activeSeason: "Samba / Kar Season",
      seasonTamil: "சம்பா பருவம்",
      avgTempC: 33.8,
      avgHumidityPct: 58.0,
      avgRainfallMm: 0.0,
      weatherForecast: "Warm sunny days with light river valley gusts",
      primaryMandi: "Karur Regulated Market",
    ),
    TamilNaduDistrictProfile(
      id: "perambalur",
      name: "Perambalur",
      tamilName: "பெரம்பலூர்",
      zoneName: "Cauvery Delta Agro-Climatic Zone",
      tamilZoneName: "காவிரி டெல்டா மண்டலம்",
      latitude: 11.2342,
      longitude: 78.8820,
      typicalSoilType: "Black Cotton Soil & Red Sandy Loam",
      typicalPh: 7.3,
      typicalMoisturePct: 24.0,
      majorCrops: ["Shallots (Small Onion / Chinna Vengayam)", "Cotton", "Maize", "Groundnut"],
      majorCropsTamil: ["சின்ன வெங்காயம்", "பருத்தி", "மக்காச்சோளம்", "நிலக்கடலை"],
      activeSeason: "Purattasi Pattam",
      seasonTamil: "புரட்டாசி பட்டம்",
      avgTempC: 33.0,
      avgHumidityPct: 56.0,
      avgRainfallMm: 0.0,
      weatherForecast: "Clear skies with dry sunny afternoon intervals",
      primaryMandi: "Perambalur Regulated Onion Market",
    ),
    TamilNaduDistrictProfile(
      id: "ariyalur",
      name: "Ariyalur",
      tamilName: "அரியலூர்",
      zoneName: "Cauvery Delta Agro-Climatic Zone",
      tamilZoneName: "காவிரி டெல்டா மண்டலம்",
      latitude: 11.1401,
      longitude: 79.0786,
      typicalSoilType: "Calcareous Loam & Red Sandy Soil",
      typicalPh: 7.4,
      typicalMoisturePct: 25.0,
      majorCrops: ["Cashew", "Sugarcane", "Paddy", "Groundnut", "Maize"],
      majorCropsTamil: ["முந்திரி", "கரும்பு", "நெல்", "நிலக்கடலை", "மக்காச்சோளம்"],
      activeSeason: "Aadi Pattam / Samba",
      seasonTamil: "ஆடிப்பட்டம்",
      avgTempC: 33.2,
      avgHumidityPct: 60.0,
      avgRainfallMm: 0.0,
      weatherForecast: "Warm sunshine, moderate humidity with clear field visibility",
      primaryMandi: "Ariyalur & Jayankondam Regulated Market",
    ),
    TamilNaduDistrictProfile(
      id: "pudukkottai",
      name: "Pudukkottai",
      tamilName: "புதுக்கோட்டை",
      zoneName: "Cauvery Delta Agro-Climatic Zone",
      tamilZoneName: "காவிரி டெல்டா மண்டலம்",
      latitude: 10.3833,
      longitude: 78.8001,
      typicalSoilType: "Lateritic Red Sandy Soil",
      typicalPh: 6.5,
      typicalMoisturePct: 26.0,
      majorCrops: ["Paddy", "Groundnut", "Coconut", "Cashew", "Pulses"],
      majorCropsTamil: ["நெல்", "நிலக்கடலை", "தென்னை", "முந்திரி", "பயறு வகைகள்"],
      activeSeason: "Samba / Thaladi",
      seasonTamil: "சம்பா பருவம்",
      avgTempC: 32.8,
      avgHumidityPct: 64.0,
      avgRainfallMm: 0.5,
      weatherForecast: "Partly cloudy with pleasant evening breezes",
      primaryMandi: "Pudukkottai Central Market",
    ),

    // =========================================================================
    // 2. Western Agro-Climatic Zone (Textile, Coconut & Spice Belt)
    // =========================================================================
    TamilNaduDistrictProfile(
      id: "coimbatore",
      name: "Coimbatore",
      tamilName: "கோயம்புத்தூர்",
      zoneName: "Western Agro-Climatic Zone",
      tamilZoneName: "மேற்கு மண்டலம்",
      latitude: 11.0168,
      longitude: 76.9558,
      typicalSoilType: "Red Sandy Loam & Clay Loam (செம்மண்)",
      typicalPh: 6.6,
      typicalMoisturePct: 26.5,
      majorCrops: ["Coconut (Thennai)", "Cotton (Paruthi)", "Tomato", "Turmeric", "Maize"],
      majorCropsTamil: ["தென்னை (பொள்ளாச்சி நெட்டை)", "பருத்தி (MCU-5)", "தக்காளி", "மஞ்சள்", "மக்காச்சோளம்"],
      activeSeason: "Aadi Pattam (ஆடிப்பட்டம்)",
      seasonTamil: "ஆடிப்பட்டம் (ஜூலை - ஆகஸ்ட்)",
      avgTempC: 29.8,
      avgHumidityPct: 62.0,
      avgRainfallMm: 1.2,
      weatherForecast: "Pleasant Western Ghats breeze with intermittent clouds",
      primaryMandi: "Pollachi Coconut Market & Coimbatore Central Market",
    ),
    TamilNaduDistrictProfile(
      id: "erode",
      name: "Erode",
      tamilName: "ஈரோடு",
      zoneName: "Western Agro-Climatic Zone",
      tamilZoneName: "மேற்கு மண்டலம்",
      latitude: 11.4500,
      longitude: 77.4000,
      typicalSoilType: "Rich Deep Clay Loam (களிமண்)",
      typicalPh: 7.0,
      typicalMoisturePct: 28.0,
      majorCrops: ["Turmeric (Erode Manjal)", "Sugarcane", "Banana", "Tapioca", "Maize"],
      majorCropsTamil: ["மஞ்சள் (ஈரோடு மஞ்சள் GI)", "கரும்பு", "வாழை", "மரவள்ளிக்கிழங்கு", "மக்காச்சோளம்"],
      activeSeason: "Chithirai / Aadi Pattam",
      seasonTamil: "சித்திரை / ஆடிப்பட்டம்",
      avgTempC: 32.5,
      avgHumidityPct: 58.0,
      avgRainfallMm: 0.0,
      weatherForecast: "Warm sunny conditions ideal for turmeric rhizome bulking",
      primaryMandi: "Erode Turmeric Market Complex & Perundurai Regulated Market",
    ),
    TamilNaduDistrictProfile(
      id: "tiruppur",
      name: "Tiruppur",
      tamilName: "திருப்பூர்",
      zoneName: "Western Agro-Climatic Zone",
      tamilZoneName: "மேற்கு மண்டலம்",
      latitude: 11.1085,
      longitude: 77.3411,
      typicalSoilType: "Red Gravelly Loam & Calcareous Soil",
      typicalPh: 7.3,
      typicalMoisturePct: 24.0,
      majorCrops: ["Cotton", "Maize", "Groundnut", "Coconut", "Millets"],
      majorCropsTamil: ["பருத்தி", "மக்காச்சோளம்", "நிலக்கடலை", "தென்னை", "சிறு தானியங்கள்"],
      activeSeason: "Purattasi Pattam (புரட்டாசி பட்டம்)",
      seasonTamil: "புரட்டாசி பட்டம்",
      avgTempC: 31.8,
      avgHumidityPct: 56.0,
      avgRainfallMm: 0.0,
      weatherForecast: "Dry sunny climate, requires micro-drip scheduling",
      primaryMandi: "Udumalaipettai & Tiruppur Cotton Market",
    ),
    TamilNaduDistrictProfile(
      id: "dindigul",
      name: "Dindigul",
      tamilName: "திண்டுக்கல்",
      zoneName: "Western Agro-Climatic Zone",
      tamilZoneName: "மேற்கு மண்டலம்",
      latitude: 10.3673,
      longitude: 77.9803,
      typicalSoilType: "Red Loamy Soil & Mountain Alluvium",
      typicalPh: 6.6,
      typicalMoisturePct: 25.0,
      majorCrops: ["Vegetables (Tomato/Drumstick/Brinjal)", "Maize", "Banana", "Shallots (Chinna Vengayam)"],
      majorCropsTamil: ["காய்கறிகள் (தக்காளி/முருங்கை)", "மக்காச்சோளம்", "வாழை", "சின்ன வெங்காயம்"],
      activeSeason: "Year-round Vegetable Cycles",
      seasonTamil: "காய்கறி சுழற்சி பருவம்",
      avgTempC: 31.0,
      avgHumidityPct: 58.0,
      avgRainfallMm: 0.5,
      weatherForecast: "Equable climate with gentle foothill winds",
      primaryMandi: "Oddanchatram Vegetable Market (South India's Largest)",
    ),
    TamilNaduDistrictProfile(
      id: "theni",
      name: "Theni",
      tamilName: "தேனி",
      zoneName: "Western Agro-Climatic Zone",
      tamilZoneName: "மேற்கு மண்டலம்",
      latitude: 10.0104,
      longitude: 77.4768,
      typicalSoilType: "Fertile Cumbum Valley River Loam",
      typicalPh: 6.8,
      typicalMoisturePct: 29.0,
      majorCrops: ["Grapes (Cumbum Panneer Thratchai GI)", "Banana (Nendran/Red Banana)", "Cotton", "Sugarcane"],
      majorCropsTamil: ["பன்னீர் திராட்சை (GI)", "செவ்வாழை / நேந்திரன்", "பருத்தி", "கரும்பு"],
      activeSeason: "Continuous Harvest Valley Cycle",
      seasonTamil: "கம்பம் பள்ளத்தாக்கு சாகுபடி",
      avgTempC: 30.0,
      avgHumidityPct: 65.0,
      avgRainfallMm: 1.5,
      weatherForecast: "Cumbum Valley breeze with high solar insolation",
      primaryMandi: "Cumbum Valley Grape & Banana Regulated Market",
    ),

    // =========================================================================
    // 3. North Western Agro-Climatic Zone (Plateau & Horticulture Hub)
    // =========================================================================
    TamilNaduDistrictProfile(
      id: "dharmapuri",
      name: "Dharmapuri",
      tamilName: "தர்மபுரி",
      zoneName: "North Western Agro-Climatic Zone",
      tamilZoneName: "வடமேற்கு மண்டலம்",
      latitude: 12.1211,
      longitude: 78.1582,
      typicalSoilType: "Red Sandy Soil & Granitic Loam (செம்மண்)",
      typicalPh: 6.4,
      typicalMoisturePct: 23.5,
      majorCrops: ["Tomato (Thakkali)", "Mango", "Ragi (Finger Millet)", "Chillies", "Groundnut"],
      majorCropsTamil: ["தக்காளி (PKM-1)", "மாம்பழம்", "கேழ்வரகு", "மிளகாய்", "நிலக்கடலை"],
      activeSeason: "Aadi Pattam / Thai Pattam",
      seasonTamil: "தைப்பட்டம் / ஆடிப்பட்டம்",
      avgTempC: 32.2,
      avgHumidityPct: 50.0,
      avgRainfallMm: 0.0,
      weatherForecast: "Warm dry climate, root-zone drip recommended for tomato crops",
      primaryMandi: "Dharmapuri Vegetable Mandi & Rayakottai Tomato Market",
    ),
    TamilNaduDistrictProfile(
      id: "krishnagiri",
      name: "Krishnagiri",
      tamilName: "கிருஷ்ணகிரி",
      zoneName: "North Western Agro-Climatic Zone",
      tamilZoneName: "வடமேற்கு மண்டலம்",
      latitude: 12.5186,
      longitude: 78.2137,
      typicalSoilType: "Red Laterite & Loamy Soil",
      typicalPh: 6.5,
      typicalMoisturePct: 24.5,
      majorCrops: ["Mango (Alphonso/Totapuri)", "Tomato", "Ragi", "Mulberry", "Capsicum"],
      majorCropsTamil: ["மாம்பழம்", "தக்காளி", "கேழ்வரகு", "மல்பெரி பட்டு", "குடைமிளகாய்"],
      activeSeason: "Kharif / Aadi Pattam",
      seasonTamil: "ஆடிப்பட்டம்",
      avgTempC: 30.5,
      avgHumidityPct: 54.0,
      avgRainfallMm: 0.0,
      weatherForecast: "Moderate plateau temperature with cool mornings",
      primaryMandi: "Hosur Floriculture Market & Krishnagiri Regulated Market",
    ),
    TamilNaduDistrictProfile(
      id: "salem",
      name: "Salem",
      tamilName: "சேலம்",
      zoneName: "North Western Agro-Climatic Zone",
      tamilZoneName: "வடமேற்கு மண்டலம்",
      latitude: 11.6643,
      longitude: 78.1460,
      typicalSoilType: "Red Sandy Loam & Black Soil",
      typicalPh: 6.9,
      typicalMoisturePct: 25.0,
      majorCrops: ["Tapioca (Maravalli Kizhangu)", "Mango", "Cotton", "Turmeric", "Paddy"],
      majorCropsTamil: ["மரவள்ளிக்கிழங்கு", "மாம்பழம் (மல்கோவா)", "பருத்தி", "மஞ்சள்", "நெல்"],
      activeSeason: "Aadi Pattam",
      seasonTamil: "ஆடிப்பட்டம்",
      avgTempC: 33.0,
      avgHumidityPct: 55.0,
      avgRainfallMm: 0.0,
      weatherForecast: "Clear skies, high photosynthetic sunshine for starch accumulation",
      primaryMandi: "Salem Sago & Starch Market Complex (SAGOSERVE)",
    ),
    TamilNaduDistrictProfile(
      id: "namakkal",
      name: "Namakkal",
      tamilName: "நாமக்கல்",
      zoneName: "North Western Agro-Climatic Zone",
      tamilZoneName: "வடமேற்கு மண்டலம்",
      latitude: 11.2189,
      longitude: 78.1674,
      typicalSoilType: "Red Sandy Soil & Gravelly Clay Loam",
      typicalPh: 6.8,
      typicalMoisturePct: 24.0,
      majorCrops: ["Tapioca", "Maize", "Groundnut", "Sugarcane", "Poultry Feeds"],
      majorCropsTamil: ["மரவள்ளிக்கிழங்கு", "மக்காச்சோளம்", "நிலக்கடலை", "கரும்பு", "கோழித்தீவனம்"],
      activeSeason: "Aadi Pattam / Purattasi Pattam",
      seasonTamil: "ஆடிப்பட்டம்",
      avgTempC: 32.6,
      avgHumidityPct: 52.0,
      avgRainfallMm: 0.0,
      weatherForecast: "Sunny, dry conditions with warm daytime temperatures",
      primaryMandi: "Namakkal Egg & Feed Commodity Exchange",
    ),

    // =========================================================================
    // 4. Southern Agro-Climatic Zone (Jasmine, Millets & Coastal Plains)
    // =========================================================================
    TamilNaduDistrictProfile(
      id: "madurai",
      name: "Madurai",
      tamilName: "மதுரை",
      zoneName: "Southern Agro-Climatic Zone",
      tamilZoneName: "தெற்கு மண்டலம்",
      latitude: 9.9252,
      longitude: 78.1198,
      typicalSoilType: "Black Cotton Soil & Red Sandy Soil (கரிசல் மண்)",
      typicalPh: 7.4,
      typicalMoisturePct: 23.0,
      majorCrops: ["Jasmine (Madurai Malli GI)", "Cotton", "Millets (Cholam/Kambu)", "Paddy", "Pulses"],
      majorCropsTamil: ["மதுரை மல்லி", "பருத்தி", "சோளம் / கம்பு", "நெல்", "பயறு வகைகள்"],
      activeSeason: "Purattasi Pattam",
      seasonTamil: "புரட்டாசி பட்டம்",
      avgTempC: 34.5,
      avgHumidityPct: 48.0,
      avgRainfallMm: 0.0,
      weatherForecast: "Hot sunny days, light wind currents over southern plains",
      primaryMandi: "Mattuthavani Central Flower & Vegetable Market",
    ),
    TamilNaduDistrictProfile(
      id: "ramanathapuram",
      name: "Ramanathapuram",
      tamilName: "ராமநாதபுரம்",
      zoneName: "Southern Agro-Climatic Zone",
      tamilZoneName: "தெற்கு மண்டலம்",
      latitude: 9.3639,
      longitude: 78.8395,
      typicalSoilType: "Coastal Saline Clay & Sandy Soil",
      typicalPh: 7.8,
      typicalMoisturePct: 21.0,
      majorCrops: ["Mundu Chilli (Ramnad Mundu Milagai GI)", "Cotton", "Paddy (Rainfed)", "Millets"],
      majorCropsTamil: ["குண்டு மிளகாய் (ராமநாதபுரம் முண்டு GI)", "பருத்தி", "மானாவாரி நெல்", "கேழ்வரகு"],
      activeSeason: "Purattasi Pattam Rainfed Sowing",
      seasonTamil: "புரட்டாசி மானாவாரி பட்டம்",
      avgTempC: 34.0,
      avgHumidityPct: 68.0,
      avgRainfallMm: 0.0,
      weatherForecast: "Warm coastal winds, drought-tolerant chilli maturation",
      primaryMandi: "Paramakudi Chilli Mandi & Ramanathapuram Regulated Market",
    ),
    TamilNaduDistrictProfile(
      id: "virudhunagar",
      name: "Virudhunagar",
      tamilName: "விருதுநகர்",
      zoneName: "Southern Agro-Climatic Zone",
      tamilZoneName: "தெற்கு மண்டலம்",
      latitude: 9.5680,
      longitude: 77.9624,
      typicalSoilType: "Black Cotton Soil & Deep Clay Loam",
      typicalPh: 7.6,
      typicalMoisturePct: 22.0,
      majorCrops: ["Cotton", "Chillies", "Groundnut", "Sesame", "Maize"],
      majorCropsTamil: ["பருத்தி", "மிளகாய்", "நிலக்கடலை", "எள்ளு", "மக்காச்சோளம்"],
      activeSeason: "Purattasi Pattam",
      seasonTamil: "புரட்டாசி பட்டம்",
      avgTempC: 34.2,
      avgHumidityPct: 52.0,
      avgRainfallMm: 0.0,
      weatherForecast: "Dry sunny climate, high evapotranspiration",
      primaryMandi: "Virudhunagar Oilseed & Cotton Exchange",
    ),
    TamilNaduDistrictProfile(
      id: "sivaganga",
      name: "Sivaganga",
      tamilName: "சிவகங்கை",
      zoneName: "Southern Agro-Climatic Zone",
      tamilZoneName: "தெற்கு மண்டலம்",
      latitude: 9.8433,
      longitude: 78.4809,
      typicalSoilType: "Red Lateritic Soil & Sandy Loam",
      typicalPh: 6.7,
      typicalMoisturePct: 23.0,
      majorCrops: ["Paddy (Rainfed)", "Groundnut", "Sugarcane", "Coconut", "Millets"],
      majorCropsTamil: ["மானாவாரி நெல்", "நிலக்கடலை", "கரும்பு", "தென்னை", "சிறு தானியங்கள்"],
      activeSeason: "Samba / Purattasi Pattam",
      seasonTamil: "சம்பா பருவம்",
      avgTempC: 33.5,
      avgHumidityPct: 56.0,
      avgRainfallMm: 0.0,
      weatherForecast: "Sunny with dry southern wind currents",
      primaryMandi: "Sivaganga Regulated Market & Karaikudi",
    ),
    TamilNaduDistrictProfile(
      id: "thoothukudi",
      name: "Thoothukudi",
      tamilName: "தூத்துக்குடி",
      zoneName: "Southern Agro-Climatic Zone",
      tamilZoneName: "தெற்கு மண்டலம்",
      latitude: 8.7642,
      longitude: 78.1348,
      typicalSoilType: "Coastal Alluvial & Saline Black Soil",
      typicalPh: 7.7,
      typicalMoisturePct: 24.0,
      majorCrops: ["Cotton", "Chillies", "Millets", "Banana", "Pulses"],
      majorCropsTamil: ["பருத்தி", "மிளகாய்", "கம்பு", "வாழை", "உளுந்து"],
      activeSeason: "Pishanam / Purattasi",
      seasonTamil: "பிசானம் பருவம்",
      avgTempC: 33.6,
      avgHumidityPct: 72.0,
      avgRainfallMm: 1.0,
      weatherForecast: "Warm maritime coastal air with afternoon sea breeze",
      primaryMandi: "Kovilpatti Cotton Market & Thoothukudi Market",
    ),
    TamilNaduDistrictProfile(
      id: "tirunelveli",
      name: "Tirunelveli",
      tamilName: "திருநெல்வேலி",
      zoneName: "Southern Agro-Climatic Zone",
      tamilZoneName: "தெற்கு மண்டலம்",
      latitude: 8.7139,
      longitude: 77.7567,
      typicalSoilType: "Tamirabarani River Alluvium & Deep Red Loam",
      typicalPh: 7.0,
      typicalMoisturePct: 31.0,
      majorCrops: ["Paddy (Rice)", "Banana", "Pulses", "Coconut"],
      majorCropsTamil: ["நெல் (அம்பை-16)", "வாழை", "பயறு", "தென்னை"],
      activeSeason: "Kar / Pishanam Season (கார் / பிசானம் பருவம்)",
      seasonTamil: "பிசானம் பருவம் (அக்டோபர் - பிப்ரவரி)",
      avgTempC: 32.0,
      avgHumidityPct: 70.0,
      avgRainfallMm: 2.0,
      weatherForecast: "Tamirabarani basin humidity with cool southern breezes",
      primaryMandi: "Tirunelveli Central Agricultural Market & Ambasamudram",
    ),
    TamilNaduDistrictProfile(
      id: "tenkasi",
      name: "Tenkasi",
      tamilName: "தென்காசி",
      zoneName: "Southern Agro-Climatic Zone",
      tamilZoneName: "தெற்கு மண்டலம்",
      latitude: 8.9594,
      longitude: 77.3161,
      typicalSoilType: "Ghat Foot Soil & River Alluvial Loam",
      typicalPh: 6.8,
      typicalMoisturePct: 32.0,
      majorCrops: ["Paddy", "Banana", "Mango", "Spices (Pepper/Cardamom)", "Coconut"],
      majorCropsTamil: ["நெல்", "வாழை", "மாம்பழம்", "மிளகு / ஏலக்காய்", "தென்னை"],
      activeSeason: "Kar & Pishanam Seasons",
      seasonTamil: "கார் / பிசானம் பருவம்",
      avgTempC: 30.2,
      avgHumidityPct: 74.0,
      avgRainfallMm: 3.5,
      weatherForecast: "Courtallam mountain breeze with intermittent misty showers",
      primaryMandi: "Tenkasi & Alangulam Agricultural Market",
    ),

    // =========================================================================
    // 5. North Eastern Agro-Climatic Zone (Groundnut, Sugarcane & Pulses)
    // =========================================================================
    TamilNaduDistrictProfile(
      id: "tiruvannamalai",
      name: "Tiruvannamalai",
      tamilName: "திருவண்ணாமலை",
      zoneName: "North Eastern Agro-Climatic Zone",
      tamilZoneName: "வடகிழக்கு மண்டலம்",
      latitude: 12.2253,
      longitude: 79.0747,
      typicalSoilType: "Red Sandy Loam (கரிசல் கலந்த செம்மண்)",
      typicalPh: 6.7,
      typicalMoisturePct: 26.0,
      majorCrops: ["Groundnut (VRI-2 / TMV-7)", "Paddy", "Sugarcane", "Sesame (Ellu)"],
      majorCropsTamil: ["நிலக்கடலை (விருத்தாசலம்-2)", "நெல்", "கரும்பு", "எள்ளு"],
      activeSeason: "Chithirai / Aadi Pattam",
      seasonTamil: "ஆடிப்பட்டம் (நிலக்கடலை சாகுபடி)",
      avgTempC: 33.0,
      avgHumidityPct: 56.0,
      avgRainfallMm: 0.0,
      weatherForecast: "Dry sunny climate, ideal for groundnut pegging and pod hardening",
      primaryMandi: "Tiruvannamalai Oilseed Regulated Market",
    ),
    TamilNaduDistrictProfile(
      id: "cuddalore",
      name: "Cuddalore",
      tamilName: "கடலூர்",
      zoneName: "North Eastern Agro-Climatic Zone",
      tamilZoneName: "வடகிழக்கு மண்டலம்",
      latitude: 11.7480,
      longitude: 79.7714,
      typicalSoilType: "Alluvial & Coastal Sandy Loam",
      typicalPh: 6.9,
      typicalMoisturePct: 33.0,
      majorCrops: ["Sugarcane", "Cashew (Kollidam GI)", "Jackfruit (Panruti Palappazham GI)", "Paddy"],
      majorCropsTamil: ["கரும்பு (Co-86032)", "முந்திரி (பண்ருட்டி)", "பலாப்பழம் (பண்ருட்டி பலா GI)", "நெல்"],
      activeSeason: "Samba / Annual Crop Window",
      seasonTamil: "சம்பா பருவம்",
      avgTempC: 31.6,
      avgHumidityPct: 76.0,
      avgRainfallMm: 2.8,
      weatherForecast: "Coastal dampness with moderate North-East monsoon clouds",
      primaryMandi: "Panruti Jackfruit & Cashew Market, Nellikuppam Sugar Mill",
    ),
    TamilNaduDistrictProfile(
      id: "villupuram",
      name: "Villupuram",
      tamilName: "விழுப்புரம்",
      zoneName: "North Eastern Agro-Climatic Zone",
      tamilZoneName: "வடகிழக்கு மண்டலம்",
      latitude: 11.9401,
      longitude: 79.4861,
      typicalSoilType: "Red Sandy Loam & Clayey Loam",
      typicalPh: 6.8,
      typicalMoisturePct: 27.5,
      majorCrops: ["Sugarcane", "Paddy", "Groundnut", "Black Gram"],
      majorCropsTamil: ["கரும்பு", "நெல்", "நிலக்கடலை", "உளுந்து"],
      activeSeason: "Samba / Thaladi",
      seasonTamil: "சம்பா பருவம்",
      avgTempC: 32.4,
      avgHumidityPct: 62.0,
      avgRainfallMm: 1.0,
      weatherForecast: "Warm bright sunshine with clear field scouting conditions",
      primaryMandi: "Villupuram Regulated Agricultural Market",
    ),
    TamilNaduDistrictProfile(
      id: "kallakurichi",
      name: "Kallakurichi",
      tamilName: "கள்ளக்குறிச்சி",
      zoneName: "North Eastern Agro-Climatic Zone",
      tamilZoneName: "வடகிழக்கு மண்டலம்",
      latitude: 11.7384,
      longitude: 78.9639,
      typicalSoilType: "Red Gravelly Loam & Clay Loam",
      typicalPh: 6.7,
      typicalMoisturePct: 26.5,
      majorCrops: ["Paddy", "Sugarcane", "Maize", "Tapioca", "Groundnut"],
      majorCropsTamil: ["நெல்", "கரும்பு", "மக்காச்சோளம்", "மரவள்ளிக்கிழங்கு", "நிலக்கடலை"],
      activeSeason: "Samba / Aadi Pattam",
      seasonTamil: "சம்பா பருவம்",
      avgTempC: 32.5,
      avgHumidityPct: 60.0,
      avgRainfallMm: 0.5,
      weatherForecast: "Clear skies with light evening wind currents",
      primaryMandi: "Kallakurichi Regulated Market",
    ),
    TamilNaduDistrictProfile(
      id: "vellore",
      name: "Vellore",
      tamilName: "வேலூர்",
      zoneName: "North Eastern Agro-Climatic Zone",
      tamilZoneName: "வடகிழக்கு மண்டலம்",
      latitude: 12.9165,
      longitude: 79.1325,
      typicalSoilType: "Red Sandy Loam & Clay Soil",
      typicalPh: 6.8,
      typicalMoisturePct: 25.0,
      majorCrops: ["Paddy", "Groundnut", "Sugarcane", "Banana", "Brinjal"],
      majorCropsTamil: ["நெல்", "நிலக்கடலை", "கரும்பு", "வாழை", "கத்தரி"],
      activeSeason: "Navarai / Samba Season",
      seasonTamil: "நவரை / சம்பா பருவம்",
      avgTempC: 33.5,
      avgHumidityPct: 54.0,
      avgRainfallMm: 0.0,
      weatherForecast: "Warm dry air, steady sunshine throughout the day",
      primaryMandi: "Vellore Central Market",
    ),
    TamilNaduDistrictProfile(
      id: "ranipet",
      name: "Ranipet",
      tamilName: "ராணிப்பேட்டை",
      zoneName: "North Eastern Agro-Climatic Zone",
      tamilZoneName: "வடகிழக்கு மண்டலம்",
      latitude: 12.9299,
      longitude: 79.3333,
      typicalSoilType: "Sandy Clay Loam & Red Soil",
      typicalPh: 6.9,
      typicalMoisturePct: 25.5,
      majorCrops: ["Paddy", "Groundnut", "Banana", "Vegetables", "Flowers"],
      majorCropsTamil: ["நெல்", "நிலக்கடலை", "வாழை", "காய்கறிகள்", "பூக்கள்"],
      activeSeason: "Navarai / Samba",
      seasonTamil: "நவரை பருவம்",
      avgTempC: 33.2,
      avgHumidityPct: 56.0,
      avgRainfallMm: 0.0,
      weatherForecast: "Warm sunny weather with moderate breeze",
      primaryMandi: "Ranipet Agricultural Market",
    ),
    TamilNaduDistrictProfile(
      id: "tirupathur",
      name: "Tirupathur",
      tamilName: "திருப்பத்தூர்",
      zoneName: "North Eastern Agro-Climatic Zone",
      tamilZoneName: "வடகிழக்கு மண்டலம்",
      latitude: 12.4961,
      longitude: 78.5639,
      typicalSoilType: "Red Gravelly Soil & Mountain Foothill Loam",
      typicalPh: 6.6,
      typicalMoisturePct: 24.5,
      majorCrops: ["Paddy", "Groundnut", "Ragi", "Mango", "Coconut"],
      majorCropsTamil: ["நெல்", "நிலக்கடலை", "கேழ்வரகு", "மாம்பழம்", "தென்னை"],
      activeSeason: "Aadi / Purattasi Pattam",
      seasonTamil: "ஆடிப்பட்டம்",
      avgTempC: 31.8,
      avgHumidityPct: 55.0,
      avgRainfallMm: 0.0,
      weatherForecast: "Foothill moderate climate with clear mornings",
      primaryMandi: "Tirupathur Regulated Market",
    ),
    TamilNaduDistrictProfile(
      id: "kanchipuram",
      name: "Kanchipuram",
      tamilName: "காஞ்சிபுரம்",
      zoneName: "North Eastern Agro-Climatic Zone",
      tamilZoneName: "வடகிழக்கு மண்டலம்",
      latitude: 12.8342,
      longitude: 79.7036,
      typicalSoilType: "Clay Loam & Sandy Coastal Alluvium",
      typicalPh: 7.0,
      typicalMoisturePct: 30.0,
      majorCrops: ["Paddy (Rice)", "Groundnut", "Sugarcane", "Watermelon", "Jasmine"],
      majorCropsTamil: ["நெல்", "நிலக்கடலை", "கரும்பு", "தர்பூசணி", "மல்லி"],
      activeSeason: "Samba / Sornavari Season (சொர்ணவாரி பருவம்)",
      seasonTamil: "சொர்ணவாரி பருவம் (ஏப்ரல் - ஜூலை)",
      avgTempC: 32.5,
      avgHumidityPct: 72.0,
      avgRainfallMm: 1.5,
      weatherForecast: "Warm coastal humidity with intermittent sunshine",
      primaryMandi: "Kanchipuram Agricultural Regulated Market",
    ),
    TamilNaduDistrictProfile(
      id: "chengalpattu",
      name: "Chengalpattu",
      tamilName: "செங்கல்பட்டு",
      zoneName: "North Eastern Agro-Climatic Zone",
      tamilZoneName: "வடகிழக்கு மண்டலம்",
      latitude: 12.6819,
      longitude: 79.9888,
      typicalSoilType: "Red Sandy Loam & Palar River Alluvium",
      typicalPh: 6.8,
      typicalMoisturePct: 29.0,
      majorCrops: ["Paddy", "Watermelon", "Groundnut", "Vegetables", "Flowers"],
      majorCropsTamil: ["நெல்", "தர்பூசணி", "நிலக்கடலை", "காய்கறிகள்", "பூக்கள்"],
      activeSeason: "Sornavari / Samba",
      seasonTamil: "சொர்ணவாரி பருவம்",
      avgTempC: 32.4,
      avgHumidityPct: 73.0,
      avgRainfallMm: 1.8,
      weatherForecast: "Coastal moisture with scattered cloud cover",
      primaryMandi: "Madurantakam & Chengalpattu Mandi",
    ),
    TamilNaduDistrictProfile(
      id: "tiruvallur",
      name: "Tiruvallur",
      tamilName: "திருவள்ளூர்",
      zoneName: "North Eastern Agro-Climatic Zone",
      tamilZoneName: "வடகிழக்கு மண்டலம்",
      latitude: 13.1432,
      longitude: 79.9083,
      typicalSoilType: "River Alluvium & Coastal Sandy Loam",
      typicalPh: 6.9,
      typicalMoisturePct: 31.0,
      majorCrops: ["Paddy", "Sugarcane", "Mango", "Watermelon", "Vegetables"],
      majorCropsTamil: ["நெல்", "கரும்பு", "மாம்பழம்", "தர்பூசணி", "காய்கறிகள்"],
      activeSeason: "Samba / Sornavari",
      seasonTamil: "சம்பா பருவம்",
      avgTempC: 32.6,
      avgHumidityPct: 74.0,
      avgRainfallMm: 2.0,
      weatherForecast: "Humid coastal conditions with light coastal clouds",
      primaryMandi: "Tiruvallur Regulated Agricultural Market",
    ),
    TamilNaduDistrictProfile(
      id: "chennai",
      name: "Chennai",
      tamilName: "சென்னை",
      zoneName: "North Eastern Agro-Climatic Zone",
      tamilZoneName: "வடகிழக்கு மண்டலம்",
      latitude: 13.0827,
      longitude: 80.2707,
      typicalSoilType: "Coastal Sandy Alluvium & Clay",
      typicalPh: 7.2,
      typicalMoisturePct: 32.0,
      majorCrops: ["Urban Horticulture (Greens/Keerai)", "Vegetables", "Flowers"],
      majorCropsTamil: ["கீரை வகைகள்", "காய்கறிகள்", "பூக்கள்"],
      activeSeason: "Year-round Green Foliage Cycles",
      seasonTamil: "வருடம் முழுவதும் கீரை சாகுபடி",
      avgTempC: 33.0,
      avgHumidityPct: 78.0,
      avgRainfallMm: 2.5,
      weatherForecast: "High coastal humidity, warm maritime sunshine",
      primaryMandi: "Koyambedu Wholesale Agricultural Market Complex (KWMC)",
    ),

    // =========================================================================
    // 6. High Rainfall Agro-Climatic Zone (Western Ghats Tail & Marine)
    // =========================================================================
    TamilNaduDistrictProfile(
      id: "kanyakumari",
      name: "Kanyakumari",
      tamilName: "கன்னியாகுமரி",
      zoneName: "High Rainfall Agro-Climatic Zone",
      tamilZoneName: "அதிக மழை மண்டலம்",
      latitude: 8.0883,
      longitude: 77.5385,
      typicalSoilType: "Deep Red Laterite Soil (செஞ்சரளை மண்)",
      typicalPh: 5.6,
      typicalMoisturePct: 38.0,
      majorCrops: ["Rubber", "Banana (Matti Vazhai GI)", "Coconut", "Paddy", "Cloves"],
      majorCropsTamil: ["ரப்பர்", "மட்டி வாழை (GI)", "தென்னை", "நெல்", "கிராம்பு"],
      activeSeason: "South-West & North-East Double Monsoon",
      seasonTamil: "இரு பருவ மழை சாகுபடி",
      avgTempC: 28.5,
      avgHumidityPct: 84.0,
      avgRainfallMm: 8.5,
      weatherForecast: "Heavy moisture saturated maritime air, intermittent coastal squalls",
      primaryMandi: "Nagercoil Central Market & Thovalai Flower Market",
    ),

    // =========================================================================
    // 7. Hilly and High Altitude Agro-Climatic Zone (Temperate & Mountain)
    // =========================================================================
    TamilNaduDistrictProfile(
      id: "nilgiris",
      name: "Nilgiris",
      tamilName: "நீலகிரி",
      zoneName: "Hilly and High Altitude Agro-Climatic Zone",
      tamilZoneName: "மலை மற்றும் உயர் குளிர்மண்டலம்",
      latitude: 11.4102,
      longitude: 76.6950,
      typicalSoilType: "Mountain Humus & Acidic Peaty Loam",
      typicalPh: 5.2,
      typicalMoisturePct: 36.0,
      majorCrops: ["Potato (Kufri Jyoti)", "Tea (Nilgiri Tea GI)", "Carrot", "Cabbage", "Garlic"],
      majorCropsTamil: ["உருளைக்கிழங்கு", "தேயிலை (நீலகிரி டீ GI)", "கேரட்", "முட்டைக்கோஸ்", "பூண்டு"],
      activeSeason: "Main Crop Season (April - August) & Autumn Crop",
      seasonTamil: "மலைப்பயிர் பருவம்",
      avgTempC: 17.5,
      avgHumidityPct: 82.0,
      avgRainfallMm: 3.5,
      weatherForecast: "Chilly mountain mist, cool overcast fog, low night temperatures",
      primaryMandi: "Ooty Mettupalayam Potato Market & Coonoor Tea Auction",
    ),
  ];

  /// Returns the default district profile: Thanjavur (Cauvery Delta)
  static TamilNaduDistrictProfile get defaultDistrict => tamilNaduDistricts.first;

  /// Find district by ID or name (case-insensitive)
  static TamilNaduDistrictProfile getDistrict(String query) {
    final q = query.toLowerCase().trim();
    return tamilNaduDistricts.firstWhere(
      (d) =>
          d.id.toLowerCase() == q ||
          d.name.toLowerCase() == q ||
          d.name.toLowerCase().contains(q) ||
          d.tamilName.contains(q) ||
          q.contains(d.name.toLowerCase()),
      orElse: () => defaultDistrict,
    );
  }

  // Real Device GPS Telemetry
  static double? lastRealLatitude;
  static double? lastRealLongitude;
  static double? lastAccuracyMeters;
  static bool wasFetchedFromDeviceGps = false;
  static String? lastGpsStatusMessage;
  static String? detectedTownOrTaluk;

  /// Reverse geocodes coordinates via OpenStreetMap Nominatim with a fast timeout (3.5s).
  /// Resolves the exact administrative district and local town/taluk/village in Tamil Nadu.
  static Future<TamilNaduDistrictProfile?> _reverseGeocodeDistrict(double lat, double lng) async {
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lng&format=json&accept-language=en',
      );
      final response = await http.get(
        uri,
        headers: {'User-Agent': 'AgriSyncApp/1.0 (Tamil Nadu Smart Agriculture Platform)'},
      ).timeout(const Duration(milliseconds: 3500));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final address = data['address'] as Map<String, dynamic>?;
        if (address != null) {
          // Extract town/taluk/village/suburb
          final localPlace = address['town'] ??
              address['village'] ??
              address['suburb'] ??
              address['county'] ??
              address['neighbourhood'];
          if (localPlace != null && localPlace.toString().trim().isNotEmpty) {
            detectedTownOrTaluk = localPlace.toString().trim();
          }

          // Candidate names from the address
          final candidates = [
            address['state_district'],
            address['county'],
            address['city'],
            address['municipality'],
          ].whereType<String>().toList();

          for (final candidate in candidates) {
            final cleaned = candidate
                .replaceAll('District', '')
                .replaceAll('district', '')
                .replaceAll('Taluk', '')
                .replaceAll('taluk', '')
                .trim()
                .toLowerCase();

            for (final d in tamilNaduDistricts) {
              if (d.name.toLowerCase() == cleaned ||
                  d.id.toLowerCase() == cleaned ||
                  cleaned.contains(d.name.toLowerCase()) ||
                  d.name.toLowerCase().contains(cleaned)) {
                return d;
              }
            }
          }
        }
      }
    } catch (_) {
      // Offline or network timeout: gracefully falls back to calibrated centroid matching
    }
    return null;
  }

  /// Live Device GPS Location Detection:
  /// Accesses physical device GPS hardware via Geolocator, queries live latitude & longitude,
  /// and resolves coordinates directly to the closest Tamil Nadu agro-climatic district.
  static Future<TamilNaduDistrictProfile> fetchCurrentLocation({
    double? manualLat,
    double? manualLng,
  }) async {
    // 1. If manual coordinates are provided (e.g. in test suites or map picker)
    if (manualLat != null && manualLng != null) {
      lastRealLatitude = manualLat;
      lastRealLongitude = manualLng;
      wasFetchedFromDeviceGps = true;
      lastGpsStatusMessage = "Coordinates applied: ${manualLat.toStringAsFixed(4)}° N, ${manualLng.toStringAsFixed(4)}° E";
      
      final onlineDist = await _reverseGeocodeDistrict(manualLat, manualLng);
      if (onlineDist != null) {
        return onlineDist;
      }
      return _findClosestDistrict(manualLat, manualLng);
    }

    // 2. Query real device hardware GPS via Geolocator
    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (lastRealLatitude != null && lastRealLongitude != null) {
          final onlineDist = await _reverseGeocodeDistrict(lastRealLatitude!, lastRealLongitude!);
          if (onlineDist != null) return onlineDist;
          return _findClosestDistrict(lastRealLatitude!, lastRealLongitude!);
        }
        lastGpsStatusMessage = "Device GPS service disabled. Please turn on Location in system settings.";
        return defaultDistrict;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          lastGpsStatusMessage = "Location permission denied. Using calibrated regional default.";
          return defaultDistrict;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        lastGpsStatusMessage = "Location permission permanently denied. Using regional default.";
        return defaultDistrict;
      }

      // Fetch live GPS coordinates with 8s timeout
      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 8),
          ),
        );
      } catch (_) {
        // Fallback to last known position if current request timed out
        position = await Geolocator.getLastKnownPosition();
      }

      if (position != null) {
        lastRealLatitude = position.latitude;
        lastRealLongitude = position.longitude;
        lastAccuracyMeters = position.accuracy;
        wasFetchedFromDeviceGps = true;
        lastGpsStatusMessage = "GPS Locked: ${position.latitude.toStringAsFixed(4)}° N, ${position.longitude.toStringAsFixed(4)}° E (±${position.accuracy.toStringAsFixed(0)}m)";

        // Try online reverse geocoding first for taluk/district precision
        final onlineDist = await _reverseGeocodeDistrict(position.latitude, position.longitude);
        if (onlineDist != null) {
          return onlineDist;
        }

        return _findClosestDistrict(position.latitude, position.longitude);
      }
    } catch (e) {
      lastGpsStatusMessage = "GPS acquisition error: $e";
    }

    return defaultDistrict;
  }

  static TamilNaduDistrictProfile _findClosestDistrict(double lat, double lng) {
    TamilNaduDistrictProfile closest = defaultDistrict;
    double minDistance = double.infinity;

    for (var d in tamilNaduDistricts) {
      final dist = _haversineDistance(lat, lng, d.latitude, d.longitude);
      if (dist < minDistance) {
        minDistance = dist;
        closest = d;
      }
    }
    return closest;
  }

  static double _haversineDistance(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371.0; // Earth radius in km
    final dLat = (lat2 - lat1) * (pi / 180.0);
    final dLon = (lon2 - lon1) * (pi / 180.0);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * (pi / 180.0)) * cos(lat2 * (pi / 180.0)) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return r * c;
  }
}
