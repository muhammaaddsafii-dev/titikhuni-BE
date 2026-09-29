# Database Schema — Titik Huni

Format: [DBML](https://dbml.dbdiagram.io/). Generated from `database/migrations/*` and `app/Models/*`.

```dbml
Table users {
  id             uuid [primary key, default: `uuid_generate_v4()`]
  full_name      varchar [not null]
  email          varchar [unique, not null]
  password       varchar [not null] // hashed
  user_type      varchar [not null, default: 'buyer'] // guest, buyer, owner, admin
  photo          text
  status         varchar [not null, default: 'active'] // active, inactive
  phone          varchar
  remember_token varchar
  created_at     timestamp
  updated_at     timestamp
}

Table lands {
  id                uuid [primary key, default: `uuid_generate_v4()`]
  name              varchar [not null]
  location          varchar [not null]
  price             bigint
  is_for_sale       boolean [not null, default: true]
  type              varchar // house, apartment, villa
  status            varchar [not null, default: 'Pending'] // Pending, Approved, Rejected, Sold, Archived
  owner_id          uuid [ref: > users.id]
  description       text
  image             text // file disimpan ke S3
  images            "text[]" // file disimpan ke S3
  floors            int
  bedrooms          int
  bathrooms         int
  electricity       int
  certificate       varchar
  certificate_image text // file disimpan ke S3
  garage            varchar
  unit_floor        int
  unit_type         varchar
  furnished         varchar // furnished, semi, unfurnished
  land_area         varchar
  building_area     varchar
  facilities        "text[]"
  views             int [not null, default: 0]
  favorites         int [not null, default: 0]
  inquiries_count   int [not null, default: 0]
  geom              geometry // PostGIS Point, SRID 4326
  rejection_reason  text
  created_at        timestamp
  updated_at        timestamp
}

Table conversations {
  id                uuid [primary key, default: `uuid_generate_v4()`]
  property_id       uuid [ref: > lands.id]
  buyer_id          uuid [ref: > users.id]
  owner_id          uuid [ref: > users.id]
  last_message      text
  last_message_time varchar
  unread_buyer      int [not null, default: 0]
  unread_owner      int [not null, default: 0]
  created_at        timestamp
  updated_at        timestamp

  indexes {
    (property_id, buyer_id, owner_id) [unique]
  }
}

Table messages {
  id              uuid [primary key, default: `uuid_generate_v4()`]
  conversation_id uuid [ref: > conversations.id]
  sender_id       uuid [ref: > users.id]
  sender_role     varchar [not null] // buyer, owner
  sender_name     varchar
  text            text [not null]
  status          varchar [not null, default: 'sent'] // sent, read
  created_at      timestamp
  updated_at      timestamp
}

Table notifications {
  id            uuid [primary key, default: `uuid_generate_v4()`]
  property_id   uuid [ref: > lands.id]
  property_name varchar
  type          varchar [not null] // submitted, approved, rejected, archived, sold
  owner_id      uuid [ref: > users.id]
  reason        text
  is_read       boolean [not null, default: false]
  created_at    timestamp
  updated_at    timestamp
}

Table favorites {
  id          uuid [primary key, default: `uuid_generate_v4()`]
  user_id     uuid [ref: > users.id]
  property_id uuid [ref: > lands.id]
  created_at  timestamp
  updated_at  timestamp

  indexes {
    (user_id, property_id) [unique]
  }
}

Table complaints {
  id          uuid [primary key, default: `uuid_generate_v4()`]
  reporter_id uuid [ref: > users.id]
  property_id uuid [ref: > lands.id]
  category    varchar [not null]
  message     text [not null]
  image       text // file disimpan ke S3
  status      varchar [not null, default: 'open'] // open, in_progress, resolved
  created_at  timestamp
  updated_at  timestamp
}

// =============================================
// Tabel hazard/bencana — hasil import shapefile (bukan Eloquent model),
// dipakai oleh LayerController & LandController::getRiskAnalysis untuk
// menampilkan overlay peta bencana dan menghitung skor risiko lokasi.
// Struktur kolom sama untuk semua tabel di bawah ini.
// =============================================

Table flood {
  gid      int [primary key]
  gridcode int // tingkat keparahan: 1 rendah, 2 sedang, >=3 tinggi
  geom     geometry // Polygon/MultiPolygon, sumber SRID 32749 (UTM 49S), tidak diset
}

Table landslide {
  gid      int [primary key]
  gridcode int
  geom     geometry // sumber SRID 32749 (UTM 49S), tidak diset
}

Table drought {
  gid      int [primary key]
  gridcode int
  geom     geometry // sumber SRID 32749 (UTM 49S), label salah sebagai 4326
}

Table eruption {
  gid      int [primary key]
  gridcode int
  geom     geometry // sumber SRID 3857 (Web Mercator), label salah sebagai 4326
}

Table liquefaction {
  gid      int [primary key]
  gridcode int
  geom     geometry // sumber SRID 32749 (UTM 49S), label salah sebagai 4326
}

Table extremeweather {
  gid      int [primary key]
  gridcode int
  geom     geometry // sumber SRID 3857 (Web Mercator), label salah sebagai 4326
}

Table earthquake {
  gid      int [primary key]
  gridcode int
  geom     geometry // sumber SRID 3857 (Web Mercator), label salah sebagai 4326
}

Table flashflood {
  gid      int [primary key]
  gridcode int
  geom     geometry // sumber SRID 32749 (UTM 49S), tidak diset
}
```

## Catatan

- Database menggunakan PostgreSQL dengan ekstensi `uuid-ossp`, `postgis`, dan `pgrouting`.
- Semua primary key tabel utama (`users`, `lands`, `conversations`, `messages`, `notifications`, `favorites`, `complaints`) berupa UUID (`uuid_generate_v4()`).
- Tabel hazard (`flood`, `landslide`, `drought`, `eruption`, `liquefaction`, `extremeweather`, `earthquake`, `flashflood`) diimpor langsung dari shapefile GIS, bukan melalui Eloquent model, dan hanya diberi index GiST pada kolom `geom` (lihat `2026_09_22_000001_add_gist_index_to_hazard_tables.php`).
- Tabel bawaan Laravel (`password_reset_tokens`, `sessions`, `cache`, `jobs`, dll.) tidak disertakan karena bukan bagian dari domain aplikasi.
