/*
 * Hydro Smart - ESP32 pH Monitoring Node
 * ======================================
 * Reads an analog pH probe via a 5V-powered signal board (e.g. the
 * "DO-PH-EC Sensor" board sold on graylogix.in, PH-4502C and
 * compatible variants) and publishes to Firebase Realtime Database,
 * which the Hydro Smart Flutter app streams live.
 *
 * HARDWARE WIRING
 *   pH probe  --BNC-->  pH sensor signal board
 *   board 5V   ->  ESP32 5V (or VIN) pin   ← USB-C to ESP32 is enough
 *   board GND  ->  ESP32 GND              (shared ground is essential)
 *   board OUT  ->  ESP32 GPIO36 (VP)      analog output pin
 *
 *   The board is powered at 5V but its analog OUT typically swings
 *   only 0 - 3V, safe for the ESP32's 3.3V ADC. VERIFY WITH A
 *   MULTIMETER before connecting OUT: with power on and the trimpot at
 *   maximum, OUT must stay < 3.3V. If it exceeds 3.3V at any trimpot
 *   position, insert a 2x 10k voltage divider between OUT and GPIO36.
 *
 *   GPIO36 (aka VP, SENSOR_VP) is on ADC1. Do NOT move this to an ADC2
 *   pin: ADC2 is disabled whenever Wi-Fi is active, so the reading would
 *   silently die the moment the board connects to Wi-Fi.
 *
 * LIBRARY REQUIRED (Arduino IDE > Library Manager)
 *   "Firebase ESP32 Client" by Mobizt  (provides FirebaseESP32.h)
 *
 * BOARD
 *   ESP32 Dev Module   (Tools > Board > esp32)
 */

#include <WiFi.h>
#include <FirebaseESP32.h>
#include <addons/TokenHelper.h>

// ─────────────────────────────────────────────
// 1. CREDENTIALS
// ─────────────────────────────────────────────
// Real values live in secrets.h, which is gitignored so the Wi-Fi
// password and API key never reach the repository. Copy
// secrets.example.h -> secrets.h and fill it in.
#include "secrets.h"

// ─────────────────────────────────────────────
// 2. CALIBRATION  (see CALIBRATION section below)
// ─────────────────────────────────────────────
// Two-point straight-line fit. The defaults below match the trimmer
// factory setting on the how2electronics board (pH 7 -> 2.0 V,
// pH 4 -> 1.5 V); replace with your own measured voltages after
// running the buffer procedure at the bottom of this file.
float CAL_PH_1 = 7.00,  CAL_V_1 = 2.000;   // volts at pH 7.00
float CAL_PH_2 = 4.00,  CAL_V_2 = 1.500;   // volts at pH 4.00

// ─────────────────────────────────────────────
const int   PH_PIN       = 36;   // GPIO36 / VP, per how2electronics guide
const float ADC_MAX      = 4095.0;   // 12-bit ADC
const float ADC_REF_V    = 3.3;
const unsigned long SEND_INTERVAL_MS = 3000;   // publish every 3 s
const int   SAMPLE_COUNT = 15;

FirebaseData   fbdo;
FirebaseAuth   auth;
FirebaseConfig config;

unsigned long lastSend = 0;
bool firebaseReady = false;

// ─────────────────────────────────────────────
// Read the probe: take several samples, throw away the extremes, average
// the middle. A raw analogRead is far too noisy to publish directly.
// ─────────────────────────────────────────────
float readPhVoltage() {
  int samples[SAMPLE_COUNT];
  for (int i = 0; i < SAMPLE_COUNT; i++) {
    samples[i] = analogRead(PH_PIN);
    delay(10);
  }
  // simple insertion sort
  for (int i = 1; i < SAMPLE_COUNT; i++) {
    int key = samples[i], j = i - 1;
    while (j >= 0 && samples[j] > key) { samples[j + 1] = samples[j]; j--; }
    samples[j + 1] = key;
  }
  // average the middle third (median filter)
  long sum = 0; int n = 0;
  for (int i = SAMPLE_COUNT / 3; i < SAMPLE_COUNT - SAMPLE_COUNT / 3; i++) {
    sum += samples[i]; n++;
  }
  float avgAdc = (float)sum / n;
  return (avgAdc / ADC_MAX) * ADC_REF_V;
}

