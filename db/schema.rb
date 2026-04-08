# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2026_04_07_141000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.string "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "attendances", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "training_group_id", null: false
    t.date "date", null: false
    t.string "status", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "client_id"
    t.index ["training_group_id"], name: "index_attendances_on_training_group_id"
  end

  create_table "documents", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "gym_id", null: false
    t.uuid "created_by_id"
    t.string "title", null: false
    t.string "kind", default: "other", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_documents_on_created_by_id"
    t.index ["gym_id"], name: "index_documents_on_gym_id"
    t.index ["kind"], name: "index_documents_on_kind"
    t.index ["title"], name: "index_documents_on_title"
  end

  create_table "group_memberships", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "training_group_id", null: false
    t.datetime "joined_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "client_id"
  end

  create_table "gyms", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.string "address"
    t.uuid "admin_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "currency", default: "TND", null: false
    t.boolean "notifications_enabled", default: true, null: false
    t.decimal "latitude", precision: 10, scale: 6
    t.decimal "longitude", precision: 10, scale: 6
    t.index ["admin_id"], name: "index_gyms_on_admin_id", unique: true
    t.index ["name"], name: "index_gyms_on_name"
  end

  create_table "payment_receipts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "payment_id", null: false
    t.uuid "generated_by_id", null: false
    t.datetime "generated_at", null: false
    t.jsonb "details_snapshot", default: {}, null: false
    t.text "client_signature_data"
    t.text "gym_signature_data", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["payment_id"], name: "index_payment_receipts_on_payment_id", unique: true
  end

  create_table "payments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "created_by_id"
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.date "starts_on", null: false
    t.integer "duration_months", default: 1, null: false
    t.string "status", default: "pending", null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "client_id"
    t.index ["created_by_id"], name: "index_payments_on_created_by_id"
    t.index ["starts_on"], name: "index_payments_on_starts_on"
  end

  create_table "planning_sessions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "training_group_id", null: false
    t.datetime "start_time", null: false
    t.datetime "end_time", null: false
    t.string "recurrence"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["start_time"], name: "index_planning_sessions_on_start_time"
    t.index ["training_group_id"], name: "index_planning_sessions_on_training_group_id"
  end

  create_table "training_groups", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.uuid "gym_id", null: false
    t.integer "capacity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "coach_id"
    t.index ["gym_id", "name"], name: "index_training_groups_on_gym_id_and_name", unique: true
    t.index ["gym_id"], name: "index_training_groups_on_gym_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.integer "failed_attempts", default: 0, null: false
    t.string "unlock_token"
    t.datetime "locked_at"
    t.string "full_name", null: false
    t.string "phone_number"
    t.string "role", default: "client", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "gym_id"
    t.boolean "is_enabled", default: true, null: false
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["gym_id"], name: "index_users_on_gym_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role"], name: "index_users_on_role"
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "attendances", "training_groups"
  add_foreign_key "attendances", "users", column: "client_id"
  add_foreign_key "documents", "gyms"
  add_foreign_key "documents", "users", column: "created_by_id"
  add_foreign_key "group_memberships", "training_groups"
  add_foreign_key "group_memberships", "users", column: "client_id"
  add_foreign_key "gyms", "users", column: "admin_id"
  add_foreign_key "payment_receipts", "payments"
  add_foreign_key "payment_receipts", "users", column: "generated_by_id"
  add_foreign_key "payments", "users", column: "client_id"
  add_foreign_key "payments", "users", column: "created_by_id"
  add_foreign_key "planning_sessions", "training_groups"
  add_foreign_key "training_groups", "gyms"
  add_foreign_key "training_groups", "users", column: "coach_id"
  add_foreign_key "users", "gyms"
end
