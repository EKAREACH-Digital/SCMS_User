# OrderPickupDto

Mirrors the `data` of `GET /pickup/my/{orderId}`:

```json
{
  "order_id": "9ded0ba7-…",
  "status": "ready",
  "pickup_no": 2,
  "pickup_qr_token": "8Xvcrt3_z-q_nKdj7ZIdqFnipZikEu1U",
  "branch_id": "487d98b0-…",
  "items": [{ "name": "បាយស្រូប", "quantity": 1 }],
  "pickup_slot_start": null,
  "ready_at": "2026-10-28T02:54:32.224Z",
  "checked_in_at": null,
  "handed_over_at": null
}
```

Why it is shaped this way:

- **It is its own DTO, not part of `OrderSummaryDto`.** The pickup QR token
  is only returned by this endpoint; `GET /orders/my` and `GET /orders/{id}`
  don't carry it. Order Detail calls both: the history list for prices and
  date, this endpoint for the QR.
- **`pickup_qr_token` and `pickup_no` are nullable**, so a ticket that hasn't
  been issued yet still parses and the page shows a "not paid yet" message
  instead of a QR.
- **No prices or dates.** The payload carries none, so the Order Detail page
  takes those from the history list the user tapped through from.
- `branch_id` and the pickup timestamps are not read: nothing in the app
  shows them yet.
