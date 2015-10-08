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

ActiveRecord::Schema.define(version: 20151005145312) do

  create_table "bookmarks", force: true do |t|
    t.integer  "user_id",       null: false
    t.string   "user_type"
    t.string   "document_id"
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "document_type"
  end

  add_index "bookmarks", ["user_id"], name: "index_bookmarks_on_user_id"

  create_table "books", force: true do |t|
    t.string   "title",      null: false
    t.string   "author",     null: false
    t.string   "publisher",  null: false
    t.string   "isbn"
    t.string   "pub_date"
    t.text     "note"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "searches", force: true do |t|
    t.text     "query_params"
    t.integer  "user_id"
    t.string   "user_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "searches", ["user_id"], name: "index_searches_on_user_id"

  create_table "suggestions", force: true do |t|
    t.integer  "user_id",    null: false
    t.integer  "book_id",    null: false
    t.integer  "status",     null: false
    t.string   "recipient",  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "suggestions", ["book_id"], name: "index_suggestions_on_book_id"
  add_index "suggestions", ["user_id"], name: "index_suggestions_on_user_id"

  create_table "users", force: true do |t|
    t.string  "user_id",                    null: false
    t.string  "password"
    t.string  "name"
    t.string  "first_name"
    t.string  "email"
    t.boolean "guest",      default: false
  end

end
