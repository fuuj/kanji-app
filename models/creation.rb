ActiveRecord::Base.configurations = YAML.load_file('database.yml')
ActiveRecord::Base.establish_connection(:development)

class Creation < ActiveRecord::Base
  belongs_to :user
  belongs_to :kanji
end
