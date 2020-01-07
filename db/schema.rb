# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_01_06_225502) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "projects", force: :cascade do |t|
    t.string "slug", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "transcriptions", force: :cascade do |t|
    t.integer "workflow_id", null: false
    t.string "group_id", null: false
    t.jsonb "text", null: false
    t.integer "status", null: false
    t.boolean "flagged", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "updated_by"
    t.integer "total_lines"
    t.integer "total_pages"
    t.jsonb "metadata"
  end

  create_table "users", force: :cascade do |t|
    t.string "login"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.jsonb "roles"
    t.datetime "roles_refreshed_at"
    t.string "display_name"
    t.boolean "admin", default: false, null: false
  end

  create_table "workflows", force: :cascade do |t|
    t.integer "project_id", null: false
    t.string "display_name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

end
