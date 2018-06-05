# coding:utf-8
require 'active_record'
require 'sinatra/base'
require 'sinatra/reloader'
require 'bcrypt'
 
ActiveRecord::Base.configurations = YAML.load_file('database.yml')
ActiveRecord::Base.establish_connection(:development)

class User < ActiveRecord::Base
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

class Application < Sinatra::Base
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
    if user && test_password(params[:password], user.password)
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
    user = User.create(
      id: nil,
      name: params[:name],
      email: params[:email],
      password: hash_password(params[:password]) #password_hash
    )
    session.clear
    session[:user_id] = user.id
    redirect '/mypage'
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

