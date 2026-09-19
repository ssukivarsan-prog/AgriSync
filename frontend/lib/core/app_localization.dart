enum AppLanguage {
  english,
  tamil,
}

class AppLocalization {
  static const Map<String, String> _en = {
    // Navigation
    'nav_home': 'Home',
    'nav_field': 'Field',
    'nav_scan': 'AI Scan',
    'nav_insights': 'Insights',
    'nav_more': 'More',
    
    // Common / General
    'app_name': 'AgriVyn',
    'app_tagline': 'Prevent. Predict. Protect.',
    'save': 'Save',
    'cancel': 'Cancel',
    'retry': 'Retry',
    'normal': 'NORMAL',
    'warning': 'WARNING',
    'critical': 'CRITICAL',
    'healthy': 'HEALTHY',
    'at_risk': 'AT RISK',
    'high_confidence': 'High Confidence',
    'view_all': 'View All >',
    'acre_map': 'Acre Map >',
    'more_options': 'More Options',
    'alerts': 'Alerts',
    'assistant': 'AgriSync Assistant',
    
    // Farmer Greeting & Scenario
    'greeting_namaste': 'Namaste',
    'switch_scenario': 'Demo Scenario',
    'farmer_profile': 'Farmer Profile',
    'help_tour': 'Interactive Help Tour',
    'settings_scenarios': 'Settings & Scenarios',
    
    // Farm Risk Card
    'current_farm_risk_score': 'CURRENT FARM RISK SCORE',
    'recommended_action': 'RECOMMENDED ACTION',
    
    // Core Question 1: What Should I Sow?
    'what_should_i_sow': 'WHAT SHOULD I SOW?',
    'crop_forecast_subtitle': 'Location-Based Crop & Outbreak Forecast',
    'suitability': 'SUITABILITY',
    'predicted_disease_risk': 'Predicted Disease Risk',
    
    // Core Question 2: How Is My Field Doing?
    'how_is_my_field_doing': 'HOW IS MY FIELD DOING?',
    'metric_soil_moisture': 'Soil Moisture',
    'metric_soil_ph': 'Soil pH',
    'metric_nitrogen': 'Nitrogen (N)',
    'metric_phosphorus': 'Phosphorus (P)',
    'metric_potassium': 'Potassium (K)',
    'metric_soil_temp': 'Soil Temperature',
    'metric_air_temp': 'Air Temperature',
    'metric_humidity': 'Humidity',
    
    // Weather
    'weather_intelligence': 'WEATHER INTELLIGENCE',
    'weather_source': 'IMD Gridded Agro-Meteorological Network',
    'weather_today_rain': 'Today Rain',
    'weather_forecast_3d': '3-Day Forecast',
    'weather_heat_index': 'Heat Index',
    'weather_et0': 'Evapotranspiration',
    
    // Alerts Sheet
    'alerts_sheet_title': 'Field & Weather Alerts',
    'alert_live': 'Live Alert',
    'what_happened_prefix': 'WHAT HAPPENED:',
    'action_needed_prefix': 'ACTION:',
    'weather_advisory_title': 'Weather Intelligence Advisory',
    'weather_advisory_action': 'Review field drainage and plan irrigation cycles accordingly.',
    'presowing_title': 'Pre-Sowing Crop Suitability Ready',
    'presowing_desc': 'Model evaluated soil chemistry and previous crop history for seasonal planning.',
    'presowing_action': 'Check pre-sowing recommendations before purchasing seeds.',
    'time_yesterday': 'Yesterday',
    'time_1hr_ago': '1 hour ago',
    
    // AI Diagnosis Screen
    'ai_diagnosis_title': 'AI Crop Diagnosis & Context Fusion',
    'ai_diagnosis_subtitle': 'Photos + Videos + Zone IoT + Agronomy',
    'location_zone_card': 'LOCATION & AGRO-CLIMATIC ZONE',
    'device_gps_btn': 'Device GPS',
    'locating': 'Locating...',
    'select_district': 'Select District',
    'sowing_outbreak_btn': '🌱 View Sowing & Disease Outbreak Forecast',
    'select_field_zone': '1. SELECT OBSERVED FIELD ZONE',
    'fuses_telemetry': 'Fuses local soil telemetry',
    'submit_evidence': '2. SUBMIT EVIDENCE (PHOTOS OR VIDEO)',
    'video_mode_active': 'Video Mode Active',
    'photos_counter': 'photos',
    'evidence_hint': 'Upload leaf photos or a 15–30s canopy sweep video for temporal motion & underside pest detection.',
    'take_photo': 'Take Photo',
    'upload_photos': 'Upload Photos',
    'record_video': 'Record Video (30s)',
    'upload_video': 'Upload Video',
    'quick_samples_title': 'Quick Test with Zone-Specific AI Samples:',
    'run_diagnosis_photo': 'Run Multi-Modal AI Diagnosis & Context Fusion',
    'run_diagnosis_video': 'Run AI Video & Context Fusion Diagnosis',
    'analyzing_photo': 'Running Context Fusion Engine...',
    'analyzing_video': 'Extracting Keyframes & Running Temporal Fusion...',
    
    // Zone-specific sample chip labels (English)
    'sample_paddy_blast': 'Paddy Blast',
    'sample_paddy_pest': 'Planthopper Pest',
    'sample_tomato_blight': 'Early Blight',
    'sample_tomato_pest': 'Tomato Whitefly',
    'sample_banana_sigatoka': 'Banana Sigatoka',
    'sample_banana_pest': 'Pseudostem Borer',
    'sample_nitrogen': 'Nitrogen Deficiency',
    'sample_healthy': 'Healthy Foliage',
    'sample_fallow_ready': 'Sowing Ready Seedbed',
    'sample_fallow_nitrogen': 'Soil Nitrogen Test',
    'sample_soil_pest': 'Soil White Grubs',
    'sample_groundnut_tikka': 'Groundnut Tikka Spot',

    // Fusion Assessment UI Headers (English)
    'context_fusion_assessment': 'CONTEXT FUSION ASSESSMENT',
    'fused_evidence_header': 'FUSED MULTI-STREAM EVIDENCE:',
    'visual_observation_label': 'Visual Observation',
    'insect_observation_label': 'Insect Observation',
    'zone_telemetry_label': 'Zone IoT Telemetry',
    'regional_climate_label': 'Regional Climate',
    'video_dynamics_label': 'Video Dynamics',
    'tnau_protocol_header': 'TAMIL NADU AGRICULTURAL UNIVERSITY (TNAU) PROTOCOL',
    'recommended_action_header': 'RECOMMENDED ACTION FOR FARMER',
    'preventative_protocol_header': 'PREVENTATIVE PROTOCOL:',
    'tnau_guides_available': 'Tamil Nadu Agronomy Guides Available',
    'read_guide_btn': 'Read Guide',
    'match_suffix': 'match',
    'calibrated_prefix': '📍 Calibrated:',
    'video_frames_analyzed': '🎥 Temporal Video Sweeps Analyzed',
    
    // Diagnosis Results
    'diagnostic_results_title': 'MULTI-MODAL DIAGNOSTIC REPORT',
    'overall_status': 'Overall Foliar Status',
    'disease_detected': 'Disease Pathogen',
    'pest_detected': 'Insect Pest Vector',
    'nutrient_status': 'Nutrient Status',
    'affected_area': 'Affected Leaf Area',
    'tnau_protocol': 'TNAU Recommended Management Protocol',
    'immediate_action': 'Immediate Field Action',

    // Scan Screen Labels
    'ai_scan_title': 'AI Crop Health Scan',
    'capture_select_photo': 'Capture or Select Leaf Photo',
    'capture_hint': 'Take a clear, close-up photo of a single crop leaf in natural daylight for instant disease, pest & nutrient diagnosis.',
    'open_camera': 'Open Camera',
    'from_gallery': 'From Gallery',
    'record_video_btn': 'Record Video',
    'upload_video_btn': 'Upload Video',
    'analyze_btn': 'Analyze Foliage with AgriSync AI',
    'analyzing_btn': 'Running AI Vision Models...',
    'change_district_btn': 'Change District',
    'clear_btn': 'Clear',
    'switch_to_photos': 'Switch to Photos',
    're_record_video': 'Re-Record Video',
    'video_loaded_title': 'CROP CANOPY VIDEO LOADED',
    'keyframes_label': 'Keyframes Sampled',
    'underside_tracking': 'Underside Pest Tracking Enabled',
    
    // Diagnostic result section headers
    'sect_crop_health': 'CROP HEALTH',
    'sect_ai_confidence': 'AI Diagnostic Confidence',
    'sect_pest_status': 'PEST STATUS',
    'sect_nutrients': 'NUTRIENTS',
    'sect_lesion_area': 'LESION AREA',
    'sect_clean_foliage': 'Clean Foliage',
    'sect_zero_pests': 'Zero Pests',
    'sect_balanced': 'Balanced',
    'sect_root_cause': 'MULTI-FACTOR ROOT CAUSE ANALYSIS',
    'sect_action_plan': 'PRACTICAL FARMER ACTION PLAN',
    'pillar_climate': 'Climate & Weather Trigger',
    'pillar_soil': 'Soil Chemistry & NPK / pH',
    'pillar_humidity': 'Canopy Air Moisture & Humidity',
    'pillar_social': 'Surrounding Fields & Social Context',
    'watch_video_btn': '🎥 Watch Video & Practical Farmer Guide',
    'sightings': 'sightings',
    'conf_suffix': '% Conf.',
    'kb_ready': 'KB • Ready for AI Analysis',
    'change_btn': 'Change',
    'video_field_loaded': 'Field Inspection Video Loaded',
    'video_temporal_hint': 'Temporal canopy sweep and underside leaf pest movement will be analyzed across extracted keyframes.',
    'select_zone_hint': 'Scan results will be matched to the planted crop in the selected zone.',
    'sightings_counter': 'sightings',
    'lesion_none': 'None',
    'confidence_label': 'Confidence',
    
    // Crop Recommendation Screen Tabs & Controls
    'crop_intelligence_title': 'Crop Intelligence',
    'crop_intelligence_sub': 'Sowing & Disease Outbreak Forecast',
    'tab_crops_to_sow': 'CROPS TO SOW',
    'tab_disease_risks': 'DISEASE RISKS',
    'tab_rotation': 'ROTATION',
    'cost_roi_title': 'Cost & ROI Estimation',
    'cost_roi_desc': 'Generate financial quote for this season.',
    'get_quote_btn': 'Get Quote',
    'gps_prefix': 'GPS: ',
    'location_prefix': 'LOCATION: ',
    'hardware_prefix': '📡 Hardware: ',
    'tinyml_prefix': ' • TinyML: ',
    'rescan_btn': 'Re-scan',
    'fit_suffix': '% FIT',
    
    // Field Monitoring Screen
    'field_monitoring_title': 'Field Monitoring & Acre Map',
    'field_monitoring_sub': 'Interactive Geospatial Acreage & Root-Zone Sensors',
    'farm_sectors_prefix': 'FARM SECTORS',
    'sensor_net_active': 'IOT SENSOR NET ACTIVE',
    'acres_unit': 'Ac',
    
    // Crop Quotation Screen
    'quotation_title': 'Smart Crop Financial Quotation',
    'select_quotation_zone': '1. SELECT CULTIVATION IOT ZONE',
    'empty_plot_active': 'EMPTY PLOT ACTIVE',
    'occupied_plot_active': 'OCCUPIED PLOT ACTIVE',
    
    // Environmental Risk Screen
    'env_screen_title': 'Environmental Risk Engine',
    'env_sim_params': 'WEATHER & SOIL SIMULATION PARAMETERS',
    'temp_param': 'Temperature',
    'rel_humidity_param': 'Relative Humidity',
    'soil_moisture_param': 'Soil Moisture',
    'rainfall_param': 'Past 24h Rainfall',
    'wind_speed_param': 'Wind Speed',
    'forecast_rain_param': 'Rain Forecast (Next 24h)',
    
    // Quick Entry Setup
    'quick_entry_title': 'AgriVyn Farm Access',
    'quick_setup': 'QUICK SETUP',
    'welcome_farmer': 'Welcome, Farmer!',
    'setup_subtitle': 'Verify your field location and details for instant AI crop protection.',
    'farmer_name': 'Farmer Name',
    'phone_number': 'Phone Number',
    'farm_location': 'Farm Location / District',
    'enter_farm_app': 'Enter Farm Dashboard',
    
    // Language Switcher
    'language': 'Language',
    'english_label': 'English',
    'tamil_label': 'தமிழ்',
  };

