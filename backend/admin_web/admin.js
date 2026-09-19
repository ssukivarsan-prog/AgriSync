/**
 * AgriVyn Village Agronomy Command Portal — Frontend Controller (admin.js)
 * Implements real-time telemetry rendering, feature phone filtering,
 * bilingual SMS dispatching, and interactive AI Voice Agent with browser Speech Synthesis.
 */

// Global Application State
const state = {
  villages: [],
  selectedVillageId: 1,
  farmers: [],
  filteredFarmers: [],
  currentFilter: 'all', // 'all', 'feature_phone', 'smartphone', 'critical'
  searchQuery: '',
  cropFilter: 'ALL',
  viewMode: 'grid', // 'grid' | 'table'
  activeFarmer: null,
  activeFarmerDetails: null,
  
  // Voice Call State
  voiceCall: {
    isActive: false,
    timerInterval: null,
    durationSeconds: 0,
    isAudioMuted: false,
    dialogue: [],
    extractedQueries: [],
    extractedActions: []
  }
};

// DOM Elements Cache
const DOM = {};

document.addEventListener('DOMContentLoaded', () => {
  initDOMElements();
  initEventListeners();
  loadVillages();
  loadFarmers();
  checkTelephonyConfig();
});

function initDOMElements() {
  DOM.villageSelect = document.getElementById('villageSelect');
  DOM.btnRefresh = document.getElementById('btnRefresh');

  // KPIs
  DOM.kpiTotalFarmers = document.getElementById('kpiTotalFarmers');
  DOM.kpiTotalAcres = document.getElementById('kpiTotalAcres');
  DOM.kpiFeaturePhone = document.getElementById('kpiFeaturePhone');
  DOM.kpiFeaturePct = document.getElementById('kpiFeaturePct');
  DOM.kpiSmartphone = document.getElementById('kpiSmartphone');
  DOM.kpiCriticalFarms = document.getElementById('kpiCriticalFarms');
  DOM.kpiActionItems = document.getElementById('kpiActionItems');

  // Filters & Search
  DOM.deviceFilterTabs = document.getElementById('deviceFilterTabs');
  DOM.countAll = document.getElementById('countAll');
  DOM.countFeature = document.getElementById('countFeature');
  DOM.countSmart = document.getElementById('countSmart');
  DOM.countCritical = document.getElementById('countCritical');
  DOM.searchInput = document.getElementById('searchInput');
  DOM.btnClearSearch = document.getElementById('btnClearSearch');
  DOM.cropFilterSelect = document.getElementById('cropFilterSelect');
  DOM.featurePhoneNotice = document.getElementById('featurePhoneNotice');
  DOM.btnDismissNotice = document.getElementById('btnDismissNotice');
  DOM.showingCountBadge = document.getElementById('showingCountBadge');

  // Views
  DOM.btnViewGrid = document.getElementById('btnViewGrid');
  DOM.btnViewTable = document.getElementById('btnViewTable');
  DOM.farmersGrid = document.getElementById('farmersGrid');
  DOM.farmersTableWrap = document.getElementById('farmersTableWrap');
  DOM.farmersTableBody = document.getElementById('farmersTableBody');

  // Farm Deep Dive Modal
  DOM.farmModal = document.getElementById('farmModal');
  DOM.btnCloseFarmModal = document.getElementById('btnCloseFarmModal');
  DOM.modalDeviceBadge = document.getElementById('modalDeviceBadge');
  DOM.modalFarmerTitle = document.getElementById('modalFarmerTitle');
  DOM.modalFarmSubtitle = document.getElementById('modalFarmSubtitle');
  DOM.btnModalOpenSMS = document.getElementById('btnModalOpenSMS');
  DOM.btnModalOpenVoiceCall = document.getElementById('btnModalOpenVoiceCall');
  DOM.gaugeMoisture = document.getElementById('gaugeMoisture');
  DOM.barMoisture = document.getElementById('barMoisture');
  DOM.statusMoisture = document.getElementById('statusMoisture');
  DOM.gaugePhTemp = document.getElementById('gaugePhTemp');
  DOM.gaugeCropStage = document.getElementById('gaugeCropStage');
  DOM.gaugeStageSub = document.getElementById('gaugeStageSub');
  DOM.npkN = document.getElementById('npkN');
  DOM.npkP = document.getElementById('npkP');
  DOM.npkK = document.getElementById('npkK');
  DOM.modalTinyMLDecision = document.getElementById('modalTinyMLDecision');
  DOM.modalRiskTitle = document.getElementById('modalRiskTitle');
  DOM.modalRiskBadge = document.getElementById('modalRiskBadge');
  DOM.modalDiseaseName = document.getElementById('modalDiseaseName');
  DOM.modalActionEn = document.getElementById('modalActionEn');
  DOM.modalActionTa = document.getElementById('modalActionTa');
  DOM.tabHistCallNotes = document.getElementById('tabHistCallNotes');
  DOM.tabHistSMS = document.getElementById('tabHistSMS');
  DOM.tabHistCallTranscripts = document.getElementById('tabHistCallTranscripts');
  DOM.countCallNotes = document.getElementById('countCallNotes');
  DOM.countSMSLogs = document.getElementById('countSMSLogs');
  DOM.countCallTranscripts = document.getElementById('countCallTranscripts');
  DOM.historyContentCallNotes = document.getElementById('historyContentCallNotes');
  DOM.historyContentSMS = document.getElementById('historyContentSMS');
  DOM.historyContentCallTranscripts = document.getElementById('historyContentCallTranscripts');
  DOM.callNotesList = document.getElementById('callNotesList');
  DOM.smsLogsList = document.getElementById('smsLogsList');
  DOM.callTranscriptsList = document.getElementById('callTranscriptsList');
  DOM.callTranscriptLiveBadge = document.getElementById('callTranscriptLiveBadge');
  DOM.btnRefreshCallTranscripts = document.getElementById('btnRefreshCallTranscripts');

  // SMS Modal
  DOM.smsModal = document.getElementById('smsModal');
  DOM.btnCloseSMSModal = document.getElementById('btnCloseSMSModal');
  DOM.btnCancelSMS = document.getElementById('btnCancelSMS');
  DOM.smsModalRecipient = document.getElementById('smsModalRecipient');
  DOM.btnSmsLangTa = document.getElementById('btnSmsLangTa');
  DOM.btnSmsLangEn = document.getElementById('btnSmsLangEn');
  DOM.btnSmsLangBoth = document.getElementById('btnSmsLangBoth');
  DOM.smsMessageText = document.getElementById('smsMessageText');
  DOM.smsCharCount = document.getElementById('smsCharCount');
  DOM.btnDispatchSMS = document.getElementById('btnDispatchSMS');
  DOM.smsDeliveryResult = document.getElementById('smsDeliveryResult');
  DOM.receiptRef = document.getElementById('receiptRef');
  DOM.receiptTime = document.getElementById('receiptTime');

  // Voice Call Modal
  DOM.voiceModal = document.getElementById('voiceModal');
  DOM.btnCloseVoiceModal = document.getElementById('btnCloseVoiceModal');
  DOM.voiceModalFarmerName = document.getElementById('voiceModalFarmerName');
  DOM.voiceModalPhone = document.getElementById('voiceModalPhone');
  DOM.phoneFarmerName = document.getElementById('phoneFarmerName');
  DOM.phoneFarmerCrop = document.getElementById('phoneFarmerCrop');
  DOM.callStatusText = document.getElementById('callStatusText');
  DOM.audioWaveform = document.getElementById('audioWaveform');
  DOM.speakerStatePill = document.getElementById('speakerStatePill');
  DOM.speakerStateText = document.getElementById('speakerStateText');
  DOM.liveDialogueBox = document.getElementById('liveDialogueBox');
  DOM.btnToggleSpeechAudio = document.getElementById('btnToggleSpeechAudio');
  DOM.btnEndVoiceCall = document.getElementById('btnEndVoiceCall');
  DOM.queryChipsContainer = document.getElementById('queryChipsContainer');
  DOM.customQueryInput = document.getElementById('customQueryInput');
  DOM.btnSendFarmerQuery = document.getElementById('btnSendFarmerQuery');
  DOM.extractedQueriesList = document.getElementById('extractedQueriesList');
  DOM.extractedActionsList = document.getElementById('extractedActionsList');
  DOM.btnSaveCallNotesToDB = document.getElementById('btnSaveCallNotesToDB');

  // Register Offline Farmer Modal
  DOM.btnOpenRegisterModal = document.getElementById('btnOpenRegisterModal');
  DOM.btnQuickCallNumber = document.getElementById('btnQuickCallNumber');
  DOM.registerFarmerModal = document.getElementById('registerFarmerModal');
  DOM.btnCloseRegisterModal = document.getElementById('btnCloseRegisterModal');
  DOM.btnCancelRegister = document.getElementById('btnCancelRegister');
  DOM.btnSubmitRegisterFarmer = document.getElementById('btnSubmitRegisterFarmer');
  DOM.regPhone = document.getElementById('regPhone');
  DOM.regName = document.getElementById('regName');
  DOM.regNameTa = document.getElementById('regNameTa');
  DOM.regHamlet = document.getElementById('regHamlet');
  DOM.regCrop = document.getElementById('regCrop');
  DOM.regAcres = document.getElementById('regAcres');
  DOM.regMoisture = document.getElementById('regMoisture');
  DOM.regDevice = document.getElementById('regDevice');

  // Direct Number Dial & Speech Mic in Voice Call
  DOM.voiceModalPhoneInput = document.getElementById('voiceModalPhoneInput');
  DOM.btnConnectDirectNumber = document.getElementById('btnConnectDirectNumber');
  DOM.linkNativePhoneDial = document.getElementById('linkNativePhoneDial');
  DOM.btnToggleMic = document.getElementById('btnToggleMic');
  DOM.micIcon = document.getElementById('micIcon');
  DOM.micStatusText = document.getElementById('micStatusText');
  DOM.linkNativeSMSApp = document.getElementById('linkNativeSMSApp');

  // Real Outbound Telephony Call & Twilio Settings
  DOM.telephonyConfigBadge = document.getElementById('telephonyConfigBadge');
  DOM.btnOpenTwilioSettings = document.getElementById('btnOpenTwilioSettings');
  DOM.btnTriggerRealPhoneCall = document.getElementById('btnTriggerRealPhoneCall');
  DOM.realCallLanguageSelect = document.getElementById('realCallLanguageSelect');
  DOM.realCallTopicSelect = document.getElementById('realCallTopicSelect');
  DOM.realCallStatusBanner = document.getElementById('realCallStatusBanner');
  DOM.realCallStatusText = document.getElementById('realCallStatusText');
  DOM.twilioSettingsModal = document.getElementById('twilioSettingsModal');
  DOM.btnCloseTwilioModal = document.getElementById('btnCloseTwilioModal');
  DOM.btnCancelTwilio = document.getElementById('btnCancelTwilio');
  DOM.btnSaveTwilioConfig = document.getElementById('btnSaveTwilioConfig');
  DOM.cfgTwilioSid = document.getElementById('cfgTwilioSid');
  DOM.cfgTwilioToken = document.getElementById('cfgTwilioToken');
  DOM.cfgTwilioPhone = document.getElementById('cfgTwilioPhone');
  DOM.cfgPublicUrl = document.getElementById('cfgPublicUrl');

  // Toast
  DOM.toastNotification = document.getElementById('toastNotification');
  DOM.toastMessage = document.getElementById('toastMessage');
}

