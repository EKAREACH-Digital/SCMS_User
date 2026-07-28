# Task: Implement ABA PayWay wallet top-up (NestJS backend + Flutter app)

## Context
This is the Smart Canteen Management System (SCMS). Users top up a digital wallet by
paying through ABA. The backend is **NestJS + TypeORM + PostgreSQL**. The end-user app is
**Flutter**. Payments go through **ABA PayWay** (Cambodia's payment gateway).

The gateway integration has already been verified in sandbox — credentials and the HMAC
hashing work. Your job is to build the real top-up feature end to end, cleanly integrated
into the existing codebase (do not create a throwaway script).

**Security rule (non-negotiable):** the PayWay `api_key` is a secret and must live ONLY in
the backend `.env`. The Flutter app must never contain PayWay credentials or call PayWay
directly — it only ever calls our own backend.

---

## Environment variables (backend `.env`)
Assume these already exist; read them via `ConfigService`, never hard-code:
```
PAYWAY_BASE_HOST=https://checkout-sandbox.payway.com.kh   # host only, no path
PAYWAY_MERCHANT_ID=<merchant id>
PAYWAY_API_KEY=<the HMAC secret / "public key" value>
PAYWAY_CALLBACK_URL=                                       # empty in local dev; set in prod
```

---

## PayWay technical facts (use these exactly — do not change ordering)

**Hashing:** every request includes a `hash` = HMAC-SHA512 of concatenated fields, keyed by
`PAYWAY_API_KEY`, base64-encoded. Field order must match exactly or PayWay rejects it.

**`req_time` format:** `YYYYMMDDHHmmss` (UTC).

**Endpoint 1 — Generate QR** (create a transaction, get QR + deeplink):
`POST {HOST}/api/payment-gateway/v1/payments/generate-qr`
Hash concatenation order:
`req_time + merchant_id + tran_id + amount + items + first_name + last_name + email + phone + purchase_type + payment_option + callback_url + return_deeplink + currency + custom_fields + return_params + payout + lifetime + qr_image_template`
- `amount`: string, 2 decimals, e.g. `"5.00"`
- `items`: base64 of a JSON array, e.g. `[{"name":"Wallet Top-up","quantity":1,"price":5.00}]`
- `callback_url`: base64 of the URL (empty string if `PAYWAY_CALLBACK_URL` is blank)
- `payment_option`: `"abapay_khqr"`
- `purchase_type`: `"purchase"`
- `currency`: `"USD"`
- `lifetime`: `15` (minutes)
- `qr_image_template`: `"template3_color"`
- Success response: `status.code === "0"`, and returns `qrImage` (data:image/png;base64),
  `qrString`, and `abapay_deeplink` (`abamobilebank://...`).

**Endpoint 2 — Check transaction** (has the user paid yet?):
`POST {HOST}/api/payment-gateway/v1/payments/check-transaction-2`
Hash concatenation order: `req_time + merchant_id + tran_id`
- Response contains a payment status; treat `"APPROVED"` as paid.

**Callback (pushback) format** — PayWay POSTs this to `PAYWAY_CALLBACK_URL` on success:
`{ "tran_id": "...", "apv": 123456, "status": "0", "merchant_ref_no": "..." }`
- `status === "0"` means success.

**Constraints:** `tran_id` must be unique and ≤ 20 characters.

---

## Confirmation strategy (important)
There are two ways to learn a payment succeeded:
1. **Callback** — PayWay POSTs to our `callback_url`. Only works when the backend is
   publicly reachable (production). In local dev PayWay cannot reach localhost/Docker.
2. **Polling** — the Flutter app polls our `/status/:tranId` endpoint, which calls
   check-transaction-2. Works in local dev.

Implement **both**. Polling is the primary path for now; the callback is wired up and ready
for production. Crediting the wallet must be **idempotent** — one payment credits exactly
once, even if both the callback and a poll report success.

---

## Backend tasks (NestJS)

1. **Create a `payments` module** with:
   - `PaywayService` — wraps the two PayWay endpoints above (`generateTopupQr`,
     `checkTransaction`). Reads credentials from `ConfigService`. Uses Node's built-in
     `crypto` for HMAC and native `fetch`.
   - `PaymentsController` with routes under `/api/payments`:
     - `POST /topup` — body `{ amount: number, userId: string }`. Generates a unique
       `tran_id`, looks up the user's real name/email/phone from the DB, calls
       `generateTopupQr`, inserts a **PENDING** `Transaction` row, returns
       `{ tranId, qrImage, qrString, abapayDeeplink }`.
     - `GET /status/:tranId` — if already PAID, return PAID. Otherwise call
       `checkTransaction`; if APPROVED, mark the transaction PAID, credit the wallet
       (idempotent), return PAID; else return PENDING.
     - `POST /callback` — verify/handle the pushback; if `status === "0"` and not already
       PAID, mark PAID and credit the wallet (idempotent). Always respond 200 so PayWay
       stops retrying.

2. **TypeORM entities** (PostgreSQL):
   - `Transaction`: `id`, `tranId` (unique, indexed), `userId` (FK to user), `amount`,
     `currency`, `status` (`PENDING | PAID | FAILED`), `provider` (`'PAYWAY'`),
     timestamps. Use `tranId` as the idempotency key.
   - `WalletTransaction`: `id`, `userId`, `amount` (signed; positive for top-up),
     `type` (`TOPUP | PURCHASE | ...`), `balanceAfter`, `sourceTranId`, `createdAt`.
   - Crediting the wallet = within a DB transaction: increment the user's wallet balance
     and insert a `WalletTransaction`. Guard against double-credit by checking the
     `Transaction.status` transition (PENDING → PAID) atomically.

3. **Provider abstraction:** put the PayWay-specific logic behind a small interface
   (e.g. `PaymentProvider` with `generateTopupQr` / `checkTransaction`) so ACLEDA can be
   added later without touching the controller/wallet logic.

4. **Register** the payments module in `AppModule`.

---

## Flutter tasks (end-user app)

1. **Add packages** to `pubspec.yaml`: `http` and `url_launcher`. Run `flutter pub get`.

2. **`lib/services/payway_service.dart`** — HTTP client for OUR backend:
   - `startTopUp({amount, userId})` → `POST /api/payments/topup`, returns
     `{ tranId, abapayDeeplink, qrImage }`.
   - `checkStatus(tranId)` → `GET /api/payments/status/:tranId`, returns
     `'PENDING' | 'PAID' | 'NOT_FOUND'`.
   - `apiBase` is configurable. In local dev: Android emulator uses `http://10.0.2.2:3000`;
     a real device uses the Mac's LAN IP. Read this from the app's existing env/flavor
     config (the project uses `main_prod.dart` and likely other flavor entrypoints) rather
     than hard-coding.

3. **`lib/screens/topup_screen.dart`** — a `StatefulWidget`:
   - Amount input + "Pay with ABA" button.
   - On tap: call `startTopUp`, then open `abapayDeeplink` with
     `launchUrl(uri, mode: LaunchMode.externalApplication)`.
   - Show a "Waiting for payment…" state with a spinner.
   - Use `WidgetsBindingObserver` to detect app resume (user returns from ABA) and check
     status immediately; also run a `Timer.periodic` poll every 3s as a fallback.
   - On PAID: show a success view and stop polling. Cancel the timer in `dispose`.
   - Reach this screen via `Navigator.push` from the wallet page (do NOT make it the app
     home in `main_prod.dart`).

4. **iOS config:** add to `ios/Runner/Info.plist` so the deeplink can open ABA:
   ```xml
   <key>LSApplicationQueriesSchemes</key>
   <array><string>abamobilebank</string></array>
   ```

---

## Acceptance criteria
- Entering an amount in the Flutter app and tapping "Pay with ABA" opens the ABA Mobile app
  via deeplink.
- The backend records a PENDING `Transaction` and, on payment, transitions it to PAID and
  creates a `WalletTransaction`, incrementing the user's balance exactly once.
- Polling `/status/:tranId` returns PENDING before payment and PAID after.
- Re-calling `/status` or receiving a duplicate `/callback` after PAID does NOT credit the
  wallet again.
- No PayWay secrets exist anywhere in the Flutter app.
- Switching from sandbox to production is a `.env`-only change (host + credentials +
  callback URL); no code changes required.

## Out of scope
- Refunds (uses PayWay's RSA-keyed API — separate task).
- Do not remove or alter existing unrelated modules.