  static const Map<String, String> _ta = {
    // Navigation
    'nav_home': 'முகப்பு',
    'nav_field': 'வயல்',
    'nav_scan': 'AI ஸ்கேன்',
    'nav_insights': 'பகுப்பாய்வு',
    'nav_more': 'மேலும்',
    
    // Common / General
    'app_name': 'அக்ரிவைன்',
    'app_tagline': 'தடுப்போம். கணிப்போம். பாதுகாப்போம்.',
    'save': 'சேமி',
    'cancel': 'ரத்து செய்',
    'retry': 'மீண்டும் முயற்சி செய்',
    'normal': 'நலம்',
    'warning': 'எச்சரிக்கை',
    'critical': 'அவசர கவனம்',
    'healthy': 'ஆரோக்கியமானது',
    'at_risk': 'பாதிப்பு அபாயம்',
    'high_confidence': 'அதிக துல்லியம்',
    'view_all': 'அனைத்தும் பார்க்க >',
    'acre_map': 'ஏக்கர் வரைபடம் >',
    'more_options': 'கூடுதல் தேர்வுகள்',
    'alerts': 'எச்சரிக்கைகள்',
    'assistant': 'அக்ரிவைன் AI உதவியாளர்',
    
    // Farmer Greeting & Scenario
    'greeting_namaste': 'வணக்கம்',
    'switch_scenario': 'மாதிரி சூழ்நிலை',
    'farmer_profile': 'விவசாயி விவரக்குறிப்பு',
    'help_tour': 'செயலி வழிகாட்டி',
    'settings_scenarios': 'அமைப்புகள் & சூழல்கள்',
    
    // Farm Risk Card
    'current_farm_risk_score': 'தற்போதைய பண்ணை இடர் மதிப்பீடு',
    'recommended_action': 'பரிந்துரைக்கப்படும் உடனடி நடவடிக்கை',
    
    // Core Question 1: What Should I Sow?
    'what_should_i_sow': 'என்ன பயிர் நடவு செய்ய வேண்டும்?',
    'crop_forecast_subtitle': 'இருப்பிட அடிப்படையிலான பயிர் & நோய் முன்னறிவிப்பு',
    'suitability': 'பொருத்தம்',
    'predicted_disease_risk': 'எதிர்பார்க்கப்படும் நோய் பாதிப்பு',
    
    // Core Question 2: How Is My Field Doing?
    'how_is_my_field_doing': 'என் வயல் நலம் எவ்வாறு உள்ளது?',
    'metric_soil_moisture': 'மண் ஈரப்பதம்',
    'metric_soil_ph': 'மண் கார அமிலத்தன்மை (pH)',
    'metric_nitrogen': 'தழைச்சத்து (N)',
    'metric_phosphorus': 'மணிச்சத்து (P)',
    'metric_potassium': 'சாம்பல்ச்சத்து (K)',
    'metric_soil_temp': 'மண் வெப்பநிலை',
    'metric_air_temp': 'காற்று வெப்பநிலை',
    'metric_humidity': 'காற்றின் ஈரப்பதம்',
    
    // Weather
    'weather_intelligence': 'வானிலை முன்னறிவிப்பு',
    'weather_source': 'இந்திய வானிலை ஆய்வு மையம் (IMD)',
    'weather_today_rain': 'இன்றைய மழை',
    'weather_forecast_3d': '3 நாள் கணிப்பு',
    'weather_heat_index': 'வெப்பக் குறியீடு',
    'weather_et0': 'நீர் ஆவியாதல் அளவு',
    
    // Alerts Sheet
    'alerts_sheet_title': 'வயல் & வானிலை எச்சரிக்கைகள்',
    'alert_live': 'நேரடி எச்சரிக்கை',
    'what_happened_prefix': 'என்ன நிகழ்ந்தது:',
    'action_needed_prefix': 'உடனடி நடவடிக்கை:',
    'weather_advisory_title': 'வானிலை ஆலோசனை அறிக்கை',
    'weather_advisory_action': 'வயல் வடிகால்களை ஆய்வு செய்து பாசனத்தை திட்டமிடுங்கள்.',
    'presowing_title': 'விதைப்புக்கு முந்தைய பயிர் பொருத்தம் தயார்',
    'presowing_desc': 'மண் வேதியியல் மற்றும் முந்தைய பயிர் வரலாற்றை ஆய்வு செய்து பரிந்துரைகள் கணிக்கப்பட்டுள்ளன.',
    'presowing_action': 'விதைகள் வாங்குவதற்கு முன் பரிந்துரைக்கப்பட்ட பயிர்களை சரிபார்க்கவும்.',
    'time_yesterday': 'நேற்று',
    'time_1hr_ago': '1 மணி நேரத்திற்கு முன்',
    
    // AI Diagnosis Screen
    'ai_diagnosis_title': 'AI பயிர் நோய் & சூழ்நிலை பகுப்பாய்வு',
    'ai_diagnosis_subtitle': 'புகைப்படம் + காணொளி + சென்சார் + வேளாண் மேலாண்மை',
    'location_zone_card': 'இருப்பிடம் & வேளாண் தட்பவெப்ப மண்டலம்',
    'device_gps_btn': 'ஜிபிஎஸ் இருப்பிடம்',
    'locating': 'கண்டறிகிறது...',
    'select_district': 'மாவட்டம் தேர்வு',
    'sowing_outbreak_btn': '🌱 விதைப்பு & நோய் முன்னறிவிப்பு காண்க',
    'select_field_zone': '1. ஆய்வு செய்ய வேண்டிய வயல் பகுதியை தேர்வு செய்க',
    'fuses_telemetry': 'மண் சென்சார் தரவுகளுடன் இணைக்கப்படுகிறது',
    'submit_evidence': '2. பயிர் ஆதாரம் பதிவேற்றுக (படம் அல்லது வீடியோ)',
    'video_mode_active': 'வீடியோ முறை செயல்படுகிறது',
    'photos_counter': 'படங்கள்',
    'evidence_hint': 'இலைகளின் அடியில் உள்ள பூச்சிகள் மற்றும் இயக்கத்தை கண்டறிய தெளிவான புகைப்படம் அல்லது 30 வினாடி வீடியோ எடுக்கவும்.',
    'take_photo': 'புகைப்படம் எடு',
    'upload_photos': 'படங்கள் பதிவேற்று',
    'record_video': 'வீடியோ பதிவு (30 வி)',
    'upload_video': 'வீடியோ பதிவேற்று',
    'quick_samples_title': 'வயல் பகுதிக்கு ஏற்ற மாதிரி படங்களை சோதனை செய்க:',
    'run_diagnosis_photo': 'AI பயிர் நோய் கண்டறிதலை இயக்குக',
    'run_diagnosis_video': 'AI வீடியோ & சூழ்நிலை பகுப்பாய்வு இயக்குக',
    'analyzing_photo': 'பயிர் நலம் பகுப்பாய்வு செய்யப்படுகிறது...',
    'analyzing_video': 'வீடியோ அசைவுகள் பிரித்தெடுக்கப்பட்டு ஆய்வு செய்யப்படுகிறது...',

    // Zone-specific sample chip labels (Tamil)
    'sample_paddy_blast': 'நெல் குலை நோய்',
    'sample_paddy_pest': 'நெல் புகையான்',
    'sample_tomato_blight': 'முன் கருகல் நோய்',
    'sample_tomato_pest': 'வெள்ளை ஈ தாக்குதல்',
    'sample_banana_sigatoka': 'சிகடோகா இலைப்புள்ளி',
    'sample_banana_pest': 'தண்டு துளைப்பான்',
    'sample_nitrogen': 'தழைச்சத்து குறைபாடு',
    'sample_healthy': 'ஆரோக்கியமான இலை',
    'sample_fallow_ready': 'விதைப்புக்கு உகந்த நிலம்',
    'sample_fallow_nitrogen': 'மண் தழைச்சத்து ஆய்வு',
    'sample_soil_pest': 'மண் வெள்ளைப்புழுக்கள்',
    'sample_groundnut_tikka': 'நிலக்கடலை டிக்கா நோய்',

    // Fusion Assessment UI Headers (Tamil)
    'context_fusion_assessment': 'பல்கூறு சூழல் ஆய்வு முடிவு',
    'fused_evidence_header': 'ஒருங்கிணைந்த பல்துறை ஆதாரங்கள்:',
    'visual_observation_label': 'கணினி பார்வை (CV)',
    'insect_observation_label': 'பூச்சி கண்காணிப்பு',
    'zone_telemetry_label': 'சென்சார் அளவீடு (IoT)',
    'regional_climate_label': 'வானிலை சூழல்',
    'video_dynamics_label': 'வீடியோ பகுப்பாய்வு',
    'tnau_protocol_header': 'தமிழ்நாடு வேளாண்மைப் பல்கலைக்கழக (TNAU) வழிகாட்டுதல்',
    'recommended_action_header': 'விவசாயிக்கான உடனடி பரிந்துரை',
    'preventative_protocol_header': 'தடுப்பு முறைகள் & வழிகாட்டுதல்கள்:',
    'tnau_guides_available': 'TNAU வேளாண் சாகுபடி கையேடு',
    'read_guide_btn': 'கையேட்டைப் படிக்க',
    'match_suffix': 'பொருத்தம்',
    'calibrated_prefix': '📍 பயிர் மண்டலம்:',
    'video_frames_analyzed': '🎥 வீடியோ தொடர் பிரேம்கள் ஆய்வு செய்யப்பட்டன',

    // Scan Screen Labels (Tamil)
    'ai_scan_title': 'AI பயிர் நலம் ஸ்கேன்',
    'capture_select_photo': 'இலைப் புகைப்படம் எடுக்கவும் அல்லது தேர்வு செய்யவும்',
    'capture_hint': 'பயிர் நோய், பூச்சி மற்றும் ஊட்டச்சத்து கண்டறிய ஒரு இலையின் தெளிவான, தயார் நிலை புகைப்படம் எடுக்கவும்.',
    'open_camera': 'கேமரா திறக்கவும்',
    'from_gallery': 'கேலரியில் இருந்து',
    'record_video_btn': 'வீடியோ பதிவு செய்க',
    'upload_video_btn': 'வீடியோ பதிவேற்று',
    'analyze_btn': 'AgriSync AI மூலம் இலை ஆய்வு செய்க',
    'analyzing_btn': 'AI கண்ணோட்ட மாதிரிகள் இயங்குகின்றன...',
    'change_district_btn': 'மாவட்டம் மாற்று',
    'clear_btn': 'அழி',
    'switch_to_photos': 'படங்களுக்கு மாற்று',
    're_record_video': 'மீண்டும் வீடியோ பதிவு',
    'video_loaded_title': 'வயல் வீடியோ ஏற்றப்பட்டது',
    'keyframes_label': 'முக்கிய சட்டங்கள் எடுக்கப்பட்டன',
    'underside_tracking': 'இலை அடிப்பக்க பூச்சி கண்காணிப்பு இயக்கத்தில் உள்ளது',

    // Diagnostic result section headers (Tamil)
    'sect_crop_health': 'பயிர் நலன்',
    'sect_ai_confidence': 'AI கண்டறிதல் துல்லியம்',
    'sect_pest_status': 'பூச்சி நிலை',
    'sect_nutrients': 'ஊட்டச்சத்து',
    'sect_lesion_area': 'நோய் பரவல் பரப்பு',
    'sect_clean_foliage': 'நோயற்ற இலைகள்',
    'sect_zero_pests': 'பூச்சி இல்லை',
    'sect_balanced': 'சமநிலை',
    'sect_root_cause': 'பன்முக மூல காரண பகுப்பாய்வு',
    'sect_action_plan': 'விவசாயி உடனடி நடவடிக்கை திட்டம்',
    'pillar_climate': 'தட்பவெப்ப & வானிலை தூண்டுதல்',
    'pillar_soil': 'மண் வேதியியல் & NPK / pH',
    'pillar_humidity': 'மேல்கதிர் ஈரப்பதம் & ஈரம்',
    'pillar_social': 'சுற்றியுள்ள வயல்கள் & சமூக சூழல்',
    'watch_video_btn': '🎥 வீடியோ பார்க்க & விவசாயி கையேடு',
    'sightings': 'கண்டுபிடிப்புகள்',
    'conf_suffix': '% துல்லியம்',
    'kb_ready': 'KB • AI ஆய்விற்கு தயாராக உள்ளது',
    'change_btn': 'மாற்று',
    'video_field_loaded': 'வயல் ஆய்வு வீடியோ ஏற்றப்பட்டது',
    'video_temporal_hint': 'வீடியோ அசைவு மற்றும் இலை அடிப்பக்க பூச்சி இயக்கம் பகுப்பாய்வு செய்யப்படும்.',
    'select_zone_hint': 'தேர்ந்தெடுக்கப்பட்ட வயலில் விளைந்த பயிருக்கு ஏற்றவாறு முடிவுகள் வழங்கப்படும்.',
    'sightings_counter': 'கண்டுபிடிப்புகள்',
    'lesion_none': 'இல்லை',
    'confidence_label': 'துல்லியம்',
    
    // Diagnosis Results
    'diagnostic_results_title': 'பயிர் நோய் கண்டறிதல் அறிக்கை',
    'overall_status': 'பயிர் இலைகளின் ஒட்டுமொத்த நலம்',
    'disease_detected': 'தாக்கியுள்ள நோய் நுண்ணுயிரி',
    'pest_detected': 'தாக்கியுள்ள பூச்சி / வெக்டார்',
    'nutrient_status': 'ஊட்டச்சத்து நிலை',
    'affected_area': 'பாதிக்கப்பட்ட இலை பரப்பு',
    'tnau_protocol': 'TNAU தமிழ்நாடு வேளாண் பல்கலைக்கழக மேலாண்மை முறை',
    'immediate_action': 'உடனடி கள நடவடிக்கை',
    
    // Crop Recommendation Screen Tabs & Controls (Tamil)
    'crop_intelligence_title': 'பயிர் நுண்ணறிவு',
    'crop_intelligence_sub': 'விதைப்பு & நோய் பரவல் முன்னறிவிப்பு',
    'tab_crops_to_sow': 'விதைக்க உகந்த பயிர்கள்',
    'tab_disease_risks': 'நோய் அபாயங்கள்',
    'tab_rotation': 'பயிர் சுழற்சி',
    'cost_roi_title': 'செலவு & லாப மதிப்பீடு',
    'cost_roi_desc': 'இப்பருவத்திற்கான பயிர் திட்ட மதிப்பீட்டை உருவாக்குக.',
    'get_quote_btn': 'மதிப்பீடு பெறுக',
    'gps_prefix': 'ஜிபிஎஸ்: ',
    'location_prefix': 'இருப்பிடம்: ',
    'hardware_prefix': '📡 சென்சார் சாதனம்: ',
    'tinyml_prefix': ' • TinyML கணிப்பு: ',
    'rescan_btn': 'மறு ஆய்வு',
    'fit_suffix': '% பொருத்தம்',
    
    // Field Monitoring Screen (Tamil)
    'field_monitoring_title': 'வயல் கண்காணிப்பு & வரைபடம்',
    'field_monitoring_sub': 'நேரடி வயல் பரப்பு & வேர் மண்டல சென்சார்கள்',
    'farm_sectors_prefix': 'பண்ணை மண்டலங்கள்',
    'sensor_net_active': 'சென்சார் இணைப்பு இயங்குகிறது',
    'acres_unit': 'ஏக்கர்',
    
    // Crop Quotation Screen (Tamil)
    'quotation_title': 'பயிர் நிதி & திட்ட மதிப்பீடு',
    'select_quotation_zone': '1. சாகுபடி வயல் பகுதியை தேர்வு செய்க',
    'empty_plot_active': 'தரிசு நிலம் தயார்',
    'occupied_plot_active': 'பயிரிடப்பட்ட நிலம்',
    
    // Environmental Risk Screen (Tamil)
    'env_screen_title': 'சுற்றுச்சூழல் இடர் கணிப்பு',
    'env_sim_params': 'வானிலை & மண் மாதிரி அளவீடுகள்',
    'temp_param': 'வெப்பநிலை',
    'rel_humidity_param': 'காற்றின் ஈரப்பதம்',
    'soil_moisture_param': 'மண் ஈரப்பதம்',
    'rainfall_param': 'கடந்த 24 மணி நேர மழை',
    'wind_speed_param': 'காற்றின் வேகம்',
    'forecast_rain_param': 'மழை முன்னறிவிப்பு (அடுத்த 24 மணி நேரம்)',

    // Quick Entry Setup
    'quick_entry_title': 'அக்ரிவைன் பண்ணை பதிவு',
    'quick_setup': 'உடனடி பதிவு',
    'welcome_farmer': 'வணக்கம், விவசாயி!',
    'setup_subtitle': 'AI பயிர் பாதுகாப்பு பெற உங்கள் பண்ணை விவரங்களை சரிபார்க்கவும்.',
    'farmer_name': 'விவசாயி பெயர்',
    'phone_number': 'தொலைபேசி எண்',
    'farm_location': 'பண்ணை இருப்பிடம் / மாவட்டம்',
    'enter_farm_app': 'பண்ணை முகப்பிற்கு செல்க',
    
    // Language Switcher
    'language': 'மொழி',
    'english_label': 'English',
    'tamil_label': 'தமிழ்',
  };

