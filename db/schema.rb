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

ActiveRecord::Schema.define(version: 20130512202551) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "beers", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "availability"
    t.string   "glassware"
    t.boolean  "organic"
    t.float    "abv"
    t.integer  "ibu"
    t.float    "original_gravity"
    t.float    "serving_temperature"
    t.string   "slug"
    t.string   "brewerydb_id",        limit: 6
    t.string   "image_id",            limit: 6
    t.integer  "style_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "beers", ["brewerydb_id"], name: "index_beers_on_brewerydb_id", unique: true, using: :btree
  add_index "beers", ["organic"], name: "index_beers_on_organic", using: :btree
  add_index "beers", ["slug"], name: "index_beers_on_slug", unique: true, using: :btree
  add_index "beers", ["style_id"], name: "index_beers_on_style_id", using: :btree

  create_table "beers_breweries", id: false, force: true do |t|
    t.integer "beer_id",    null: false
    t.integer "brewery_id", null: false
  end

  add_index "beers_breweries", ["beer_id", "brewery_id"], name: "index_beers_breweries_on_beer_id_and_brewery_id", unique: true, using: :btree

  create_table "beers_ingredients", id: false, force: true do |t|
    t.integer "beer_id",       null: false
    t.integer "ingredient_id", null: false
  end

  add_index "beers_ingredients", ["beer_id", "ingredient_id"], name: "index_beers_ingredients_on_beer_id_and_ingredient_id", unique: true, using: :btree

  create_table "breweries", force: true do |t|
    t.string   "name"
    t.string   "alternate_names",           array: true
    t.text     "description"
    t.string   "website"
    t.boolean  "organic"
    t.integer  "established"
    t.string   "slug"
    t.string   "image_id",        limit: 6
    t.string   "brewerydb_id",    limit: 6
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "breweries", ["brewerydb_id"], name: "index_breweries_on_brewerydb_id", unique: true, using: :btree
  add_index "breweries", ["slug"], name: "index_breweries_on_slug", unique: true, using: :btree

  create_table "ingredients", force: true do |t|
    t.string   "name"
    t.string   "category"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "locations", force: true do |t|
    t.string   "name"
    t.string   "category"
    t.boolean  "primary"
    t.boolean  "in_planning"
    t.boolean  "public"
    t.boolean  "closed"
    t.string   "street"
    t.string   "street2"
    t.string   "city"
    t.string   "region"
    t.string   "postal_code"
    t.string   "country"
    t.float    "latitude"
    t.float    "longitude"
    t.text     "hours"
    t.string   "website"
    t.string   "phone"
    t.integer  "brewery_id"
    t.string   "brewerydb_id", limit: 6
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "locations", ["brewery_id"], name: "index_locations_on_brewery_id", using: :btree
  add_index "locations", ["brewerydb_id"], name: "index_locations_on_brewerydb_id", unique: true, using: :btree

  create_table "styles", force: true do |t|
    t.string   "name"
    t.string   "category"
    t.text     "description"
    t.float    "min_abv"
    t.float    "max_abv"
    t.integer  "min_ibu"
    t.integer  "max_ibu"
    t.integer  "min_original_gravity"
    t.integer  "max_original_gravity"
    t.integer  "min_final_gravity"
    t.integer  "max_final_gravity"
    t.string   "slug"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "styles", ["category"], name: "index_styles_on_category", using: :btree
  add_index "styles", ["slug"], name: "index_styles_on_slug", unique: true, using: :btree

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
