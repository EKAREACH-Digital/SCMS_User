# BranchDto

Mirrors one item of `GET /pickup/branches?school_id=<id>`:

```json
{ "id": "…", "name": "Branch C", "school_id": "…", "is_home": false }
```

Why it is shaped this way:

- **It lives in the auth feature** because Complete Profile is where the
  student picks a branch (the `home_branch_id` sent to
  `POST /auth/complete-profile`). If the menu feature later needs a branch
  picker of its own, move it to a shared place instead of copying it.
- **`school_id` and `is_home` are nullable** in the DTO, so a leaner response
  still parses. `toEntity()` turns them into an empty string and `false`, so
  the `Branch` entity has no nulls to check.
- Only the fields the app uses are read. Anything else the backend adds is
  ignored.