  static String tr(String key, {required bool isTamil}) {
    final map = isTamil ? _ta : _en;
    return map[key] ?? _en[key] ?? key;
  }

  // ---------------------------------------------------------------------------
  // Clean Crops
  // ---------------------------------------------------------------------------
  static String cropName(String crop, {required bool isTamil}) {
    final lower = crop.toLowerCase();
    if (lower.contains('paddy') || lower.contains('rice') || lower.contains('நெல்')) {
      return isTamil ? 'நெல்' : 'Paddy (Rice)';
    }
    if (lower.contains('tomato') || lower.contains('thakkali') || lower.contains('தக்காளி')) {
      return isTamil ? 'தக்காளி' : 'Tomato';
    }
    if (lower.contains('banana') || lower.contains('vazhai') || lower.contains('வாழை')) {
      return isTamil ? 'வாழை' : 'Banana';
    }
    if (lower.contains('sugarcane') || lower.contains('karumbu') || lower.contains('கரும்பு')) {
      return isTamil ? 'கரும்பு' : 'Sugarcane';
    }
    if (lower.contains('turmeric') || lower.contains('manjal') || lower.contains('மஞ்சள்')) {
      return isTamil ? 'மஞ்சள்' : 'Turmeric';
    }
    if (lower.contains('groundnut') || lower.contains('kadalai') || lower.contains('கடலை')) {
      return isTamil ? 'நிலக்கடலை' : 'Groundnut';
    }
    if (lower.contains('coconut') || lower.contains('thennai') || lower.contains('தென்னை')) {
      return isTamil ? 'தென்னை' : 'Coconut';
    }
    if (lower.contains('black gram') || lower.contains('ulundu') || lower.contains('உளுந்து')) {
      return isTamil ? 'உளுந்து' : 'Black Gram';
    }
    if (lower.contains('cotton') || lower.contains('paruthi') || lower.contains('பருத்தி')) {
      return isTamil ? 'பருத்தி' : 'Cotton';
    }
    if (lower.contains('maize') || lower.contains('corn') || lower.contains('மக்காச்சோளம்')) {
      return isTamil ? 'மக்காச்சோளம்' : 'Corn (Maize)';
    }
    if (lower.contains('fallow') || lower.contains('தரிசு') || lower.contains('empty')) {
      return isTamil ? 'தரிசு நிலம் (விதைப்புக்கு தயார்)' : 'Fallow (Ready for Sowing)';
    }
    return isTamil ? cleanTamil(crop) : cleanEnglish(crop);
  }

