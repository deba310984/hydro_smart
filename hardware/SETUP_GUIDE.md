# ESP32 pH Sensor → Hydro Smart: Setup Guide

The app side is **done and verified**. This is what you need to do to get
live readings flowing.

---

## Your project's real values

These were read from your actual `google-services.json` — use them exactly:

| Setting | Value |
|---|---|
| Firebase project | `hydroappsmart` |
| **Realtime Database URL** | `https://hydroappsmart-default-rtdb.asia-southeast1.firebasedatabase.app` |
| Region | **asia-southeast1** (Singapore) |
| Data path | `devices/<deviceId>/live` |
| Default device id | `hydro-smart-01` |

> Your database is in **asia-southeast1**, not the US default. If you paste a
> `firebaseio.com` URL anywhere it will silently fail to connect.

---

## Step 1 — Fix the database rules (this is what's blocking you now)

The app currently shows `permission-denied`. Your rules deny reads.

Firebase Console → **Realtime Database** → **Rules**, paste this, Publish:

```json
{
  "rules": {
    "devices": {
      "$deviceId": {
        "live": {
          ".read": "auth != null",
          ".write": "auth != null"
        },
        "history": {
          ".read": "auth != null",
          ".write": "auth != null",
          ".indexOn": ["ts"]
        }
      }
    }
  }
}
```

This requires any client (app *or* ESP32) to be signed in. The firmware below
signs in anonymously, so it satisfies this.

**Also enable anonymous auth:** Console → **Authentication** → *Sign-in
method* → **Anonymous** → Enable. Without this the ESP32 cannot authenticate
and writes will be rejected.

> If you just want it working for a demo and will lock it down later, you can
> temporarily use `".read": true, ".write": true`. Understand what that means:
> anyone who learns your database URL can read and overwrite your data. Do not
> leave a submitted/public project on open rules.

---

## Step 2 — Wire the hardware

| pH module pin | ESP32 pin | Note |
|---|---|---|
| VCC | **3V3** | use 5V/VIN only if your module needs it |
| GND | **GND** | shared ground is essential |
| AO | **GPIO34** | analog output |
| DO | *not connected* | digital threshold, unused |

**GPIO34 is on ADC1 — do not move it to an ADC2 pin.** ADC2 is disabled
whenever Wi-Fi is active, so the reading would die the moment the board
connects to your network. This is the single most common wiring mistake.

---

## Step 3 — Flash the firmware

1. Arduino IDE → **Library Manager** → install
   *"Firebase Arduino Client Library for ESP8266 and ESP32"* by **Mobizt**.
2. Open `hardware/esp32_ph_sensor/esp32_ph_sensor.ino`.
3. Fill in the block at the top:
   - `WIFI_SSID` / `WIFI_PASSWORD` — must be a **2.4 GHz** network; ESP32 cannot
     see 5 GHz.
   - `API_KEY` — Console → Project settings → General → **Web API Key**.
   - `DATABASE_URL` — already set to your asia-southeast1 URL.
   - `DEVICE_ID` — must match what you type in the app.
4. Board: **ESP32 Dev Module**. Upload. Open Serial Monitor at **115200**.

You should see `V=... pH=...` every 3 seconds, then `-> sent`.

---

## Step 4 — Calibrate (do this before trusting any number)

An uncalibrated probe reports confident nonsense.

1. Flash as-is, open Serial Monitor.
2. Rinse the probe in distilled water and **blot** dry — never wipe, it
   scratches the glass bulb.
3. Sit it in **pH 6.86** buffer, wait ~60 s for the value to settle, note the
   `V=` reading → put in `CAL_V_1`.
4. Rinse, sit in **pH 4.00** buffer, wait, note `V=` → `CAL_V_2`.
5. Re-flash. Verify against **pH 9.18** buffer — expect within ±0.1.

Recalibrate every 2–4 weeks; glass electrodes drift as they age. Store the
probe in KCl storage solution, **never** in distilled water (it ruins the bulb).

---

## Step 5 — Pair in the app

Dashboard → **Live pH** card → gear icon (or **Pair** button) → enter the same
`DEVICE_ID` → **Save & Connect**.

The card shows the exact path it is listening on, so you can confirm both sides
match at a glance.

---

## What the app does with the data

The ESP32 writes to `devices/<deviceId>/live`:

```json
{
  "ph": 6.42,
  "rssi": -58,
  "firmware": "1.0.0",
  "updatedAt": 1723459815000
}
```

The app streams this over an open socket — **no polling**, so the display
updates the instant the ESP32 writes.

| Range | Status | Shown as |
|---|---|---|
| < 5.5 | Acidic | red — "add pH Up solution" |
| 5.5 – 6.5 | **Optimal** | green — ideal nutrient uptake |
| 6.5 – 7.5 | Slightly Alkaline | amber — monitor closely |
| > 7.5 | Alkaline | red — "add pH Down solution" |

The card also shows a live **online/offline dot** and freshness ("Just now",
"12s ago"). If no reading arrives for **60 seconds** the device is marked
offline — that silence is how you find out the board crashed, lost Wi-Fi, or
lost power.

`updatedAt` is written using Firebase's **server** timestamp, so freshness
stays correct even though the ESP32 has no real-time clock.

---

## Adding more sensors later

The app already parses these fields if present — just add them to the
`FirebaseJson` in the sketch and they appear automatically, no app change:

`temperature` · `humidity` · `ec` · `waterLevel`

Suggested pins (all ADC1 or digital, keeping ADC2 free for Wi-Fi):

| Sensor | Pin | Interface |
|---|---|---|
| EC / TDS | GPIO35 | analog |
| DS18B20 water temp | GPIO4 | 1-Wire |
| DHT22 air temp/humidity | GPIO15 | digital |
| Water level | GPIO32 | analog |
| Relay (pump) | GPIO26 | digital out |

---

## Troubleshooting

| Symptom | Cause |
|---|---|
| `permission-denied` in app | Rules not published, or Anonymous auth not enabled (**Step 1**) |
| Card stuck "offline" | Device id mismatch, or ESP32 not sending — check Serial Monitor |
| ESP32 won't join Wi-Fi | Network is 5 GHz; ESP32 needs 2.4 GHz |
| pH jumps around wildly | No shared ground between module and ESP32 |
| Reading pinned at 0 or 14 | Probe not in liquid, or BNC not seated |
| Value drifts over weeks | Normal — recalibrate |
| Worked, then died after Wi-Fi connect | Sensor moved to an ADC2 pin |
