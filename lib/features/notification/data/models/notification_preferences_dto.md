# NotificationPreferencesDto

The three Settings → Notifications switches.

Why it is shaped this way:

- **The backend has no preferences resource of its own.** The flags are
  columns on the `User` record (`notify_order_updates`, `notify_promotions`,
  `notify_system_alerts`). Both `GET /users/me` and
  `PATCH /users/:id/notification-preferences` return the whole user, so the
  DTO reads them with `fromUserJson` instead of an ordinary `fromJson`.
- **It belongs to the notification feature, not auth.** Auth's
  `UserProfileDto` ignores these fields, so the signed-in `User` stays about
  identity and onboarding only. The notification datasource reads the user
  JSON itself and takes just these flags.
- **Missing fields fall back to the backend column defaults**
  (order updates on, promotions off, system alerts on), so a leaner response
  still parses.
