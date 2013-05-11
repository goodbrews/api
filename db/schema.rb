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

ActiveRecord::Schema.define(version: 20130511194333) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "breweries", force: true do |t|
    t.string   "name"
    t.string   "alternate_names",           array: true
    t.text     "description"
    t.string   "website"
    t.boolean  "organic"
    t.integer  "established"
    t.string   "permalink"
    t.string   "image_id",        limit: 6
    t.string   "brewerydb_id",    limit: 6
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "breweries", ["brewerydb_id"], name: "index_breweries_on_brewerydb_id", unique: true, using: :btree
  add_index "breweries", ["permalink"], name: "index_breweries_on_permalink", unique: true, using: :btree

  create_table "users", force: true do |t|
    t.string   "email",                        null: false
    t.string   "username",                     null: false
    t.string   "password_digest",              null: false
    t.string   "auth_token",                   null: false
    t.string   "password_reset_token"
    t.datetime "password_reset_token_sent_at"
    t.string   "name"
    t.string   "city"
    t.string   "region"
    t.string   "country"
    t.float    "latitude"
    t.float    "longitude"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["auth_token"], name: "index_users_on_auth_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["password_reset_token"], name: "index_users_on_password_reset_token", unique: true, using: :btree
  add_index "users", ["username"], name: "index_users_on_username", unique: true, using: :btree

end