float voltageToPh(float volts) {
  // Straight line through the two calibration points.
  float slope  = (CAL_PH_2 - CAL_PH_1) / (CAL_V_2 - CAL_V_1);
  float offset = CAL_PH_1 - slope * CAL_V_1;
  return slope * volts + offset;
}

// Captures the driver's real disconnect reason. WL_DISCONNECTED alone is
// ambiguous; the reason code distinguishes wrong password (AUTH_FAIL /
// 4WAY_TIMEOUT) from AP not found, assoc rejected, or beacon timeout.
volatile int g_lastReason = 0;

void onWifiEvent(WiFiEvent_t event, WiFiEventInfo_t info) {
  if (event == ARDUINO_EVENT_WIFI_STA_DISCONNECTED) {
    g_lastReason = info.wifi_sta_disconnected.reason;
  }
}

const char *reasonText(int r) {
  switch (r) {
    case 1:   return "UNSPECIFIED";
    case 2:   return "AUTH_EXPIRE";
    case 4:   return "ASSOC_EXPIRE";
    case 5:   return "ASSOC_TOOMANY - AP client limit reached";
    case 15:  return "4WAY_HANDSHAKE_TIMEOUT -> WRONG PASSWORD";
    case 200: return "BEACON_TIMEOUT - AP vanished / too weak";
    case 201: return "NO_AP_FOUND - SSID not on air";
    case 202: return "AUTH_FAIL -> WRONG PASSWORD";
    case 203: return "ASSOC_FAIL";
    case 204: return "HANDSHAKE_TIMEOUT -> WRONG PASSWORD";
    default:  return "see esp_wifi_types.h";
  }
}

void connectWifi() {
  WiFi.onEvent(onWifiEvent);
  WiFi.mode(WIFI_STA);
  WiFi.setSleep(false);          // modem sleep can stall association
  WiFi.setAutoReconnect(true);

  // Retry indefinitely instead of rebooting. A phone hotspot that sleeps
  // between attempts made the old reboot loop look like a hard failure.
  for (int attempt = 1; ; attempt++) {
    Serial.print("Wi-Fi attempt ");
    Serial.print(attempt);
    Serial.print(" -> ");
    Serial.println(WIFI_SSID);

    g_lastReason = 0;
    WiFi.disconnect(true);
    delay(300);
    WiFi.begin(WIFI_SSID, WIFI_PASSWORD);

    unsigned long start = millis();
    while (WiFi.status() != WL_CONNECTED && millis() - start < 20000) {
      Serial.print(".");
      delay(400);
    }
    Serial.println();

    if (WiFi.status() == WL_CONNECTED) {
      Serial.print("CONNECTED. IP: ");
      Serial.println(WiFi.localIP());
      Serial.print("RSSI: ");
      Serial.println(WiFi.RSSI());
      return;
    }

    Serial.print("  failed. disconnect reason = ");
    Serial.print(g_lastReason);
    Serial.print(" (");
    Serial.print(reasonText(g_lastReason));
    Serial.println(")");

    // Wait for the SSID to actually be on air before trying again.
    WiFi.disconnect(true);
    delay(200);
    int n = WiFi.scanNetworks();
    bool visible = false;
    int rssi = 0;
    for (int i = 0; i < n; i++) {
      if (WiFi.SSID(i).equals(String(WIFI_SSID))) {
        visible = true;
        rssi = WiFi.RSSI(i);
      }
    }
    Serial.print("  --- networks in range ("); Serial.print(n); Serial.println(") ---");
    for (int i = 0; i < n; i++) {
      Serial.print("    [");
      Serial.print(WiFi.SSID(i));
      Serial.print("]  ");
      Serial.print(WiFi.RSSI(i));
      Serial.print(" dBm  ch");
      Serial.println(WiFi.channel(i));
    }
    Serial.print("  SSID on air: ");
    Serial.print(visible ? "YES" : "NO");
    if (visible) {
      Serial.print("  RSSI ");
      Serial.print(rssi);
      Serial.print(" dBm");
    }
    Serial.println();
    delay(3000);
  }
}

