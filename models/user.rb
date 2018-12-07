# coding: utf-8

class User < ActiveRecord::Base
  # (id, name, email, password, message)
  has_many :creations, dependent: :destroy
  has_many :kanjis, through: :creations
  has_many :readings, through: :kanjis
  has_many :answers, through: :creations

  validates :name, :email, presence: true
  validates :name, :email, length: {in: 3..20}
  validates :password, length: {in: 8..20}

  # :passwordと:password_confirmation, それらのpresence(存在確認), validation(2つが同じかどうかの確認)がすべて自動で追加される.
  has_secure_password
end
