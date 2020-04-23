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

ActiveRecord::Schema.define(version: 2020_04_23_025501) do

  create_table "users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.string "uuid", null: false
    t.string "email", null: false
    t.string "username", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "password"
    t.string "password_digest"
    t.string "color_hex", default: "000000", null: false
    t.string "type"
    t.boolean "active", default: false, null: false
    t.boolean "blocked", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
    t.index ["uuid", "color_hex"], name: "index_users_on_uuid_and_color_hex", unique: true
    t.index ["uuid"], name: "index_users_on_uuid", unique: true
  end

  create_table "users_sessions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "user_type", null: false
    t.string "token", null: false
    t.string "rotation_token"
    t.boolean "is_not_deleted", default: true, null: false
    t.datetime "deleted_on"
    t.datetime "expires_on", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["is_not_deleted", "token"], name: "index_users_sessions_on_is_not_deleted_and_token"
    t.index ["token"], name: "index_users_sessions_on_token", unique: true
    t.index ["user_id", "token"], name: "index_users_sessions_on_user_id_and_token"
  end

end