  // ---------------------------------------------------------------------------
  // Clean Growth Stages
  // ---------------------------------------------------------------------------
  static String stageName(String stage, {required bool isTamil}) {
    final lower = stage.toLowerCase();
    if (lower.contains('tillering') || lower.contains('தூர்')) {
      return isTamil ? 'தூர்கட்டும் பருவம்' : 'Tillering Stage';
    }
    if (lower.contains('flowering') || lower.contains('பூக்கும்')) {
      return isTamil ? 'பூக்கும் பருவம்' : 'Flowering Stage';
    }
    if (lower.contains('shooting') || lower.contains('குலை')) {
      return isTamil ? 'குலை தள்ளும் பருவம்' : 'Shooting Stage';
    }
    if (lower.contains('grand growth') || lower.contains('வளர்ச்சி')) {
      return isTamil ? 'வளர்ச்சிப் பருவம்' : 'Grand Growth Stage';
    }
    if (lower.contains('rhizome') || lower.contains('கிழங்கு')) {
      return isTamil ? 'கிழங்கு உருவாகும் பருவம்' : 'Rhizome Development Stage';
    }
    if (lower.contains('peg') || lower.contains('விருது')) {
      return isTamil ? 'விருது இறங்கும் பருவம்' : 'Peg Formation Stage';
    }
    if (lower.contains('tilled') || lower.contains('seedbed') || lower.contains('உழவு') || lower.contains('விதைப்புக்கு')) {
      return isTamil ? 'விதைப்புக்கு தயார்' : 'Tilled / Seedbed Ready';
    }
    if (lower.contains('unplanted') || lower.contains('பயிர் செய்யப்படாதது')) {
      return isTamil ? 'பயிர் செய்யப்படாதது' : 'Unplanted';
    }
    return isTamil ? cleanTamil(stage) : cleanEnglish(stage);
  }

