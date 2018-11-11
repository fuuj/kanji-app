class Kanji < ActiveRecord::Base
  has_many :readings
  has_many :users, through: :creations
end
