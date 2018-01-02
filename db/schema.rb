# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20171230163308) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "days", id: :serial, force: :cascade do |t|
    t.date "date"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "lists", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "list_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "recurring_tasks", id: :serial, force: :cascade do |t|
    t.integer "day"
    t.string "description", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tags", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tags_tasks", id: false, force: :cascade do |t|
    t.integer "task_id", null: false
    t.integer "tag_id", null: false
    t.index ["task_id"], name: "index_tags_tasks_on_task_id"
  end

  create_table "tasks", id: :serial, force: :cascade do |t|
    t.date "date"
    t.text "description"
    t.boolean "done"
    t.boolean "deleted"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "day_id"
    t.integer "list_id"
    t.index ["day_id"], name: "index_tasks_on_day_id"
    t.index ["list_id"], name: "index_tasks_on_list_id"
  end

  add_foreign_key "tasks", "lists"
end