  // ---------------------------------------------------------------------------
  // Clean Zone Names
  // ---------------------------------------------------------------------------
  static String zoneName(String zoneIdOrName, {required bool isTamil}) {
    final lower = zoneIdOrName.toLowerCase();
    if (lower.contains('zone_1') || lower.contains('north') || lower.contains('வடக்கு')) {
      return isTamil ? 'வடக்கு வயல் (3.5 ஏக்கர் - டெல்டா நெல்)' : 'North Field (3.5 Acres - Delta Paddy)';
    }
    if (lower.contains('zone_2') || lower.contains('south') || lower.contains('தெற்கு')) {
      return isTamil ? 'தெற்கு வயல் (2.5 ஏக்கர் - தக்காளி)' : 'South Field (2.5 Acres - Tomato)';
    }
    if (lower.contains('zone_3') || lower.contains('east') || lower.contains('கிழக்கு')) {
      return isTamil ? 'கிழக்கு வயல் (2.5 ஏக்கர் - வாழை)' : 'East Field (2.5 Acres - Banana)';
    }
    if (lower.contains('zone_4') || lower.contains('west') || lower.contains('மேற்கு')) {
      return isTamil ? 'மேற்கு நிலம் (1.5 ஏக்கர் - தரிசு நிலம்)' : 'West Plot (1.5 Acres - Fallow)';
    }
    return isTamil ? cleanTamil(zoneIdOrName) : cleanEnglish(zoneIdOrName);
  }

