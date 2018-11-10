ActiveRecord::Base.configurations = YAML.load_file('./database.yml')
ActiveRecord::Base.establish_connection(:development)

class Answer < ActiveRecord::Base
  belongs_to :creation
end