function initEventListeners() {
  DOM.btnRefresh.addEventListener('click', () => {
    showToast('Syncing village IoT telemetry...');
    loadVillages();
    loadFarmers();
  });

  DOM.villageSelect.addEventListener('change', (e) => {
    state.selectedVillageId = parseInt(e.target.value, 10);
    loadFarmers();
  });

  // Filter Tabs
  DOM.deviceFilterTabs.addEventListener('click', (e) => {
    const tab = e.target.closest('.filter-tab');
    if (!tab) return;
    DOM.deviceFilterTabs.querySelectorAll('.filter-tab').forEach(t => t.classList.remove('active'));
    tab.classList.add('active');
    state.currentFilter = tab.dataset.filter;

    // Toggle banner for feature phones
    if (state.currentFilter === 'feature_phone') {
      DOM.featurePhoneNotice.classList.remove('hidden');
    } else {
      DOM.featurePhoneNotice.classList.add('hidden');
    }

    applyFilters();
  });

  DOM.btnDismissNotice.addEventListener('click', () => {
    DOM.featurePhoneNotice.classList.add('hidden');
  });

  // Search
  DOM.searchInput.addEventListener('input', (e) => {
    state.searchQuery = e.target.value.trim();
    DOM.btnClearSearch.classList.toggle('hidden', state.searchQuery.length === 0);
    applyFilters();
  });

  DOM.btnClearSearch.addEventListener('click', () => {
    state.searchQuery = '';
    DOM.searchInput.value = '';
    DOM.btnClearSearch.classList.add('hidden');
    applyFilters();
  });

  // Crop Filter
  DOM.cropFilterSelect.addEventListener('change', (e) => {
    state.cropFilter = e.target.value;
    applyFilters();
  });

  // View toggles
  DOM.btnViewGrid.addEventListener('click', () => setViewMode('grid'));
  DOM.btnViewTable.addEventListener('click', () => setViewMode('table'));

  // Modal Closers
  DOM.btnCloseFarmModal.addEventListener('click', closeFarmModal);
  DOM.btnCloseSMSModal.addEventListener('click', closeSMSModal);
  DOM.btnCancelSMS.addEventListener('click', closeSMSModal);
  DOM.btnCloseVoiceModal.addEventListener('click', closeVoiceModal);

  // Deep dive open SMS / Call buttons
  DOM.btnModalOpenSMS.addEventListener('click', () => {
    if (state.activeFarmer) {
      closeFarmModal();
      openSMSModal(state.activeFarmer);
    }
  });

  DOM.btnModalOpenVoiceCall.addEventListener('click', () => {
    if (state.activeFarmer) {
      closeFarmModal();
      openVoiceModal(state.activeFarmer);
    }
  });

  // History Tab switcher in Deep Dive
  DOM.tabHistCallNotes.addEventListener('click', () => {
    DOM.tabHistCallNotes.classList.add('active');
    DOM.tabHistSMS.classList.remove('active');
    if (DOM.tabHistCallTranscripts) DOM.tabHistCallTranscripts.classList.remove('active');
    DOM.historyContentCallNotes.classList.remove('hidden');
    DOM.historyContentSMS.classList.add('hidden');
    if (DOM.historyContentCallTranscripts) DOM.historyContentCallTranscripts.classList.add('hidden');
  });

  DOM.tabHistSMS.addEventListener('click', () => {
    DOM.tabHistSMS.classList.add('active');
    DOM.tabHistCallNotes.classList.remove('active');
    if (DOM.tabHistCallTranscripts) DOM.tabHistCallTranscripts.classList.remove('active');
    DOM.historyContentSMS.classList.remove('hidden');
    DOM.historyContentCallNotes.classList.add('hidden');
    if (DOM.historyContentCallTranscripts) DOM.historyContentCallTranscripts.classList.add('hidden');
  });

  if (DOM.tabHistCallTranscripts) {
    DOM.tabHistCallTranscripts.addEventListener('click', () => {
      DOM.tabHistCallTranscripts.classList.add('active');
      DOM.tabHistCallNotes.classList.remove('active');
      DOM.tabHistSMS.classList.remove('active');
      DOM.historyContentCallTranscripts.classList.remove('hidden');
      DOM.historyContentCallNotes.classList.add('hidden');
      DOM.historyContentSMS.classList.add('hidden');
      fetchAndRenderCallTranscripts();
    });
  }

  if (DOM.btnRefreshCallTranscripts) {
    DOM.btnRefreshCallTranscripts.addEventListener('click', fetchAndRenderCallTranscripts);
  }

  // Auto-refresh call transcripts every 10s when the tab is visible
  setInterval(() => {
    if (DOM.historyContentCallTranscripts && !DOM.historyContentCallTranscripts.classList.contains('hidden')) {
      fetchAndRenderCallTranscripts();
    }
  }, 10000);

  // SMS Modal Controls
  DOM.btnSmsLangTa.addEventListener('click', () => setSmsLanguage('ta'));
  DOM.btnSmsLangEn.addEventListener('click', () => setSmsLanguage('en'));
  DOM.btnSmsLangBoth.addEventListener('click', () => setSmsLanguage('both'));
  DOM.smsMessageText.addEventListener('input', updateSmsCharCount);
  DOM.btnDispatchSMS.addEventListener('click', dispatchSMS);

  // Voice Call Modal Controls
  DOM.btnToggleSpeechAudio.addEventListener('click', toggleAudioMute);
  DOM.btnEndVoiceCall.addEventListener('click', endVoiceCallAndSaveNotes);
  DOM.btnSaveCallNotesToDB.addEventListener('click', saveCallNotesToBackend);

  // Voice Call Query Chips
  DOM.queryChipsContainer.addEventListener('click', (e) => {
    const chip = e.target.closest('.query-chip');
    if (!chip) return;
    const queryText = chip.dataset.query;
    processFarmerVoiceQuery(queryText);
  });

  // Custom Query
  DOM.btnSendFarmerQuery.addEventListener('click', () => {
    const queryText = DOM.customQueryInput.value.trim();
    if (queryText) {
      processFarmerVoiceQuery(queryText);
      DOM.customQueryInput.value = '';
    }
  });

  DOM.customQueryInput.addEventListener('keypress', (e) => {
    if (e.key === 'Enter') {
      DOM.btnSendFarmerQuery.click();
    }
  });

  // Offline Farmer Registration Modal Listeners
  if (DOM.btnOpenRegisterModal) {
    DOM.btnOpenRegisterModal.addEventListener('click', openRegisterFarmerModal);
  }
  if (DOM.btnCloseRegisterModal) {
    DOM.btnCloseRegisterModal.addEventListener('click', closeRegisterFarmerModal);
  }
  if (DOM.btnCancelRegister) {
    DOM.btnCancelRegister.addEventListener('click', closeRegisterFarmerModal);
  }
  if (DOM.btnSubmitRegisterFarmer) {
    DOM.btnSubmitRegisterFarmer.addEventListener('click', submitRegisterFarmer);
  }

  // Quick Direct Call Demo from Header
  if (DOM.btnQuickCallNumber) {
    DOM.btnQuickCallNumber.addEventListener('click', () => {
      openVoiceModal({
        id: null,
        name: "Direct Number Dial Demo",
        name_tamil: "நேரடி அழைப்பு டெமோ",
        phone_number: "+91 98421 78210",
        primary_crop: "Paddy (CR1009 / Samba)",
        hamlet: "Melattur Village",
        soil_moisture_pct: 22.5,
        risk_level: "CRITICAL",
        recommended_action: "Schedule 1.5-hour furrow wetting immediately."
      });
    });
  }

  // Direct Number Dial inside Voice Modal
  if (DOM.btnConnectDirectNumber) {
    DOM.btnConnectDirectNumber.addEventListener('click', () => {
      const num = DOM.voiceModalPhoneInput.value.trim();
      if (num) connectCallToPhoneNumber(num);
    });
  }
  if (DOM.voiceModalPhoneInput) {
    DOM.voiceModalPhoneInput.addEventListener('input', (e) => {
      const num = e.target.value.trim();
      if (DOM.linkNativePhoneDial) DOM.linkNativePhoneDial.href = `tel:${num.replace(/\s+/g, '')}`;
    });
  }

  // Real Outbound Telephony Call Listeners
  if (DOM.btnOpenTwilioSettings) {
    DOM.btnOpenTwilioSettings.addEventListener('click', openTwilioSettingsModal);
  }
  if (DOM.btnCloseTwilioModal) {
    DOM.btnCloseTwilioModal.addEventListener('click', closeTwilioSettingsModal);
  }
  if (DOM.btnCancelTwilio) {
    DOM.btnCancelTwilio.addEventListener('click', closeTwilioSettingsModal);
  }
  if (DOM.btnSaveTwilioConfig) {
    DOM.btnSaveTwilioConfig.addEventListener('click', submitTwilioConfig);
  }
  if (DOM.btnTriggerRealPhoneCall) {
    DOM.btnTriggerRealPhoneCall.addEventListener('click', triggerRealAIPhoneCall);
  }

  // Speech Recognition Microphone
  initSpeechRecognition();
}

