import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parent.parent))

from backend.app.services.telephony_service import TelephonyService
from backend.app.core.config import settings

def test_phone_number_normalization():
    # 10-digit Indian numbers
    assert TelephonyService.normalize_phone_number("9842178210") == "+919842178210"
    assert TelephonyService.normalize_phone_number("98421 78210") == "+919842178210"
    assert TelephonyService.normalize_phone_number("+91 98421-78210") == "+919842178210"
    
    # Numbers with leading 0
    assert TelephonyService.normalize_phone_number("09842178210") == "+919842178210"
    
    # Numbers with leading 91
    assert TelephonyService.normalize_phone_number("919842178210") == "+919842178210"

def test_twiml_generation_tamil():
    msg = TelephonyService.build_advisory_message(
        farmer_name="முருகன்",
        crop="நெல்",
        reason="மண் ஈரப்பதம் குறைவு",
        recommended_action="1.5 மணி நேரம் பாசனம் செய்யவும்",
        language="ta"
    )
    assert "முருகன்" in msg
    assert "பாசனம்" in msg
    
    twiml = TelephonyService.build_inline_twiml(msg, language="ta", allow_farmer_reply=False)
    assert "<Response>" in twiml
    assert "Polly.Aditi" in twiml
    assert "ta-IN" in twiml

def test_twiml_generation_english():
    msg = TelephonyService.build_advisory_message(
        farmer_name="Murugan",
        crop="Paddy",
        reason="Low moisture detected",
        recommended_action="Run irrigation",
        language="en"
    )
    assert "Murugan" in msg
    assert "irrigation" in msg
    
    twiml = TelephonyService.build_inline_twiml(msg, language="en", allow_farmer_reply=False)
    assert "<Response>" in twiml
    assert "en-IN" in twiml

def test_unconfigured_telephony_response():
    # Calling without valid credentials should give clean instructions without crashing
    res = TelephonyService.make_real_call(to_phone="9842178210")
    assert res["success"] is False
    assert "phone_number" in res
    assert res["phone_number"] == "+919842178210"

if __name__ == "__main__":
    test_phone_number_normalization()
    test_twiml_generation_tamil()
    test_twiml_generation_english()
    test_unconfigured_telephony_response()
    print("All 4 Telephony tests passed successfully!")