  static String zoneShortName(String zoneIdOrName, {required bool isTamil}) {
    final lower = zoneIdOrName.toLowerCase();
    if (lower.contains('zone_1') || lower.contains('north') || lower.contains('வடக்கு')) {
      return isTamil ? 'வடக்கு வயல்' : 'North Field';
    }
    if (lower.contains('zone_2') || lower.contains('south') || lower.contains('தெற்கு')) {
      return isTamil ? 'தெற்கு வயல்' : 'South Field';
    }
    if (lower.contains('zone_3') || lower.contains('east') || lower.contains('கிழக்கு')) {
      return isTamil ? 'கிழக்கு வயல்' : 'East Field';
    }
    if (lower.contains('zone_4') || lower.contains('west') || lower.contains('மேற்கு')) {
      return isTamil ? 'மேற்கு நிலம்' : 'West Plot';
    }
    return isTamil ? cleanTamil(zoneIdOrName) : cleanEnglish(zoneIdOrName);
  }

  // ---------------------------------------------------------------------------
  // Soil Textures
  // ---------------------------------------------------------------------------
  static String soilTexture(String texture, {required bool isTamil}) {
    final lower = texture.toLowerCase();
    if (lower.contains('alluvial') && lower.contains('clay')) {
      return isTamil ? 'காவிரி வண்டல் களிமண்' : 'Cauvery Alluvial Clay Loam';
    }
    if (lower.contains('red') && lower.contains('sandy')) {
      return isTamil ? 'செம்மண் நிலம்' : 'Red Sandy Loam';
    }
    if (lower.contains('riverbank') || (lower.contains('alluvial') && lower.contains('loam'))) {
      return isTamil ? 'ஆற்று வண்டல் மண்' : 'Riverbank Alluvial Loam';
    }
    if (lower.contains('sandy loam')) {
      return isTamil ? 'மணல் கலந்த வண்டல் மண்' : 'Sandy Loam';
    }
    if (lower.contains('clay loam')) {
      return isTamil ? 'களிமண் நிலம்' : 'Clay Loam';
    }
    if (lower.contains('black')) {
      return isTamil ? 'கரிசல் மண்' : 'Black Cotton Soil';
    }
    if (lower.contains('loam') || lower.contains('loamy')) {
      return isTamil ? 'வண்டல் மண்' : 'Loamy Soil';
    }
    return isTamil ? cleanTamil(texture) : cleanEnglish(texture);
  }

  // ---------------------------------------------------------------------------
  // Zone Status & Headlines
  // ---------------------------------------------------------------------------
  static String zoneStatus(dynamic status, {required bool isTamil}) {
    final str = status is Enum ? status.name : (status?.toString() ?? '');
    final upper = str.toUpperCase();
    if (upper.contains('CRITICAL')) return isTamil ? 'அவசர கவனம்' : 'CRITICAL';
    if (upper.contains('WARNING')) return isTamil ? 'எச்சரிக்கை' : 'WARNING';
    return isTamil ? 'நலம்' : 'NORMAL';
  }

  static String zoneStatusHeadline(String headline, {required bool isTamil}) {
    final lower = headline.toLowerCase();
    if (lower.contains('water stress') || lower.contains('நீர்ப்பற்றாக்குறை')) {
      return isTamil ? 'தெற்கு வயல் — நீர்ப்பற்றாக்குறை எச்சரிக்கை' : 'South Field — Water Stress Warning';
    }
    if (lower.contains('fungal') || lower.contains('spore') || lower.contains('பூஞ்சான்')) {
      return isTamil ? 'வடக்கு வயல் — பூஞ்சான் நோய் அபாயம்' : 'North Field — Foliar Fungal Risk';
    }
    if (lower.contains('waterlogging') || lower.contains('saturation') || lower.contains('நீர் தேக்கம்')) {
      return isTamil ? 'கிழக்கு வயல் — கடும் நீர் தேக்கம்' : 'East Field — Waterlogging Saturation';
    }
    if (lower.contains('fallow') || lower.contains('seedbed') || lower.contains('தரிசு')) {
      return isTamil ? 'மேற்கு நிலம் — விதைப்புக்கு தயார்' : 'West Plot — Ready for Sowing';
    }
    if (lower.contains('north') || lower.contains('வடக்கு')) {
      return isTamil ? 'வடக்கு வயல் — நலம்' : 'North Field — Normal Condition';
    }
    if (lower.contains('south') || lower.contains('தெற்கு')) {
      return isTamil ? 'தெற்கு வயல் — நலம்' : 'South Field — Normal Condition';
    }
    if (lower.contains('east') || lower.contains('கிழக்கு')) {
      return isTamil ? 'கிழக்கு வயல் — நலம்' : 'East Field — Normal Condition';
    }
    if (lower.contains('west') || lower.contains('மேற்கு')) {
      return isTamil ? 'மேற்கு நிலம் — நலம்' : 'West Plot — Normal Condition';
    }
    if (isTamil) {
      final res = cleanTamil(headline);
      if (!RegExp(r'[\u0B80-\u0BFF]').hasMatch(res)) {
        return 'பண்ணை பகுதி — நலம்';
      }
      return res;
    }
    return cleanEnglish(headline);
  }

  static String zoneStatusReason(String reason, {required bool isTamil}) {
    final lower = reason.toLowerCase();
    if (lower.contains('24.8%') || lower.contains('37.4°c') || lower.contains('declining sharply')) {
      return isTamil
          ? 'சுற்றுப்புற வெப்பநிலை 37.4°C ஆக உள்ள நிலையில் மண் ஈரப்பதம் 24.8% ஆகக் குறைந்துள்ளது.'
          : 'Soil moisture dropped to 24.8% while ambient temperature is 37.4°C.';
    }
    if (lower.contains('leaf wetness') || lower.contains('spore') || lower.contains('germination')) {
      return isTamil
          ? 'இலைகளில் தொடர் ஈரம் மற்றும் அதிக காற்றின் ஈரப்பதம் பூஞ்சான் வித்துக்கள் முளைக்க சாதகமாக உள்ளது.'
          : 'Extended leaf wetness combined with high humidity creates favorable spore germination conditions.';
    }
    if (lower.contains('saturated') || lower.contains('suffocation') || lower.contains('continuous precipitation')) {
      return isTamil
          ? 'தொடர் கனமழையால் மண் துளைகள் நிரம்பி வேர்களுக்கு காற்று புகாத சூழல் ஏற்பட்டுள்ளது.'
          : 'Excessive continuous precipitation has saturated soil pore spaces, risking root suffocation.';
    }
    if (lower.contains('tilled') || lower.contains('seedbed') || lower.contains('fresh sowing') || lower.contains('awaiting sowing')) {
      return isTamil
          ? 'அறுவடைக்கு பின் நிலம் உழப்பட்டு விதைப்புக்கு தயாராக உள்ளது; மண் வேதியியல் சமநிலையில் உள்ளது.'
          : 'Post-harvest fallow seedbed prepared; optimal moisture and balanced soil chemistry.';
    }
    if (lower.contains('balanced') || lower.contains('cauvery') || lower.contains('photosynthetic')) {
      return isTamil
          ? 'வேர் மண்டல ஈரப்பதம் சீராக உள்ளது; பயிர் வளர்ச்சி ஆரோக்கியமாக உள்ளது.'
          : 'Root-zone hydration is balanced; normal vegetative vigor.';
    }
    if (isTamil) {
      final res = cleanTamil(reason);
      if (!RegExp(r'[\u0B80-\u0BFF]').hasMatch(res)) {
        return 'மண் தரம் மற்றும் பயிர் வளர்ச்சி சூழல் ஆரோக்கியமாக உள்ளது.';
      }
      return res;
    }
    return cleanEnglish(reason);
  }