// ----------------- API Data Fetching -----------------

async function loadVillages() {
  try {
    const res = await fetch('/api/admin/villages');
    if (!res.ok) throw new Error('Failed to fetch villages');
    state.villages = await res.json();
    if (state.villages.length > 0) {
      const current = state.villages[0];
      DOM.kpiTotalFarmers.textContent = current.total_farmers;
      DOM.kpiFeaturePhone.textContent = current.feature_phone_farmers;
      DOM.kpiSmartphone.textContent = current.smartphone_farmers;
      DOM.kpiCriticalFarms.textContent = current.critical_alerts_count;
      
      const pct = Math.round((current.feature_phone_farmers / current.total_farmers) * 100);
      DOM.kpiFeaturePct.textContent = `${pct}%`;
    }
  } catch (err) {
    console.error('loadVillages error:', err);
  }
}

async function loadFarmers() {
  try {
    const res = await fetch('/api/admin/farmers');
    if (!res.ok) throw new Error('Failed to fetch farmers');
    state.farmers = await res.json();
    updateFilterCounts();
    applyFilters();
  } catch (err) {
    console.error('loadFarmers error:', err);
    showToast('Failed to load farmers telemetry data');
  }
}

function updateFilterCounts() {
  const total = state.farmers.length;
  const feature = state.farmers.filter(f => !f.has_smartphone).length;
  const smart = state.farmers.filter(f => f.has_smartphone).length;
  const critical = state.farmers.filter(f => f.risk_level === 'CRITICAL' || f.risk_level === 'ELEVATED').length;

  DOM.countAll.textContent = total;
  DOM.countFeature.textContent = feature;
  DOM.countSmart.textContent = smart;
  DOM.countCritical.textContent = critical;

  // Calculate total acres
  const totalAcres = state.farmers.reduce((acc, f) => acc + (f.farm_size_acres || 0), 0);
  DOM.kpiTotalAcres.textContent = totalAcres.toFixed(1);
}

function applyFilters() {
  let list = [...state.farmers];

  // Device / Risk tab filter
  if (state.currentFilter === 'feature_phone') {
    list = list.filter(f => !f.has_smartphone);
  } else if (state.currentFilter === 'smartphone') {
    list = list.filter(f => f.has_smartphone);
  } else if (state.currentFilter === 'critical') {
    list = list.filter(f => f.risk_level === 'CRITICAL' || f.risk_level === 'ELEVATED');
  }

  // Crop Filter
  if (state.cropFilter !== 'ALL') {
    list = list.filter(f => f.primary_crop.toLowerCase().includes(state.cropFilter.toLowerCase()));
  }

  // Text Search
  if (state.searchQuery) {
    const q = state.searchQuery.toLowerCase();
    list = list.filter(f => 
      f.name.toLowerCase().includes(q) ||
      (f.name_tamil && f.name_tamil.includes(q)) ||
      f.phone_number.includes(q) ||
      f.primary_crop.toLowerCase().includes(q) ||
      f.hamlet.toLowerCase().includes(q)
    );
  }

  state.filteredFarmers = list;
  DOM.showingCountBadge.textContent = `Showing ${list.length} of ${state.farmers.length}`;

  renderFarmers();
}

function setViewMode(mode) {
  state.viewMode = mode;
  DOM.btnViewGrid.classList.toggle('active', mode === 'grid');
  DOM.btnViewTable.classList.toggle('active', mode === 'table');
  DOM.farmersGrid.classList.toggle('hidden', mode === 'table');
  DOM.farmersTableWrap.classList.toggle('hidden', mode === 'grid');
  renderFarmers();
}

// ----------------- Rendering Farmers -----------------

function renderFarmers() {
  if (state.viewMode === 'grid') {
    renderFarmersGrid();
  } else {
    renderFarmersTable();
  }
}

function renderFarmersGrid() {
  DOM.farmersGrid.innerHTML = '';

  if (state.filteredFarmers.length === 0) {
    DOM.farmersGrid.innerHTML = `
      <div class="empty-state glass-card" style="grid-column: 1 / -1; padding: 3rem; text-align: center;">
        <div style="font-size: 2.5rem; margin-bottom: 0.5rem;">🔍</div>
        <h3>No Farmers Found Matching Criteria</h3>
        <p style="color: var(--text-muted); font-size: 0.85rem;">Try relaxing the device filter or clearing your search term.</p>
      </div>
    `;
    return;
  }

  state.filteredFarmers.forEach(farmer => {
    const card = document.createElement('div');
    const riskClass = `card-${farmer.risk_level.toLowerCase()}`;
    card.className = `farmer-card glass-card ${riskClass}`;

    const deviceBadgeClass = farmer.has_smartphone ? 'badge-smartphone' : 'badge-feature-phone';
    const deviceIcon = farmer.has_smartphone ? '📱' : '📞';
    const deviceLabel = farmer.has_smartphone ? 'Smartphone App' : 'Feature Phone (2G)';

    let moistureClass = 'moisture-val-optimal';
    if (farmer.soil_moisture_pct < 25) moistureClass = 'moisture-val-critical';
    else if (farmer.soil_moisture_pct > 40) moistureClass = 'moisture-val-elevated';

    card.innerHTML = `
      <div class="card-top">
        <div class="card-farmer-info">
          <div class="card-farmer-name">
            <span>${farmer.name}</span>
          </div>
          <div class="card-farmer-tamil">${farmer.name_tamil || ''}</div>
          <div class="card-hamlet">📍 ${farmer.hamlet} • ${farmer.phone_number}</div>
        </div>
        <div class="device-badge ${deviceBadgeClass}">
          <span>${deviceIcon}</span>
          <span>${deviceLabel}</span>
        </div>
      </div>

      <div class="card-telemetry-row">
        <div class="tel-item">
          <span class="tel-label">CROP & ACRES</span>
          <span class="tel-value">${farmer.primary_crop.split(' ')[0]} • ${farmer.farm_size_acres} Ac</span>
        </div>
        <div class="tel-item">
          <span class="tel-label">SOIL MOISTURE</span>
          <span class="tel-value ${moistureClass}">${farmer.soil_moisture_pct}%</span>
        </div>
      </div>

      <div class="card-tinyml-strip">
        <div class="tinyml-label-row">
          <span>TINYML EDGE DECISION</span>
          <span style="color: var(--text-muted);">${farmer.crop_stage}</span>
        </div>
        <div class="tinyml-decision-text">
          <span>⚡</span>
          <span>${farmer.tinyml_edge_decision}</span>
        </div>
      </div>

      <div class="card-actions">
        <button class="btn btn-card-inspect" data-action="inspect" data-id="${farmer.id}">
          🔍 Inspect Farm
        </button>
        <button class="btn btn-card-sms" data-action="sms" data-id="${farmer.id}" title="Send SMS Summary">
          💬 Send SMS
        </button>
        <button class="btn btn-card-call" data-action="call" data-id="${farmer.id}" title="AI Voice Call Assistant">
          📞 AI Call
        </button>
      </div>
    `;

    // Action button handlers
    card.querySelector('[data-action="inspect"]').addEventListener('click', () => openFarmModal(farmer.id));
    card.querySelector('[data-action="sms"]').addEventListener('click', () => openSMSModal(farmer));
    card.querySelector('[data-action="call"]').addEventListener('click', () => openVoiceModal(farmer));

    DOM.farmersGrid.appendChild(card);
  });
}

