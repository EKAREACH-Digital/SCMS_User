# AuthSessionDto

Mirrors the `data` of `POST /auth/login`, `POST /auth/google` and
`POST /auth/complete-profile`. All three return the same shape:

```json
{ "access_token", "refresh_token", "expires_in", "user": { … }, "mustChangePassword"? }
```

Why it is shaped this way:

- **One DTO for every sign-in response.** It replaces the old `AuthTokenDto` and
  `CompleteProfileResponseDto`. The user comes back in the body, so the
  repository no longer makes a second `GET /users/me` call after signing in.
- **`user` reuses `UserProfileDto`**, which already handles the auth-response
  shape (school flattened to a name string, id in `school_id`).
- **`mustChangePassword` is camelCase on the backend** and present only for
  temporary-password accounts, so it defaults to `false`. It isn't a profile
  field, so `toEntity()` copies it onto the `User` instead of storing it in
  `UserProfileDto`.
- **`expires_in` defaults to 900** (the backend's 15 minutes), so a response
  without it still parses.
- The tokens never leave the data layer. The repository stores them through
  `StorageService` and passes only the `User` upward.