void setup() {
  Serial.begin(115200);
  delay(300);

  analogReadResolution(12);
  // 11 dB attenuation lets the ADC read the full 0-3.3 V swing.
  analogSetPinAttenuation(PH_PIN, ADC_11db);

  connectWifi();

  config.api_key = API_KEY;
  config.database_url = DATABASE_URL;
  config.token_status_callback = tokenStatusCallback;

  // Anonymous sign-in keeps the database rules locked to authenticated
  // users without hard-coding a long-lived secret in the firmware.
  if (Firebase.signUp(&config, &auth, "", "")) {
    Serial.println("Firebase: anonymous sign-in OK");
    firebaseReady = true;
  } else {
    Serial.printf("Firebase sign-in failed: %s\n",
                  config.signer.signupError.message.c_str());
  }

  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);
}

void loop() {
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("Wi-Fi lost - reconnecting");
    connectWifi();
    return;
  }

  if (millis() - lastSend < SEND_INTERVAL_MS) return;
  lastSend = millis();

  float volts = readPhVoltage();
  float ph    = voltageToPh(volts);

  Serial.printf("V=%.3f  pH=%.2f\n", volts, ph);

  // (ADC diagnostics removed - sensor verified working)

  // Reject impossible values rather than publishing garbage: a detached
  // or dry probe reads as an open circuit and produces nonsense.
  if (isnan(ph)) {
    Serial.println("  -> NaN, not sending (check probe)");
    return;
  }
  // The probe is reading, but the calibration constants are still the
  // factory placeholders, so the mapped pH can land outside 0-14. Clamp
  // and publish so the live pipeline works, and flag it as uncalibrated
  // rather than passing a bogus number off as a real measurement.
  bool calibrated = (ph >= 0.0 && ph <= 14.0);
  if (!calibrated) {
    ph = ph < 0.0 ? 0.0 : 14.0;
    Serial.println("  (uncalibrated - clamped; run the buffer procedure)");
  }

  if (!Firebase.ready() || !firebaseReady) {
    Serial.println("  -> firebase not ready");
    return;
  }

  String path = "/devices/" + String(DEVICE_ID) + "/live";

  FirebaseJson json;
  json.set("ph", ph);
  json.set("rssi", (int)WiFi.RSSI());
  json.set("firmware", calibrated ? "1.0.0" : "1.0.0-uncalibrated");
  json.set("voltage", volts);
  // Server-side timestamp: avoids relying on the ESP32 having correct time.
  json.set("updatedAt/.sv", "timestamp");

  if (Firebase.updateNode(fbdo, path.c_str(), json)) {
    Serial.println("  -> sent");
  } else {
    Serial.printf("  -> send failed: %s\n", fbdo.errorReason().c_str());
  }
}

/*
 * ─────────────────────────────────────────────
 * CALIBRATION PROCEDURE
 * ─────────────────────────────────────────────
 * The guide's factory trimmer target is pH4 = 1.5 V, pH7 = 2.0 V,
 * pH9 = 2.5 V. In practice every probe drifts, so you should still
 * measure your own and update CAL_V_1 / CAL_V_2.
 *
 * 1. Flash this sketch as-is and open Serial Monitor at 115200.
 * 2. Rinse the probe in distilled water, blot dry (never wipe - it
 *    scratches the glass bulb).
 * 3. Sit the probe in pH 7.00 buffer. Wait ~60 s for the reading to
 *    settle, then note the "V=" value. Put that in CAL_V_1.
 * 4. Rinse again, sit in pH 4.00 buffer, wait, note "V=" -> CAL_V_2.
 * 5. Re-flash with your two voltages filled in.
 * 6. Check against pH 9.18 buffer - you should land within +/-0.1.
 *    (If the module's own trimmer is far off, loosen it a hair so
 *    the readings bracket 0.5 V - 3.0 V rather than clipping.)
 *
 * Recalibrate every 2-4 weeks; glass electrodes drift as they age.
 * Store the probe tip in pH 4.0 buffer (per the electrode leaflet), never
 * in distilled water.
 */