function renderFarmersTable() {
  DOM.farmersTableBody.innerHTML = '';

  state.filteredFarmers.forEach(farmer => {
    const tr = document.createElement('tr');
    const deviceIcon = farmer.has_smartphone ? '📱' : '📞';
    const deviceBadgeClass = farmer.has_smartphone ? 'badge-smartphone' : 'badge-feature-phone';

    tr.innerHTML = `
      <td>
        <strong>${farmer.name}</strong><br>
        <small style="color: var(--emerald-400);">${farmer.name_tamil || ''}</small><br>
        <small style="color: var(--text-muted);">${farmer.phone_number}</small>
      </td>
      <td>
        <span class="device-badge ${deviceBadgeClass}">
          ${deviceIcon} ${farmer.device_type}
        </span>
      </td>
      <td>
        ${farmer.primary_crop}<br>
        <small style="color: var(--text-muted);">${farmer.farm_size_acres} Acres • ${farmer.crop_stage}</small>
      </td>
      <td>
        <strong class="font-mono">${farmer.soil_moisture_pct}%</strong>
      </td>
      <td>
        <code style="font-size: 0.72rem; color: var(--amber-400);">${farmer.tinyml_edge_decision}</code>
      </td>
      <td>
        <span class="badge" style="font-size: 0.68rem;">${farmer.risk_level}</span>
      </td>
      <td>
        <div style="display: flex; gap: 0.35rem;">
          <button class="btn btn-sm btn-secondary" data-action="inspect" data-id="${farmer.id}">🔍 Inspect</button>
          <button class="btn btn-sm btn-card-sms" data-action="sms" data-id="${farmer.id}">💬 SMS</button>
          <button class="btn btn-sm btn-card-call" data-action="call" data-id="${farmer.id}">📞 Call</button>
        </div>
      </td>
    `;

    tr.querySelector('[data-action="inspect"]').addEventListener('click', () => openFarmModal(farmer.id));
    tr.querySelector('[data-action="sms"]').addEventListener('click', () => openSMSModal(farmer));
    tr.querySelector('[data-action="call"]').addEventListener('click', () => openVoiceModal(farmer));

    DOM.farmersTableBody.appendChild(tr);
  });
}

// ----------------- MODAL 1: Farm Deep Dive -----------------

async function openFarmModal(farmerId) {
  try {
    const res = await fetch(`/api/admin/farmers/${farmerId}`);
    if (!res.ok) throw new Error('Failed to load farm details');
    const farmer = await res.json();
    state.activeFarmer = farmer;
    state.activeFarmerDetails = farmer;

    // Header info
    DOM.modalDeviceBadge.textContent = farmer.has_smartphone ? '📱 SMARTPHONE APP ACTIVE' : '📞 FEATURE PHONE (NO SMARTPHONE)';
    DOM.modalDeviceBadge.className = `modal-badge ${farmer.has_smartphone ? 'badge-smartphone' : 'badge-feature-phone'}`;
    DOM.modalFarmerTitle.textContent = `${farmer.name} (${farmer.name_tamil || ''})`;
    DOM.modalFarmSubtitle.textContent = `${farmer.farm_name} • ${farmer.farm_size_acres} Acres • ${farmer.hamlet} • ${farmer.phone_number}`;

    // Gauges
    const moisture = farmer.telemetry.soil_moisture_pct;
    DOM.gaugeMoisture.textContent = `${moisture}%`;
    DOM.barMoisture.style.width = `${Math.min(100, moisture)}%`;

    if (moisture < 25) {
      DOM.statusMoisture.textContent = 'CRITICAL DEFICIT';
      DOM.statusMoisture.className = 'gauge-footer text-red';
    } else if (moisture > 40) {
      DOM.statusMoisture.textContent = 'HIGH MOISTURE / SATURATED';
      DOM.statusMoisture.className = 'gauge-footer text-amber';
    } else {
      DOM.statusMoisture.textContent = 'OPTIMAL MOISTURE';
      DOM.statusMoisture.className = 'gauge-footer text-green';
    }

    DOM.gaugePhTemp.textContent = `${farmer.telemetry.soil_ph} pH • ${farmer.telemetry.soil_temp_c}°C`;
    DOM.gaugeCropStage.textContent = farmer.primary_crop;
    DOM.gaugeStageSub.textContent = farmer.crop_stage;

    DOM.npkN.textContent = farmer.telemetry.nitrogen_kg_ha;
    DOM.npkP.textContent = farmer.telemetry.phosphorus_kg_ha;
    DOM.npkK.textContent = farmer.telemetry.potassium_kg_ha;

    // TinyML & Risk findings
    DOM.modalTinyMLDecision.textContent = farmer.telemetry.tinyml_edge_decision;
    DOM.modalRiskTitle.textContent = farmer.risk.title;
    DOM.modalRiskBadge.textContent = `${farmer.risk.level} RISK`;
    DOM.modalDiseaseName.textContent = farmer.risk.recent_disease || 'Healthy Crop';
    DOM.modalActionEn.textContent = farmer.risk.recommended_action || 'Maintain current schedule.';
    DOM.modalActionTa.textContent = farmer.risk.recommended_action_tamil || 'வழக்கமான பயிர் பராமரிப்பை தொடரவும்.';

    // History
    renderCallNotesHistory(farmer.call_notes);
    renderSMSHistory(farmer.sms_history);

    DOM.farmModal.classList.remove('hidden');
  } catch (err) {
    console.error('openFarmModal error:', err);
    showToast('Failed to open farm deep dive inspector');
  }
}

function renderCallNotesHistory(notes) {
  DOM.countCallNotes.textContent = notes.length;
  DOM.callNotesList.innerHTML = '';

  if (notes.length === 0) {
    DOM.callNotesList.innerHTML = '<p style="color: var(--text-muted); font-size: 0.8rem;">No voice call records yet. Initiate an AI call to auto-log farmer queries.</p>';
    return;
  }

  notes.forEach(note => {
    const card = document.createElement('div');
    card.className = 'call-note-card';

    const queriesHtml = note.extracted_queries.map(q => `<li>"${q}"</li>`).join('');
    const actionsHtml = note.officer_action_items.map(a => `
      <label class="action-checkbox-row">
        <input type="checkbox" ${note.is_resolved ? 'checked' : ''} data-note-id="${note.id}">
        <span>${a}</span>
      </label>
    `).join('');

    const formattedTime = new Date(note.timestamp).toLocaleString();

    card.innerHTML = `
      <div class="call-note-top">
        <span>⏱️ Duration: ${note.call_duration_seconds}s • Mood: ${note.farmer_mood}</span>
        <span>${formattedTime}</span>
      </div>
      <div style="font-size: 0.825rem; margin-bottom: 0.35rem;">
        <strong>AI Agronomist Summary:</strong> ${note.ai_response_summary}
      </div>
      <div style="font-size: 0.725rem; font-weight: 700; color: var(--amber-400);">FARMER QUERIES RAISED:</div>
      <ul class="call-note-queries">
        ${queriesHtml}
      </ul>
      <div style="font-size: 0.725rem; font-weight: 700; color: var(--purple-400); margin-top: 0.5rem;">OFFICER FOLLOW-UP TASKS:</div>
      <div class="call-note-actions">
        ${actionsHtml}
      </div>
    `;

    card.querySelectorAll('input[type="checkbox"]').forEach(cb => {
      cb.addEventListener('change', async (e) => {
        const noteId = e.target.dataset.noteId;
        await toggleNoteResolved(noteId);
      });
    });

    DOM.callNotesList.appendChild(card);
  });
}

function renderSMSHistory(logs) {
  DOM.countSMSLogs.textContent = logs.length;
  DOM.smsLogsList.innerHTML = '';

  if (logs.length === 0) {
    DOM.smsLogsList.innerHTML = '<p style="color: var(--text-muted); font-size: 0.8rem;">No SMS advisories sent yet.</p>';
    return;
  }

  logs.forEach(log => {
    const card = document.createElement('div');
    card.className = 'sms-log-card';
    const formattedTime = new Date(log.timestamp).toLocaleString();

    card.innerHTML = `
      <div class="sms-log-top">
        <span style="color: var(--emerald-400); font-weight: 700;">✅ ${log.delivery_status} • Ref: ${log.carrier_ref}</span>
        <span>${formattedTime}</span>
      </div>
      <div style="font-size: 0.8rem; margin-bottom: 0.35rem;">${log.message_tamil || ''}</div>
      <div style="font-size: 0.75rem; color: var(--text-muted); font-style: italic;">${log.message_english}</div>
    `;
    DOM.smsLogsList.appendChild(card);
  });
}

async function toggleNoteResolved(noteId) {
  try {
    const res = await fetch(`/api/admin/call-notes/${noteId}/resolve`, { method: 'PATCH' });
    if (res.ok) {
      showToast('Action item status updated');
    }
  } catch (err) {
    console.error('toggleNoteResolved error:', err);
  }
}

