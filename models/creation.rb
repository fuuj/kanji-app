class Creation < ActiveRecord::Base
  # (id, user_id, kanji_id)
  belongs_to :user
  belongs_to :kanji
  has_many :answers
end
