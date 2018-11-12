
# どのmodelにも必要な3行をこのファイルにまとめた. app.rbではこのファイルをrequireするだけで済む.
require 'active_record'
ActiveRecord::Base.configurations = YAML.load_file('./database.yml')
ActiveRecord::Base.establish_connection(:development)

require_relative 'user'
require_relative 'kanji'
require_relative 'reading'
require_relative 'creation'
require_relative 'answer'
