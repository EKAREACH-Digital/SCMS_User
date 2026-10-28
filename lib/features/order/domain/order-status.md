# Order status in the app

_Written: 2026-10-28 11:10 (UTC+7)_

How the app reads an order's status and what the student sees for each one.

## Statuses

The backend sends a status string. The data layer turns it into the
`OrderStatus` enum (`orderStatusFromBackend` in `order_dto.dart`).

| Backend | `OrderStatus` | History tab | Badge | QR on Order Detail |
|---|---|---|---|---|
| `pending_payment` | `pendingPayment` | Pending Payment | orange | No: "appears once the order is paid" |
| `paid`, `preparing` | `paid` | Processing | yellow | No: "your food is being prepared" |
| `ready` | `ready` | Ready | blue | **Yes**, with Download |
| `completed` | `completed` | Completed | green | No: "already picked up, QR not available" |
| `cancelled` | `cancelled` | All only | red | No: "this order was cancelled" |

- `preparing` is merged into `paid`: for the student both mean "still cooking".
- Any unknown value becomes `pendingPayment`, the safest guess because it never shows a QR.

## The pickup QR token

- It is only returned by `GET /pickup/my/{orderId}`. `GET /orders/my` doesn't include it.
- The backend issues it at `paid` and returns it while the order is `paid`,
  `preparing` or `ready`. For `pending_payment`, `completed` and `cancelled` it is `null`.
- **The app shows the QR only at `ready`**, even though the token exists from
  `paid`. Before that the food is still cooking, so there is nothing to collect.

## Where the logic lives

- `OrderHistoryViewModel.ordersWith(status)`: the orders for each History tab.
- `OrderDetailViewModel.qrState(listStatus)`: picks the QR area's state
  (`PickupQrState`). It combines the pickup endpoint's status with the History
  list's status:
  - a `completed` or `cancelled` from either one wins;
  - otherwise the pickup endpoint's status is used, because it was fetched
    when the page opened.
- `OrderStatusStyle` (`order_status_style.dart`): label and color only. The
  tabs and the badges use it, so they always match.

## Open questions for the backend

- Is the token the same from `paid` to `ready`, or is a new one issued at `ready`?
- What does `GET /pickup/my/{orderId}` return for an unpaid or cancelled
  order: a `null` token, or an error?
- Order Detail doesn't refresh itself. The realtime `order.changed` event
  (`change: "ready"`) could update the QR while the page is open.
