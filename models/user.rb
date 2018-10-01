# coding: utf-8
ActiveRecord::Base.configurations = YAML.load_file('./database.yml')
ActiveRecord::Base.establish_connection(:development)

class User < ActiveRecord::Base
  has_many :creations, dependent: :destroy
  has_many :kanjis, through: :creations

  validates :name, :email, presence: true
  validates :name, :email, length: {in: 3..20}
  validates :password, length: {in: 8..20}

  # :passwordと:password_confirmation, それらのpresence(存在確認), validation(2つが同じかどうかの確認)がすべて自動で追加される.
  has_secure_password
end