function closeFarmModal() {
  DOM.farmModal.classList.add('hidden');
}

// ----------------- MODAL 2: SMS Summary Advisory -----------------

function openSMSModal(farmer) {
  state.activeFarmer = farmer;
  DOM.smsModalRecipient.textContent = `Recipient: ${farmer.name} (${farmer.name_tamil || ''}) • ${farmer.phone_number}`;
  DOM.smsDeliveryResult.classList.add('hidden');
  DOM.btnDispatchSMS.disabled = false;
  DOM.btnDispatchSMS.innerHTML = '<span>🚀 Dispatch SMS Advisory</span>';

  // Set default language to Tamil
  setSmsLanguage('ta');

  if (DOM.linkNativeSMSApp) {
    const cleanPhone = (farmer.phone_number || '').replace(/\s+/g, '');
    DOM.linkNativeSMSApp.href = `sms:${cleanPhone}?body=${encodeURIComponent(DOM.smsMessageText.value || '')}`;
  }

  DOM.smsModal.classList.remove('hidden');
}

function setSmsLanguage(lang) {
  DOM.btnSmsLangTa.classList.toggle('active', lang === 'ta');
  DOM.btnSmsLangEn.classList.toggle('active', lang === 'en');
  DOM.btnSmsLangBoth.classList.toggle('active', lang === 'both');

  const farmer = state.activeFarmer;
  if (!farmer) return;

  const defaultTa = (
    `வணக்கம் ${farmer.name_tamil || farmer.name} ஐயா, உங்கள் ${farmer.primary_crop} வயலில் ஈரப்பதம் ${farmer.soil_moisture_pct}%. ` +
    `நிலைமை: ${farmer.risk_level}. பரிந்துரை: ${farmer.recommended_action_tamil || farmer.recommended_action} - மெலட்டூர் வேளாண் மையம்.`
  );
  const defaultEn = (
    `AgriVyn Advisory for ${farmer.name}: ${farmer.primary_crop} Field. Soil moisture at ${farmer.soil_moisture_pct}%. ` +
    `Status: ${farmer.risk_level}. Action: ${farmer.recommended_action} - Melattur Agri Office.`
  );

  if (lang === 'ta') {
    DOM.smsMessageText.value = defaultTa;
  } else if (lang === 'en') {
    DOM.smsMessageText.value = defaultEn;
  } else {
    DOM.smsMessageText.value = `${defaultTa}\n\n[EN]: ${defaultEn}`;
  }

  updateSmsCharCount();
}

function updateSmsCharCount() {
  const len = DOM.smsMessageText.value.length;
  const credits = Math.ceil(len / 160) || 1;
  DOM.smsCharCount.textContent = `${len} characters (${credits} SMS credit${credits > 1 ? 's' : ''})`;

  if (DOM.linkNativeSMSApp && state.activeFarmer) {
    const cleanPhone = (state.activeFarmer.phone_number || '').replace(/\s+/g, '');
    DOM.linkNativeSMSApp.href = `sms:${cleanPhone}?body=${encodeURIComponent(DOM.smsMessageText.value || '')}`;
  }
}

async function dispatchSMS() {
  if (!state.activeFarmer) return;

  const messageText = DOM.smsMessageText.value.trim();
  if (!messageText) {
    alert('Please enter message text before dispatching.');
    return;
  }

  DOM.btnDispatchSMS.disabled = true;
  DOM.btnDispatchSMS.innerHTML = '<span>⏳ Dispatching via GSM Gateway...</span>';

  try {
    const res = await fetch(`/api/admin/farmers/${state.activeFarmer.id}/send-sms`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        message_tamil: messageText,
        message_english: messageText
      })
    });

    if (!res.ok) throw new Error('SMS dispatch error');
    const result = await res.json();

    DOM.receiptRef.textContent = `Carrier Reference: ${result.carrier_reference}`;
    DOM.receiptTime.textContent = `Delivered: ${new Date(result.timestamp).toLocaleTimeString()}`;
    DOM.smsDeliveryResult.classList.remove('hidden');

    DOM.btnDispatchSMS.innerHTML = '<span>✅ Sent Successfully</span>';
    showToast(`SMS Summary delivered to ${result.recipient}`);
  } catch (err) {
    console.error('dispatchSMS error:', err);
    DOM.btnDispatchSMS.disabled = false;
    DOM.btnDispatchSMS.innerHTML = '<span>🚀 Dispatch SMS Advisory</span>';
    showToast('Failed to dispatch SMS');
  }
}

function closeSMSModal() {
  DOM.smsModal.classList.add('hidden');
}

// ----------------- MODAL 3: Interactive AI Voice Call System -----------------

function openVoiceModal(farmer) {
  state.activeFarmer = farmer;
  state.voiceCall.isActive = true;
  state.voiceCall.durationSeconds = 0;
  state.voiceCall.dialogue = [];
  state.voiceCall.extractedQueries = [];
  state.voiceCall.extractedActions = [];

  DOM.voiceModalFarmerName.textContent = `AI Voice Call: ${farmer.name} (${farmer.name_tamil || ''})`;
  DOM.voiceModalPhone.textContent = `${farmer.phone_number} • Feature Phone (Tamil Voice Protocol)`;
  DOM.phoneFarmerName.textContent = farmer.name;
  DOM.phoneFarmerCrop = `${farmer.primary_crop} • ${farmer.hamlet}`;
  DOM.callStatusText.textContent = 'Connecting...';
  DOM.liveDialogueBox.innerHTML = '';
  DOM.extractedQueriesList.innerHTML = '';
  DOM.extractedActionsList.innerHTML = '';

  if (DOM.voiceModalPhoneInput) {
    DOM.voiceModalPhoneInput.value = farmer.phone_number || "+91 98421 78210";
  }
  if (DOM.linkNativePhoneDial) {
    const clean = (farmer.phone_number || "").replace(/\s+/g, "");
    DOM.linkNativePhoneDial.href = `tel:${clean}`;
  }

  DOM.voiceModal.classList.remove('hidden');

  // Start Call Timer
  if (state.voiceCall.timerInterval) clearInterval(state.voiceCall.timerInterval);
  state.voiceCall.timerInterval = setInterval(updateCallTimer, 1000);

  // Initial greeting from AI Voice Agent
  if (!farmer.id) {
    connectCallToPhoneNumber(farmer.phone_number || "+91 98421 78210");
  } else {
    setTimeout(() => {
      DOM.callStatusText.textContent = 'Call Connected';
      const greetingTa = (
        `வணக்கம் ${farmer.name_tamil || farmer.name} ஐயா! நான் அக்ரிவின் AI வேளாண்மை உதவியாளர் பேசுகிறேன். ` +
        `உங்கள் வயலில் ஈரப்பதம் ${farmer.soil_moisture_pct}% ஆக உள்ளது. உங்களுக்கு ஏதேனும் சந்தேகங்கள் உள்ளதா?`
      );

      addDialogueTurn('AI_AGENT', greetingTa);
      speakSpokenAudio(greetingTa, 'ta');

      // Pre-populate with default action based on current field state
      if (farmer.recommended_action) {
        addActionItem(`Inspect ${farmer.name}'s field regarding: ${farmer.recommended_action}`);
      }
    }, 1000);
  }
}

function updateCallTimer() {
  state.voiceCall.durationSeconds++;
  const m = String(Math.floor(state.voiceCall.durationSeconds / 60)).padStart(2, '0');
  const s = String(state.voiceCall.durationSeconds % 60).padStart(2, '0');
  DOM.callStatusText.textContent = `Connected • ${m}:${s}`;
}

function addDialogueTurn(speaker, text) {
  state.voiceCall.dialogue.push({ speaker, text });

  const bubble = document.createElement('div');
  const isAI = speaker === 'AI_AGENT';
  bubble.className = `chat-bubble ${isAI ? 'bubble-ai' : 'bubble-farmer'}`;

  const speakerName = isAI ? '🌱 AgriVyn AI Assistant' : `👨‍🌾 ${state.activeFarmer ? state.activeFarmer.name : 'Farmer'}`;

  bubble.innerHTML = `
    <div class="bubble-speaker">${speakerName}</div>
    <div class="bubble-content">${text}</div>
  `;

  DOM.liveDialogueBox.appendChild(bubble);
  DOM.liveDialogueBox.scrollTop = DOM.liveDialogueBox.scrollHeight;
}

// Interactive Query Processing
async function processFarmerVoiceQuery(queryText) {
  if (!state.activeFarmer) return;

  // 1. Add Farmer speech to UI
  addDialogueTurn('FARMER', queryText);
  addExtractedQuery(queryText);

  // Set speaker state
  setSpeakerState('thinking');

  try {
    const res = await fetch(`/api/admin/farmers/${state.activeFarmer.id}/ai-call/chat`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        user_message: queryText,
        conversation_history: state.voiceCall.dialogue
      })
    });

    if (!res.ok) throw new Error('AI conversation error');
    const result = await res.json();

    // 2. Add AI reply
    addDialogueTurn('AI_AGENT', result.reply);
    speakSpokenAudio(result.reply, 'ta');

    // 3. Add extracted officer action
    if (result.suggested_action) {
      addActionItem(result.suggested_action);
    }
  } catch (err) {
    console.error('processFarmerVoiceQuery error:', err);
    const fallback = 'ஐயா, உங்கள் கோரிக்கை பதிவு செய்யப்பட்டது. வேளாண்மை அலுவலர் உடனே தொடர்பு கொள்வார்.';
    addDialogueTurn('AI_AGENT', fallback);
    speakSpokenAudio(fallback, 'ta');
  }
}

