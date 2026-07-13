"""
Regression test for reflected XSS in the OAuth popup response.

json.dumps() does not escape '<', '>' or '&', so interpolating it directly
into an inline <script> tag let a "message" containing "</script><script>..."
break out of the script block and execute attacker-controlled JS. Only the
visible <p> text was escaped; the JSON payload embedded in the script was not.
"""
from app.api.v1.social_import import _oauth_popup_response, _json_for_inline_script


def test_json_for_inline_script_escapes_script_breakout():
    payload = {"message": "</script><script>alert(document.domain)</script>"}
    serialized = _json_for_inline_script(payload)

    assert "</script>" not in serialized
    assert "<script>" not in serialized
    # Still valid, round-trippable JSON content (just with the dangerous
    # characters unicode-escaped rather than stripped).
    assert "\\u003c/script\\u003e" in serialized


def test_oauth_popup_response_escapes_malicious_message():
    malicious = "</script><script>alert(document.domain)</script>"

    response = _oauth_popup_response(
        job_id="job-123",
        status_value="error",
        message=malicious,
    )
    body = response.body.decode()

    # The payload embedded in the <script> block must not contain a literal
    # "</script>" that would close the real script tag early.
    script_start = body.index("<script>")
    script_end = body.index("</script>", script_start + len("<script>"))
    script_content = body[script_start:script_end]
    assert "</script>" not in script_content
    assert "<script>alert" not in script_content
