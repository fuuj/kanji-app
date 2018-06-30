ActiveRecord::Base.configurations = YAML.load_file('database.yml')
ActiveRecord::Base.establish_connection(:development)

class Kanji < ActiveRecord::Base
  has_many :readings
  has_many :users, through: :creations
end
