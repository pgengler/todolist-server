# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20140801180203) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "item_tags", force: true do |t|
    t.integer "item_id",  null: false
    t.integer "tag_id",   null: false
    t.integer "position"
  end

  add_index "item_tags", ["item_id", "tag_id"], name: "index_item_tags_on_item_id_and_tag_id", unique: true, using: :btree

  create_table "items", force: true do |t|
    t.date     "date"
    t.string   "event"
    t.boolean  "done"
    t.boolean  "deleted"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tags", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
