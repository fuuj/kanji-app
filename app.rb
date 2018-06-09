# coding:utf-8
require 'active_record'
require 'sinatra/base'
require 'sinatra/reloader'
require 'bcrypt'
require 'pry'
 
ActiveRecord::Base.configurations = YAML.load_file('database.yml')
ActiveRecord::Base.establish_connection(:development)

class User < ActiveRecord::Base
  validates :name, :email, :password, :password_confirmation, presence: true
  validates :name, :email, length: {in: 3..20}
  validates :password, length: {in: 8..20}
  has_secure_password
end
class Kanji < ActiveRecord::Base
end
class Creation < ActiveRecord::Base
end

def hash_password(password)
  BCrypt::Password.create(password).to_s
end

def test_password(password, hash)
  BCrypt::Password.new(hash) == password
end

class KanjiApp < Sinatra::Base
  enable :sessions

  get '/' do
    if current_user
      erb :mypage
    else
      erb :index
    end
  end

  get '/login' do
    if current_user
      erb :mypage
    else
      erb :login
    end
  end

  post '/login' do
    user = User.find_by(email: params[:email])
    # binding.pry
    if user && user.authenticate(params[:password])
      session.clear
      session[:user_id] = user.id
      redirect '/mypage'
    else
      @error = 'email or password was incorrect'
      erb :login
    end
  end

  get '/signup' do
    if current_user
      erb :mypage
    else
      erb :signup
    end
  end

  post '/signup' do
    user = User.new(
        id: nil,
        name: params[:name],
        email: params[:email],
        password: params[:password], #password_hash
        password_confirmation: params[:password_confirmation] 
      )
    if user.save
      # セッションに追加する(ログイン状態になる)
      session.clear
      session[:user_id] = user.id
      redirect '/mypage'
    else
      @error = user.errors.full_messages
      erb :signup
    end
  end

  post '/logout' do
    session.clear
    redirect '/'
  end

  get '/mypage' do
    if current_user
      erb :mypage
    else
      redirect '/'
    end
  end

  helpers do
    def current_user
      if session[:user_id]
        User.find(session[:user_id])
      else
        nil
      end
    end
  end


  get '/management' do
    @users = User.all
    @kanjis = Kanji.all
    @creations = Creation.all
    erb :management
  end

  delete '/management/delUser' do
    User.destroy(params[:id])
    redirect '/management'
  end

  run!
end

