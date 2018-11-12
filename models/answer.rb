class Answer < ActiveRecord::Base
  # (id, creation_id, correct: integer)
  belongs_to :creation
end