# pickup_checkin_dto — POST /pickup/arrive response

## Why this shape

The `POST /pickup/arrive` response wraps its payload in a `data` envelope:

```json
{
  "statusCode": 200,
  "data": {
    "counter": "Counter 1",
    "checked_in_at": "2026-10-28T06:09:32.453Z",
    "orders": [...]
  }
}
```

The remote datasource unwraps `response.data['data']` before passing the inner
object to `PickupCheckinDto.fromJson`.

## Three DTO classes, one file

All three classes live here because they only make sense together and are never
used independently outside this file.

- **`PickupCheckinDto`** — the `data` object
- **`PickupOrderDto`** — one element of `orders`
- **`PickupOrderItemDto`** — one element of an order's `items`

## checkedInAt as String

The DTO keeps `checkedInAt` as a raw ISO-8601 string. `DateTime.parse` runs
in `toEntity()`, so the DTO layer never interprets it — consistent with how
other DTOs in this project handle timestamps.

## Status mapping

`PickupOrderDto.toEntity()` reuses `orderStatusFromBackend()` from
`order_dto.dart`. This keeps the `paid` / `preparing` → `OrderStatus.paid`
collapsing in one place rather than duplicating it here.

## Items reuse OrderItem

`PickupOrderItemDto.toEntity()` returns an `OrderItem` (from the order
feature). The pickup counter items have no prices or images, so `unitPrice`
and `imageUrl` are null — that is valid for `OrderItem`.