function addExtractedQuery(q) {
  if (!state.voiceCall.extractedQueries.includes(q)) {
    state.voiceCall.extractedQueries.push(q);
    const li = document.createElement('li');
    li.className = 'query-item';
    li.textContent = `"${q}"`;
    DOM.extractedQueriesList.appendChild(li);
  }
}

function addActionItem(action) {
  if (!state.voiceCall.extractedActions.includes(action)) {
    state.voiceCall.extractedActions.push(action);
    const item = document.createElement('div');
    item.className = 'action-item-pill';
    item.innerHTML = `
      <span class="action-check">☐</span>
      <span>${action}</span>
    `;
    DOM.extractedActionsList.appendChild(item);
  }
}

function setSpeakerState(state) {
  if (state === 'speaking') {
    DOM.speakerStateText.textContent = 'AI Voice Assistant Speaking...';
    DOM.speakerStatePill.style.display = 'flex';
    DOM.audioWaveform.classList.remove('paused');
  } else if (state === 'thinking') {
    DOM.speakerStateText.textContent = 'AI Analyzing Farm Telemetry...';
    DOM.speakerStatePill.style.display = 'flex';
    DOM.audioWaveform.classList.add('paused');
  } else {
    DOM.speakerStateText.textContent = 'Listening to Farmer...';
    DOM.audioWaveform.classList.add('paused');
  }
}

// Real Web Speech API Spoken Audio Output
function speakSpokenAudio(text, lang = 'ta') {
  if (state.voiceCall.isAudioMuted) return;
  if (!('speechSynthesis' in window)) {
    console.warn('Browser does not support SpeechSynthesis');
    return;
  }

  window.speechSynthesis.cancel(); // Stop any pending utterances
  setSpeakerState('speaking');

  const utterance = new SpeechSynthesisUtterance(text);
  utterance.rate = 0.92;
  utterance.pitch = 1.0;

  // Try to find an Indian English or Tamil voice if available
  const voices = window.speechSynthesis.getVoices();
  const matchedVoice = voices.find(v => v.lang.includes('ta') || v.lang.includes('ta-IN') || v.lang.includes('en-IN'));
  if (matchedVoice) {
    utterance.voice = matchedVoice;
  }

  utterance.onend = () => {
    setSpeakerState('listening');
  };

  utterance.onerror = () => {
    setSpeakerState('listening');
  };

  window.speechSynthesis.speak(utterance);
}

function toggleAudioMute() {
  state.voiceCall.isAudioMuted = !state.voiceCall.isAudioMuted;
  if (state.voiceCall.isAudioMuted) {
    window.speechSynthesis.cancel();
    DOM.btnToggleSpeechAudio.textContent = '🔇 Voice Muted';
    DOM.btnToggleSpeechAudio.style.background = 'rgba(239, 68, 68, 0.2)';
    setSpeakerState('listening');
  } else {
    DOM.btnToggleSpeechAudio.textContent = '🔊 Voice On';
    DOM.btnToggleSpeechAudio.style.background = 'rgba(255, 255, 255, 0.08)';
  }
}

async function endVoiceCallAndSaveNotes() {
  if (state.voiceCall.timerInterval) {
    clearInterval(state.voiceCall.timerInterval);
    state.voiceCall.timerInterval = null;
  }
  window.speechSynthesis.cancel();
  DOM.callStatusText.textContent = 'Call Ended • Logging Notes...';
  setSpeakerState('listening');

  // Trigger save
  await saveCallNotesToBackend();
}

async function saveCallNotesToBackend() {
  if (!state.activeFarmer) return;

  const queries = state.voiceCall.extractedQueries.length > 0 
    ? state.voiceCall.extractedQueries 
    : ['மண்ணில் ஈரப்பதம் குறைந்துவிட்டது, என்ன செய்ய வேண்டும்?'];

  const actions = state.voiceCall.extractedActions.length > 0
    ? state.voiceCall.extractedActions
    : [`Field visit by VAO for ${state.activeFarmer.name} regarding moisture deficit`];

  const summary = `AI Agronomist conducted automated voice consultation with ${state.activeFarmer.name} regarding ${state.activeFarmer.primary_crop} cultivation. Provided immediate furrow irrigation steps and recommended TNAU protocol.`;

  try {
    DOM.btnSaveCallNotesToDB.disabled = true;
    DOM.btnSaveCallNotesToDB.innerHTML = '<span>💾 Saving Notes to Farmer Profile...</span>';

    const res = await fetch(`/api/admin/farmers/${state.activeFarmer.id}/ai-call/save-notes`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        call_duration_seconds: state.voiceCall.durationSeconds || 95,
        farmer_mood: 'SEEKING_ADVICE',
        extracted_queries: queries,
        ai_response_summary: summary,
        officer_action_items: actions,
        transcript: state.voiceCall.dialogue
      })
    });

    if (!res.ok) throw new Error('Save call notes error');
    const data = await res.json();

    DOM.btnSaveCallNotesToDB.innerHTML = '<span>✅ Notes & Tasks Saved to Database</span>';
    showToast(`Call Notes & Action Items saved for ${data.farmer_name}!`);

    // Increment KPI
    const currentActions = parseInt(DOM.kpiActionItems.textContent || '0', 10);
    DOM.kpiActionItems.textContent = currentActions + 1;

    setTimeout(() => {
      closeVoiceModal();
      DOM.btnSaveCallNotesToDB.disabled = false;
      DOM.btnSaveCallNotesToDB.innerHTML = '<span>💾 Save Call Notes & Follow-up Tasks to Farmer Record</span>';
    }, 1200);
  } catch (err) {
    console.error('saveCallNotesToBackend error:', err);
    DOM.btnSaveCallNotesToDB.disabled = false;
    DOM.btnSaveCallNotesToDB.innerHTML = '<span>💾 Save Call Notes & Follow-up Tasks to Farmer Record</span>';
    showToast('Failed to save call notes');
  }
}

function closeVoiceModal() {
  if (state.voiceCall.timerInterval) {
    clearInterval(state.voiceCall.timerInterval);
    state.voiceCall.timerInterval = null;
  }
  window.speechSynthesis.cancel();
  DOM.voiceModal.classList.add('hidden');
}

// ----------------- Toast Utilities -----------------

function showToast(message) {
  DOM.toastMessage.textContent = message;
  DOM.toastNotification.classList.remove('hidden');
  setTimeout(() => {
    DOM.toastNotification.classList.add('hidden');
  }, 3500);
}

// ----------------- OFFLINE FARMER REGISTRATION (VAO WEB) -----------------
function openRegisterFarmerModal() {
  if (DOM.registerFarmerModal) {
    DOM.registerFarmerModal.classList.remove('hidden');
  }
}

function closeRegisterFarmerModal() {
  if (DOM.registerFarmerModal) {
    DOM.registerFarmerModal.classList.add('hidden');
  }
}

async function submitRegisterFarmer(e) {
  if (e && e.preventDefault) e.preventDefault();

  const phone = DOM.regPhone.value.trim();
  const name = DOM.regName.value.trim();
  const nameTa = DOM.regNameTa.value.trim();
  const hamlet = DOM.regHamlet.value.trim();
  const crop = DOM.regCrop.value;
  const acres = parseFloat(DOM.regAcres.value) || 3.5;
  const moisture = parseFloat(DOM.regMoisture.value) || 22.0;
  const device = DOM.regDevice.value;

  if (!phone || !name) {
    alert('Please enter Farmer Mobile Number and Full Name.');
    return;
  }

  DOM.btnSubmitRegisterFarmer.disabled = true;
  DOM.btnSubmitRegisterFarmer.innerHTML = '<span>⏳ Registering Farmer & Mapping Plot...</span>';

  try {
    const res = await fetch('/api/admin/farmers/register', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        village_id: state.selectedVillageId || 1,
        name: name,
        name_tamil: nameTa || name,
        phone_number: phone,
        hamlet: hamlet,
        farm_name: `${name}'s Cauvery Delta Farm`,
        farm_size_acres: acres,
        primary_crop: crop,
        crop_stage: "Active Growth",
        soil_type: "Cauvery Alluvial Clay Loam",
        water_source: "Canal + Borewell",
        soil_moisture_pct: moisture,
        has_smartphone: false,
        device_type: device
      })
    });

    const data = await res.json();
    if (!res.ok || data.success === false) {
      throw new Error(data.message || (data.detail ? (typeof data.detail === 'string' ? data.detail : JSON.stringify(data.detail)) : 'Registration failed'));
    }

    closeRegisterFarmerModal();
    showToast(`Registered ${data.name} on the VAO Portal!`);
    await loadVillages();
    await loadFarmers();

    // Immediately open farm deep dive for the newly registered farmer
    if (data.id) {
      setTimeout(() => openFarmModal(data.id), 400);
    }
  } catch (err) {
    console.error('submitRegisterFarmer error:', err);
    showToast(err.message || 'Failed to register farmer');
  } finally {
    DOM.btnSubmitRegisterFarmer.disabled = false;
    DOM.btnSubmitRegisterFarmer.innerHTML = '<span>💾 Save Profile & Map Virtual Zones ➔</span>';
  }
}

