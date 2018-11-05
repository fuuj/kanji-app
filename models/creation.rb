class Creation < ActiveRecord::Base
  belongs_to :user
  belongs_to :kanji
end