  static String zoneRecommendedAction(String action, {required bool isTamil}) {
    final lower = action.toLowerCase();
    if (lower.contains('drip irrigation') || lower.contains('3 hours') || lower.contains('4 hours')) {
      return isTamil
          ? 'அடுத்த 3 மணி நேரத்திற்குள் இப்பகுதிக்கு சொட்டு நீர் பாசனம் வழங்கவும்.'
          : 'Prioritize root-zone drip irrigation for this sector within 3 hours.';
    }
    if (lower.contains('sprinkler') || lower.contains('lesion') || lower.contains('cease')) {
      return isTamil
          ? 'தெளிப்பு நீர் பாசனத்தை உடனே நிறுத்தவும்; இலைகளில் புள்ளி உள்ளதா என ஆய்வு செய்யவும்.'
          : 'Cease any overhead sprinkler watering; inspect lower leaves for lesion spots.';
    }
    if (lower.contains('drainage') || lower.contains('furrows') || lower.contains('standing surface water')) {
      return isTamil
          ? 'தேங்கியுள்ள நீரை உடனடியாக வெளியேற்ற வடிகால் வாய்க்கால்களை திறக்கவும்.'
          : 'Open drainage furrows immediately to clear standing surface water.';
    }
    if (lower.contains('potassium') || lower.contains('fertigation') || lower.contains('சாம்பல் சத்து') || lower.contains('உரமிடுதல்')) {
      return isTamil
          ? 'அடுத்த கட்ட சாம்பல் சத்து (பொட்டாசியம்) உரமிடுதல் 7 நாட்களில் திட்டமிடப்பட்டுள்ளது.'
          : 'Next split Potassium fertigation scheduled in 7 days.';
    }
    if (lower.contains('quotation') || lower.contains('seed') || lower.contains('variety') || lower.contains('certified')) {
      return isTamil
          ? 'விதைப்புக்கு நிலத்தை தயார் செய்து சான்றளிக்கப்பட்ட விதைகளை தேர்வு செய்யவும்.'
          : 'Proceed with seedbed preparation and certified seed procurement.';
    }
    if (lower.contains('morning') || lower.contains('micro-irrigation') || lower.contains('scouting')) {
      return isTamil
          ? 'திட்டமிட்டபடி காலை நேர நுண்ணீர் பாசனத்தை தொடரவும், வழக்கமான கண்காணிப்பை மேற்கொள்ளவும்.'
          : 'Maintain scheduled morning micro-irrigation cycle and regular visual scouting.';
    }
    if (isTamil) {
      final res = cleanTamil(action);
      if (!RegExp(r'[\u0B80-\u0BFF]').hasMatch(res)) {
        return 'திட்டமிட்டபடி காலை நேர நுண்ணீர் பாசனத்தை தொடரவும், வழக்கமான கண்காணிப்பை மேற்கொள்ளவும்.';
      }
      return res;
    }
    return cleanEnglish(action);
  }

  // ---------------------------------------------------------------------------
  // Demo Scenario Translations
  // ---------------------------------------------------------------------------
  static String scenarioTitle(int scenarioIndex, {required bool isTamil}) {
    switch (scenarioIndex) {
      case 0:
        return isTamil ? 'சூழல் 1: ஆரோக்கியமான வயல்' : 'Scenario 1: Healthy Field';
      case 1:
        return isTamil ? 'சூழல் 2: நீர்ப்பற்றாக்குறை' : 'Scenario 2: Water Stress';
      case 2:
        return isTamil ? 'சூழல் 3: நோய் பரவல் அபாயம்' : 'Scenario 3: Disease Risk';
      case 3:
      default:
        return isTamil ? 'சூழல் 4: கனமழை / நீர் தேக்கம்' : 'Scenario 4: Heavy Rain / Waterlogging';
    }
  }

  static String scenarioDescription(int scenarioIndex, {required bool isTamil}) {
    switch (scenarioIndex) {
      case 0:
        return isTamil
            ? 'வேர் மண்டல ஈரப்பதம் சமநிலை, சீரான தட்பவெப்பம், பூச்சி நோய் தாக்கம் இல்லை.'
            : 'Balanced root-zone moisture, normal microclimate, zero biotic pressure.';
      case 1:
        return isTamil
            ? 'ஈரப்பதம் 25%, வெப்பநிலை 37°C, காற்றின் ஈரப்பதம் 45%, மழை 0 மி.மீ.'
            : 'Moisture 25%, Temp 37°C, Humidity 45%, Rainfall 0 mm.';
      case 2:
        return isTamil
            ? 'அதிக ஈரப்பதம் >82%, இலைகளில் ஈரம், மேகமூட்டம், பூஞ்சான் தொற்றுக்கு சாதகமான சூழல்.'
            : 'High humidity >82%, leaf wetness, cloudy canopy, favorable fungal spore conditions.';
      case 3:
      default:
        return isTamil
            ? 'மழை அளவு >55 மி.மீ, அதிக நீர் தேக்கம், வேர்களுக்கு ஆக்ஸிஜன் பற்றாக்குறை அபாயம்.'
            : 'Rainfall >55 mm, saturated soil, oxygen deficit risk in root zone.';
    }
  }

  static String scenarioRiskLabel(int scenarioIndex, {required bool isTamil}) {
    switch (scenarioIndex) {
      case 0:
        return isTamil ? 'சிறந்த பயிர் சூழல் (குறைந்த இடர்)' : 'Optimal Field Condition (Low Risk)';
      case 1:
        return isTamil ? 'அதிக நீர்ப்பற்றாக்குறை அபாயம்' : 'High Water Stress Risk';
      case 2:
        return isTamil ? 'இலை நோய் பரவும் அபாயம்' : 'Elevated Foliar Disease Risk';
      case 3:
      default:
        return isTamil ? 'கடும் நீர் தேக்கம் / வேர் அழுகல் அபாயம்' : 'Severe Waterlogging / Root Hypoxia Risk';
    }
  }