// ----------------- DIRECT NUMBER CALL DEMO -----------------
async function connectCallToPhoneNumber(phoneNumber) {
  DOM.callStatusText.textContent = `Dialing ${phoneNumber}...`;
  setSpeakerState('thinking');

  try {
    const res = await fetch('/api/admin/farmers/direct-call/initiate', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        phone_number: phoneNumber,
        caller_name: state.activeFarmer ? state.activeFarmer.name : 'Farmer',
        crop: state.activeFarmer ? state.activeFarmer.primary_crop : 'Paddy'
      })
    });

    if (!res.ok) throw new Error('Call initiate failed');
    const data = await res.json();

    state.activeFarmer = data.farmer;
    DOM.voiceModalFarmerName.textContent = `AI Voice Call: ${data.farmer.name} (${data.farmer.name_tamil || ''})`;
    DOM.callStatusText.textContent = 'Call Connected';
    DOM.phoneFarmerName.textContent = data.farmer.name;
    DOM.phoneFarmerCrop = `${data.farmer.primary_crop} • ${phoneNumber}`;
    DOM.voiceModalPhone.textContent = `${phoneNumber} • Cellular Protocol`;

    if (DOM.linkNativePhoneDial) {
      DOM.linkNativePhoneDial.href = `tel:${phoneNumber.replace(/\s+/g, '')}`;
    }

    addDialogueTurn('AI_AGENT', data.greeting_tamil);
    speakSpokenAudio(data.greeting_tamil, 'ta');

    if (data.farmer.recommended_action) {
      addActionItem(data.farmer.recommended_action);
    }
  } catch (err) {
    console.error('connectCallToPhoneNumber error:', err);
    DOM.callStatusText.textContent = 'Connected (Direct Line)';
    const fallback = `வணக்கம் ஐயா! உங்கள் அலைபேசி எண் ${phoneNumber} இணைக்கப்பட்டுள்ளது. பயிர் ஆலோசனைக்கு என்ன உதவி வேண்டும்?`;
    addDialogueTurn('AI_AGENT', fallback);
    speakSpokenAudio(fallback, 'ta');
  }
}

// ----------------- SPEECH RECOGNITION MICROPHONE -----------------
function initSpeechRecognition() {
  if (!DOM.btnToggleMic) return;

  const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;
  if (!SpeechRecognition) {
    DOM.btnToggleMic.addEventListener('click', () => {
      showToast('Microphone simulated — you can type your query in the box');
    });
    return;
  }

  const recognition = new SpeechRecognition();
  recognition.continuous = false;
  recognition.interimResults = false;
  recognition.lang = 'ta-IN'; // Tamil speech input, fallback to Indian English

  recognition.onstart = () => {
    if (DOM.micStatusText) DOM.micStatusText.style.display = 'block';
    if (DOM.micIcon) DOM.micIcon.textContent = '🔴';
  };

  recognition.onresult = (event) => {
    const transcript = event.results[0][0].transcript;
    if (DOM.customQueryInput) DOM.customQueryInput.value = transcript;
    if (DOM.micStatusText) DOM.micStatusText.style.display = 'none';
    if (DOM.micIcon) DOM.micIcon.textContent = '🎤';
    processFarmerVoiceQuery(transcript);
  };

  recognition.onerror = (e) => {
    console.warn('SpeechRecognition error:', e);
    if (DOM.micStatusText) DOM.micStatusText.style.display = 'none';
    if (DOM.micIcon) DOM.micIcon.textContent = '🎤';
  };

  recognition.onend = () => {
    if (DOM.micStatusText) DOM.micStatusText.style.display = 'none';
    if (DOM.micIcon) DOM.micIcon.textContent = '🎤';
  };

  DOM.btnToggleMic.addEventListener('click', () => {
    try {
      recognition.start();
    } catch (e) {
      console.warn('Speech recognition start error:', e);
    }
  });
}

// =========================================================================
// REAL OUTBOUND TELEPHONY (TWILIO VOICE API INTEGRATION)
// =========================================================================

async function checkTelephonyConfig() {
  try {
    const res = await fetch('/api/telephony/config-status');
    if (!res.ok) return;
    const data = await res.json();
    state.telephony = data;

    if (DOM.telephonyConfigBadge) {
      if (data.is_configured) {
        DOM.telephonyConfigBadge.style.background = '#dcfce7';
        DOM.telephonyConfigBadge.style.color = '#15803d';
        DOM.telephonyConfigBadge.textContent = `🟢 Twilio Active (${data.twilio_phone_masked})`;
      } else {
        DOM.telephonyConfigBadge.style.background = '#fef3c7';
        DOM.telephonyConfigBadge.style.color = '#b45309';
        DOM.telephonyConfigBadge.textContent = '⚠️ Twilio Not Set';
      }
    }
  } catch (err) {
    console.warn('checkTelephonyConfig error:', err);
  }
}

function openTwilioSettingsModal() {
  if (DOM.twilioSettingsModal) {
    DOM.twilioSettingsModal.classList.remove('hidden');
    if (state.telephony && state.telephony.public_server_url && DOM.cfgPublicUrl) {
      DOM.cfgPublicUrl.value = state.telephony.public_server_url === 'Not Set (Direct TwiML Mode Active)' ? '' : state.telephony.public_server_url;
    }
  }
}

function closeTwilioSettingsModal() {
  if (DOM.twilioSettingsModal) {
    DOM.twilioSettingsModal.classList.add('hidden');
  }
}

async function submitTwilioConfig(e) {
  if (e) e.preventDefault();
  const sid = DOM.cfgTwilioSid ? DOM.cfgTwilioSid.value.trim() : '';
  const token = DOM.cfgTwilioToken ? DOM.cfgTwilioToken.value.trim() : '';
  const phone = DOM.cfgTwilioPhone ? DOM.cfgTwilioPhone.value.trim() : '';
  const publicUrl = DOM.cfgPublicUrl ? DOM.cfgPublicUrl.value.trim() : '';

  if (!sid || !token || !phone) {
    showToast('Please fill in Account SID, Auth Token, and Twilio Phone Number');
    return;
  }

  try {
    DOM.btnSaveTwilioConfig.disabled = true;
    DOM.btnSaveTwilioConfig.innerHTML = '<span>Saving...</span>';

    const res = await fetch('/api/telephony/update-config', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        account_sid: sid,
        auth_token: token,
        phone_number: phone,
        public_server_url: publicUrl
      })
    });

    const data = await res.json();
    if (!res.ok) throw new Error(data.detail || 'Failed to save config');

    showToast('✅ Twilio Credentials activated successfully!');
    closeTwilioSettingsModal();
    checkTelephonyConfig();
  } catch (err) {
    alert('Error saving Twilio keys: ' + err.message);
  } finally {
    DOM.btnSaveTwilioConfig.disabled = false;
    DOM.btnSaveTwilioConfig.innerHTML = '<span>💾 Save & Activate Twilio Keys</span>';
  }
}

