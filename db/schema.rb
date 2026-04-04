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

ActiveRecord::Schema[7.1].define(version: 2026_03_27_121000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "abonnements", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "client_id", null: false
    t.uuid "salle_id", null: false
    t.date "start_date", null: false
    t.date "end_date", null: false
    t.string "status", default: "actif", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "groupe_id"
    t.index ["client_id"], name: "index_abonnements_on_client_id"
    t.index ["end_date"], name: "index_abonnements_on_end_date"
    t.index ["groupe_id"], name: "index_abonnements_on_groupe_id"
    t.index ["salle_id"], name: "index_abonnements_on_salle_id"
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
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

  create_table "categories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_categories_on_name", unique: true
  end

  create_table "clients", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.uuid "salle_id", null: false
    t.string "phone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["salle_id"], name: "index_clients_on_salle_id"
    t.index ["user_id"], name: "index_clients_on_user_id"
  end

  create_table "coachs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.uuid "salle_id", null: false
    t.string "speciality"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["salle_id"], name: "index_coachs_on_salle_id"
    t.index ["user_id"], name: "index_coachs_on_user_id"
  end

  create_table "groupe_clients", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "groupe_id", null: false
    t.uuid "client_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_groupe_clients_on_client_id"
    t.index ["groupe_id", "client_id"], name: "index_groupe_clients_on_groupe_id_and_client_id", unique: true
    t.index ["groupe_id"], name: "index_groupe_clients_on_groupe_id"
  end

  create_table "groupes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.integer "monthly_fee_cents", default: 0, null: false
    t.integer "annual_insurance_cents", default: 0, null: false
    t.uuid "coach_id", null: false
    t.uuid "salle_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["coach_id"], name: "index_groupes_on_coach_id"
    t.index ["salle_id"], name: "index_groupes_on_salle_id"
  end

  create_table "paiements", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "client_id", null: false
    t.uuid "groupe_id", null: false
    t.uuid "salle_id", null: false
    t.string "payment_type", null: false
    t.integer "amount_cents", null: false
    t.date "paid_on", null: false
    t.string "status", default: "paid", null: false
    t.string "reference"
    t.text "note"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.uuid "abonnement_id"
    t.index ["abonnement_id"], name: "index_paiements_on_abonnement_id"
    t.index ["client_id", "groupe_id", "payment_type", "paid_on"], name: "index_paiements_uniqueness_scope"
    t.index ["client_id"], name: "index_paiements_on_client_id"
    t.index ["groupe_id"], name: "index_paiements_on_groupe_id"
    t.index ["paid_on"], name: "index_paiements_on_paid_on"
    t.index ["salle_id"], name: "index_paiements_on_salle_id"
  end

  create_table "salles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name", null: false
    t.text "address"
    t.uuid "admin_id", null: false
    t.uuid "categorie_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["admin_id"], name: "index_salles_on_admin_id"
    t.index ["categorie_id"], name: "index_salles_on_categorie_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email", default: ""
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.string "firstname"
    t.string "lastname"
    t.string "address"
    t.float "latitude"
    t.float "longitude"
    t.date "birthday"
    t.integer "gender", default: 0
    t.integer "civil_status", default: 0
    t.boolean "is_archived", default: false
    t.integer "order", default: 1
    t.string "type"
    t.integer "plan", default: 0
    t.string "language", default: "fr"
    t.string "jti", default: "", null: false
    t.string "phone_number"
    t.boolean "default_admin", default: false
    t.string "country"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "provider"
    t.string "uid"
    t.string "role"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["provider", "uid"], name: "index_users_on_provider_and_uid", unique: true, where: "((provider IS NOT NULL) AND (uid IS NOT NULL))"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role"], name: "index_users_on_role"
  end

  add_foreign_key "abonnements", "clients"
  add_foreign_key "abonnements", "groupes"
  add_foreign_key "abonnements", "salles"
  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "clients", "salles"
  add_foreign_key "clients", "users"
  add_foreign_key "coachs", "salles"
  add_foreign_key "coachs", "users"
  add_foreign_key "groupe_clients", "clients"
  add_foreign_key "groupe_clients", "groupes"
  add_foreign_key "groupes", "coachs"
  add_foreign_key "groupes", "salles"
  add_foreign_key "paiements", "abonnements"
  add_foreign_key "paiements", "clients"
  add_foreign_key "paiements", "groupes"
  add_foreign_key "paiements", "salles"
  add_foreign_key "salles", "categories", column: "categorie_id"
  add_foreign_key "salles", "users", column: "admin_id"
end
