ActiveRecord::Base.configurations = YAML.load_file('database.yml')
ActiveRecord::Base.establish_connection(:development)

class User < ActiveRecord::Base
  has_many :creations, dependent: :destroy
  has_many :kanjis, through: :creations

  validates :name, :email, presence: true
  validates :name, :email, length: {in: 3..20}
  validates :password, length: {in: 8..20}
  # 魔術的なhas_secure_passwordにより, 属性の :password, :password_confirmation, それらのpresence, 一致のvalidationがすべて自動で追加される.
  has_secure_password
end