async function triggerRealAIPhoneCall() {
  const phoneInput = DOM.voiceModalPhoneInput ? DOM.voiceModalPhoneInput.value.trim() : '';
  if (!phoneInput) {
    showToast('Please enter a target phone number (e.g. +91 98421 78210)');
    return;
  }

  const lang = DOM.realCallLanguageSelect ? DOM.realCallLanguageSelect.value : 'ta';
  const topic = DOM.realCallTopicSelect ? DOM.realCallTopicSelect.value : 'Soil Moisture Deficit';
  const farmerName = state.activeFarmer ? state.activeFarmer.name : 'Farmer';
  const crop = state.activeFarmer ? state.activeFarmer.primary_crop : 'Paddy (Samba)';
  const farmerId = state.activeFarmer ? state.activeFarmer.id : null;

  // Show calling banner
  if (DOM.realCallStatusBanner) {
    DOM.realCallStatusBanner.style.display = 'block';
    DOM.realCallStatusBanner.style.background = '#f0fdf4';
    DOM.realCallStatusBanner.style.border = '1.5px solid #86efac';
    DOM.realCallStatusBanner.style.color = '#15803d';
    DOM.realCallStatusText.innerHTML = `
      <div style="display: flex; align-items: center; gap: 0.5rem;">
        <span class="live-pulse"></span>
        <span>Calling real mobile phone <strong>${phoneInput}</strong> via Twilio Voice API...</span>
      </div>
    `;
  }

  DOM.btnTriggerRealPhoneCall.disabled = true;
  DOM.btnTriggerRealPhoneCall.innerHTML = '<span>Dialing Mobile...</span>';

  try {
    const res = await fetch('/api/telephony/call-real-phone', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        phone_number: phoneInput,
        farmer_name: farmerName,
        crop: crop,
        reason: topic,
        language: lang,
        farmer_id: farmerId
      })
    });

    const result = await res.json();

    if (!result.success) {
      // If Twilio not configured yet, pop up settings
      if (result.is_configured === false) {
        DOM.realCallStatusBanner.style.background = '#fef2f2';
        DOM.realCallStatusBanner.style.border = '1.5px solid #fca5a5';
        DOM.realCallStatusBanner.style.color = '#991b1b';
        DOM.realCallStatusText.innerHTML = `
          <strong>⚠️ Twilio Not Configured:</strong> Please click <strong>"⚙️ Twilio Settings"</strong> to enter your Twilio Account SID & Token, or add them to your <code>.env</code> file.
        `;
        openTwilioSettingsModal();
        return;
      }

      // If trial restrictions or helpful guidance returned
      if (result.is_trial_restriction || result.help || result.code === 21608) {
        DOM.realCallStatusBanner.style.background = '#fffbeb';
        DOM.realCallStatusBanner.style.border = '1.5px solid #fde68a';
        DOM.realCallStatusBanner.style.color = '#92400e';
        DOM.realCallStatusText.innerHTML = `
          <strong>⚠️ Twilio Trial Account Step:</strong> ${result.help || result.error}<br/><br/>
          <strong>Quick Fix in Twilio Console:</strong><br/>
          1️⃣ Get a free assigned trial number at <a href="https://console.twilio.com/" target="_blank" style="text-decoration:underline; font-weight:bold; color:#b45309;">Twilio Console Home</a> (click <em>"Get phone number"</em>).<br/>
          2️⃣ Verify your destination phone number at <a href="https://console.twilio.com/us1/develop/phone-numbers/manage/verified" target="_blank" style="text-decoration:underline; font-weight:bold; color:#b45309;">Verified Caller IDs</a>.<br/>
          3️⃣ Update <code>TWILIO_PHONE_NUMBER</code> with your assigned number, then click call again!
        `;
        showToast('Trial account setup required - check instructions');
        return;
      }

      DOM.realCallStatusBanner.style.background = '#fef2f2';
      DOM.realCallStatusBanner.style.border = '1.5px solid #fca5a5';
      DOM.realCallStatusBanner.style.color = '#991b1b';
      DOM.realCallStatusText.innerHTML = `<strong>Error:</strong> ${result.error || 'Failed to place call'}`;
      showToast('Call failed: ' + (result.error || 'Unknown error'));
      return;
    }

    // Success! The real phone is ringing!
    DOM.realCallStatusBanner.style.background = '#ecfdf5';
    DOM.realCallStatusBanner.style.border = '1.5px solid #34d399';
    DOM.realCallStatusBanner.style.color = '#065f46';
    DOM.realCallStatusText.innerHTML = `
      <div style="font-size: 0.88rem; font-weight: 800; margin-bottom: 0.25rem;">🔔 Real Phone Call In Progress! Your mobile is ringing.</div>
      <div style="font-size: 0.75rem; color: #047857; line-height: 1.4;">
        • <strong>Twilio Call SID:</strong> <code>${result.call_sid}</code><br/>
        • <strong>Target Phone:</strong> <code>${result.to_phone}</code><br/>
        • <strong>Status:</strong> <span class="badge" style="background:#a7f3d0; color:#064e3b; font-weight:800;">${result.status.toUpperCase()}</span><br/>
        • <strong>Spoken Speech:</strong> <em>"${result.spoken_preview}"</em><br/>
        • Pick up your phone to hear the AgriVyn AI agronomist speak!<br/>
        <div style="margin-top: 6px; padding: 6px 10px; background: #d1fae5; border-radius: 6px; color: #065f46; font-size: 0.74rem; line-height: 1.4;">
          💡 <strong>Twilio Trial Note:</strong> When you answer, Twilio says: <em>"You have a trial account. Press any key to execute your call."</em><br/>
          👉 <strong>Press 1 on your phone keypad</strong> to immediately hear the Tamil agricultural advisory!
        </div>
      </div>
    `;

    showToast(`🔔 Call placed! Ringing ${result.to_phone}`);

    // Add entry into the active dialogue box
    addDialogueTurn('AI_AGENT', `[REAL TELEPHONE CALL INITIATED TO ${result.to_phone}] ${result.spoken_preview}`);

  } catch (err) {
    console.error('triggerRealAIPhoneCall error:', err);
    DOM.realCallStatusBanner.style.background = '#fef2f2';
    DOM.realCallStatusBanner.style.border = '1.5px solid #fca5a5';
    DOM.realCallStatusBanner.style.color = '#991b1b';
    DOM.realCallStatusText.innerHTML = `<strong>Network Error:</strong> ${err.message}`;
  } finally {
    DOM.btnTriggerRealPhoneCall.disabled = false;
    DOM.btnTriggerRealPhoneCall.innerHTML = '<span>📞 Ring Mobile Phone Now</span>';
  }
}

// ============================================================
// REAL PHONE CALL TRANSCRIPT VIEWER
// Fetches /api/telephony/call-log and renders chat-style turns
// ============================================================

async function fetchAndRenderCallTranscripts() {
  if (!DOM.callTranscriptsList) return;
  try {
    const res = await fetch('/api/telephony/call-log');
    if (!res.ok) throw new Error(`HTTP ${res.status}`);
    const logs = await res.json();

    if (DOM.countCallTranscripts) DOM.countCallTranscripts.textContent = logs.length;

    if (logs.length === 0) {
      DOM.callTranscriptsList.innerHTML = '<p style="color:var(--text-muted); font-size:0.8rem;">No real phone call transcripts yet. Make a call using the Ring Mobile Phone Now button above.</p>';
      if (DOM.callTranscriptLiveBadge) DOM.callTranscriptLiveBadge.style.display = 'none';
      return;
    }

    if (DOM.callTranscriptLiveBadge) DOM.callTranscriptLiveBadge.style.display = 'inline-block';

    DOM.callTranscriptsList.innerHTML = '';
    logs.forEach(entry => {
      const card = document.createElement('div');
      card.style.cssText = 'border:1.5px solid var(--border-light,#e2e8f0); border-radius:10px; padding:0.9rem 1rem; margin-bottom:0.85rem; background:#f8fafc;';

      const headerHtml = `
        <div style="display:flex; align-items:center; justify-content:space-between; margin-bottom:0.65rem; flex-wrap:wrap; gap:0.4rem;">
          <div style="font-weight:800; font-size:0.85rem; color:#0f172a;">
            &#128222; ${entry.farmer || 'Unknown Farmer'} &bull; ${entry.crop || ''}
          </div>
          <div style="font-size:0.7rem; color:var(--text-muted);">${entry.started_at || ''} &bull; Call SID: <code style="font-size:0.68rem;">${(entry.call_sid || '').substring(0,14)}...</code></div>
        </div>
        <div style="font-size:0.74rem; color:#475569; margin-bottom:0.5rem; font-style:italic; padding:0.35rem 0.5rem; background:#f1f5f9; border-radius:6px;">
          &#128204; Reason: ${entry.reason || ''} ${entry.action ? ' &bull; Action: ' + entry.action : ''}
        </div>
      `;

      const turns = entry.turns || [];
      const turnsHtml = turns.length > 0 ? turns.map(turn => {
        const isAI = turn.speaker === 'AI';
        return `
          <div style="display:flex; gap:0.5rem; margin-bottom:0.5rem; ${isAI ? '' : 'flex-direction:row-reverse;'}">
            <div style="font-size:1.1rem; align-self:flex-end; flex-shrink:0;">${isAI ? '&#129302;' : '&#128068;'}</div>
            <div style="max-width:85%; padding:0.5rem 0.8rem; border-radius:${isAI ? '4px 14px 14px 14px' : '14px 4px 14px 14px'};
                        background:${isAI ? 'linear-gradient(135deg,#ecfdf5,#d1fae5)' : 'linear-gradient(135deg,#eff6ff,#dbeafe)'};
                        color:${isAI ? '#064e3b' : '#1e3a8a'}; font-size:0.79rem; line-height:1.5; border:1px solid ${isAI ? '#a7f3d0' : '#bfdbfe'};">
              <div style="font-size:0.65rem; font-weight:800; opacity:0.65; margin-bottom:3px; text-transform:uppercase; letter-spacing:0.04em;">${isAI ? 'AgriVyn AI Agronomist' : 'Farmer'} &bull; ${turn.time || ''}</div>
              ${turn.text || ''}
            </div>
          </div>
        `;
      }).join('') : '<p style="color:var(--text-muted);font-size:0.75rem;font-style:italic;">No dialogue turns recorded for this call.</p>';

      card.innerHTML = headerHtml + `<div style="margin-top:0.6rem; border-top:1px solid #e2e8f0; padding-top:0.6rem;">${turnsHtml}</div>`;
      DOM.callTranscriptsList.appendChild(card);
    });

  } catch (err) {
    console.warn('fetchAndRenderCallTranscripts error:', err);
    if (DOM.callTranscriptsList) {
      DOM.callTranscriptsList.innerHTML = `<p style="color:#ef4444; font-size:0.8rem;">&#9888; Could not load call transcripts: ${err.message}. Make sure the backend is running.</p>`;
    }
  }
}
