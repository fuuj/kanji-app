class Kanji < ActiveRecord::Base
  # (id, kanji)
  has_many :readings
  has_many :creations
end
