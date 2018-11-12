class Reading < ActiveRecord::Base
  # (id, kanji_id, reading)
  belongs_to :kanji
end
