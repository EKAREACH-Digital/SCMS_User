# ActiveMenuDto

Mirrors the `data` of `GET /menus/active?branch_id=&canteen_id=&date=`, the one call the student menu needs (see `docs/features/student-menu-api.md`):

```
{ date, day_of_week, branch, menu | null, canteens: [ { id, name, categories: [ { id | null, name, items: [ … ] } ] } ] }
```

Why it is shaped this way:

- **One DTO per level of the JSON** (menu → canteen → category → item). The nesting matches the backend exactly, so parsing stays obvious. The classes live in one file because they only make sense together.
- **`menu` is nullable.** `null` means nothing is published for that date, and the entity's `isPublished` turns that into the "No menu today" state. A published menu with no dishes is a different state ("Nothing scheduled"), exposed as `isEmpty`.
- **Items map to the existing `FoodItem` entity**, not a new type, so the cart, home grid and detail page work with them unchanged. `FoodItem.id` is `menu_item_id`, the id the cart, orders and `GET /menu-items/:id` use. `composition_id` is kept in the DTO only.
- **The category name becomes `FoodItem.category` and its tag**, which is how the existing screens already group and label dishes.
- **Relative image paths are resolved in `toEntity`.** `image_url` may be `/uploads/...`. The repository passes the API base URL as `imageHost`, and `Uri.resolve` keeps only the host, so `http://host:3000/api` + `/uploads/a.jpg` becomes `http://host:3000/uploads/a.jpg`. Empty strings are treated as no image.
- **`price` accepts a number or a decimal string**, like the other menu DTOs, since the backend's decimal columns can come back as strings.
