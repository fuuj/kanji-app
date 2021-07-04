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

ActiveRecord::Schema.define(version: 2018_12_09_032630) do

  create_table "answers", force: :cascade do |t|
    t.integer "creation_id"
    t.integer "correct"
    t.index ["creation_id"], name: "index_answers_on_creation_id"
  end

  create_table "creations", force: :cascade do |t|
    t.integer "user_id"
    t.integer "kanji_id"
    t.index ["kanji_id"], name: "index_creations_on_kanji_id"
    t.index ["user_id"], name: "index_creations_on_user_id"
  end

  create_table "kanjis", force: :cascade do |t|
    t.string "kanji"
  end

  create_table "readings", force: :cascade do |t|
    t.integer "kanji_id"
    t.string "reading"
    t.index ["kanji_id"], name: "index_readings_on_kanji_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.text "message"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

end