  static String scenarioRiskReason(int scenarioIndex, {required bool isTamil}) {
    switch (scenarioIndex) {
      case 0:
        return isTamil
            ? 'மண் வேதியியல் சென்சார்கள் மற்றும் காலநிலை நிலையங்கள் நிலையான சமநிலையைக் காட்டுகின்றன.'
            : 'All soil chemical sensors and microclimate stations indicate stable agronomic equilibrium.';
      case 1:
        return isTamil
            ? 'வெப்பநிலை அதிகமாக உள்ள நிலையில் மண் ஈரப்பதம் வேகமாக குறைந்து வருகிறது.'
            : 'Soil moisture is declining sharply while ambient temperatures remain elevated.';
      case 2:
        return isTamil
            ? 'இலைகளில் தொடர் ஈரம் மற்றும் அதிக காற்றின் ஈரப்பதம் பூஞ்சான் வித்துக்கள் முளைக்க சாதகமாக உள்ளது.'
            : 'Extended leaf wetness combined with high relative humidity creates favorable spore germination conditions.';
      case 3:
      default:
        return isTamil
            ? 'தொடர் கனமழையால் மண் துளைகள் நிரம்பி வேர்களுக்கு காற்று புகாத சூழல் ஏற்பட்டுள்ளது.'
            : 'Excessive continuous precipitation has saturated soil pore spaces, risking root suffocation.';
    }
  }

  static String scenarioRecommendedAction(int scenarioIndex, {required bool isTamil}) {
    switch (scenarioIndex) {
      case 0:
        return isTamil
            ? 'வழக்கமான காலை நேர பாசனத்தை தொடரவும், தொடர்ந்து வயலை கண்காணிக்கவும்.'
            : 'Maintain standard morning irrigation schedule and regular visual scouting.';
      case 1:
        return isTamil
            ? 'அடுத்த 4 மணி நேரத்திற்குள் 2-ஆம் பகுதிக்கு சொட்டு நீர் பாசனம் வழங்கவும்.'
            : 'Prioritize root-zone drip irrigation for Zone 2 within the next 4 hours.';
      case 2:
        return isTamil
            ? 'தெளிப்பு நீர் பாசனத்தை உடனே நிறுத்தவும்; இலைகளில் புள்ளி உள்ளதா என ஆய்வு செய்யவும்.'
            : 'Cease any overhead sprinkler watering; inspect lower leaves in Zone 1 for lesion spots.';
      case 3:
      default:
        return isTamil
            ? 'தேங்கியுள்ள நீரை உடனடியாக வெளியேற்ற 3-ஆம் பகுதியில் வடிகால் வாய்க்கால்களை திறக்கவும்.'
            : 'Open drainage furrows immediately in Zone 3 to clear standing surface water.';
    }
  }

  static String scenarioWeatherForecast(int scenarioIndex, {required bool isTamil}) {
    switch (scenarioIndex) {
      case 0:
        return isTamil
            ? 'தெளிவான வானம் மற்றும் மிதமான காற்று; எச்சரிக்கைகள் ஏதுமில்லை.'
            : 'Clear skies with mild breeze; no environmental alerts.';
      case 1:
        return isTamil
            ? 'பகலில் தீவிர வெப்பம் மற்றும் பிற்பகலில் குறைந்த ஈரப்பதம்.'
            : 'Intense daytime heat with low afternoon humidity.';
      case 2:
        return isTamil
            ? 'மேகமூட்டம், தொடர் அதிக ஈரப்பதம் மற்றும் காற்று வீசாத சூழல்.'
            : 'Overcast with persistent high humidity and stagnant air.';
      case 3:
      default:
        return isTamil
            ? 'அடுத்த 24 மணி நேரத்திற்கு இந்திய வானிலை மையம் கனமழை எச்சரிக்கை விடுத்துள்ளது.'
            : 'Heavy rainfall alert issued by IMD for the next 24 hours.';
    }
  }

  static String scenarioPrimaryZoneConcern(int scenarioIndex, {required bool isTamil}) {
    switch (scenarioIndex) {
      case 0:
        return isTamil ? 'அனைத்து பகுதிகளும் நலம்' : 'All zones nominal';
      case 1:
        return isTamil ? 'பகுதி 2 — கடுமையான ஈரப்பதம் குறைவு' : 'Zone 2 — Critical Moisture Depletion';
      case 2:
        return isTamil ? 'பகுதி 1 — பூஞ்சான் நோய் தாக்கம்' : 'Zone 1 — Microclimatic Fungal Incubation';
      case 3:
      default:
        return isTamil ? 'பகுதி 3 — தரைமட்ட நீர் தேக்கம்' : 'Zone 3 — Surface Runoff Ponding';
    }
  }

  // ---------------------------------------------------------------------------
  // String Sanitation Utilities
  // ---------------------------------------------------------------------------
  /// Returns 100% pure English: removes any Tamil characters and bracketed Tamil text.
  static String cleanEnglish(String text) {
    if (text.isEmpty) return text;
    // Strip bracketed Tamil content e.g. "Tillering Stage (தூர்கட்டும் பருவம்)" -> "Tillering Stage"
    String cleaned = text.replaceAll(RegExp(r'\s*\([\u0B80-\u0BFF\s\-/0-9]+\)'), '');
    // Clean dual names with slashes e.g. "Tomato / Thakkali" -> "Tomato"
    if (cleaned.contains(' / ')) {
      final parts = cleaned.split(' / ');
      if (parts.length == 2 && RegExp(r'[\u0B80-\u0BFF]').hasMatch(parts[1])) {
        cleaned = parts[0];
      }
    }
    // Remove any remaining Tamil characters
    cleaned = cleaned.replaceAll(RegExp(r'[\u0B80-\u0BFF]'), '');
    return cleaned.trim();
  }

  /// Returns 100% pure Tamil: extracts or maps to pure Tamil.
  static String cleanTamil(String text) {
    if (text.isEmpty) return text;
    // Check if bracketed Tamil text exists e.g. "Tillering Stage (தூர்கட்டும் பருவம்)" -> "தூர்கட்டும் பருவம்"
    final match = RegExp(r'\(([\u0B80-\u0BFF\s\-/0-9]+)\)').firstMatch(text);
    if (match != null && match.group(1) != null && match.group(1)!.isNotEmpty) {
      return match.group(1)!.trim();
    }
    // Check if dual name exists with slash e.g. "Tomato / Thakkali"
    final lower = text.toLowerCase();
    if (lower.contains('tomato') || lower.contains('thakkali')) return 'தக்காளி';
    if (lower.contains('paddy') || lower.contains('rice')) return 'நெல்';
    if (lower.contains('banana') || lower.contains('vazhai')) return 'வாழை';
    if (lower.contains('sugarcane') || lower.contains('karumbu')) return 'கரும்பு';
    if (lower.contains('turmeric') || lower.contains('manjal')) return 'மஞ்சள்';
    if (lower.contains('groundnut') || lower.contains('kadalai')) return 'நிலக்கடலை';
    if (lower.contains('fallow')) return 'தரிசு நிலம் (விதைப்புக்கு தயார்)';
    return text.trim();
  }
}
