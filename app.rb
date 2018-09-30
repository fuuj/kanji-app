# coding:utf-8
require 'active_record'
require 'sinatra/base'
require 'sinatra/reloader'
require 'bcrypt'
require 'pry'
require_relative 'models/user'
require_relative 'models/kanji'
require_relative 'models/reading'
require_relative 'models/creation'

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
        password: params[:password],
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

  post '/kanji/register' do
    kanji = Kanji.find_by(kanji: params[:kanji])
    if not kanji
      # 漢字がテーブルになければエラーメッセージを返す
      @error = ['その漢字は登録できません']
      erb :mypage
    elsif current_user.creations.exists?(kanji_id: kanji.id)
      # 漢字が登録済みなら何もしない
      erb :mypage
    else
      # ドリルに漢字を登録する
      creation = current_user.creations.create(kanji_id: kanji.id)
      if creation.save
        @message= '「' + kanji.kanji + '」を登録しました.'
        erb :mypage
      else
        @error = creation.errors.full_messages
        erb :mypage
      end
    end
  end

  get '/drill' do
    if current_user
      erb :drill
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

    def kanji_quiz_choices()
      # ユーザークイズはユーザーが保存した漢字から, ゲストクイズならすべての漢字から問題を作る
      kanjis = current_user ? current_user.kanjis : Kanji.all
      # kanjisから漢字を1つランダムに取る
      quiz_kanji = kanjis.sample
      correct_readings = quiz_kanji.readings.pluck(:reading)
      # その漢字の読みを1つランダムに取る
      answer_reading = correct_readings.sample
      # 間違った読みを3つ取る
      three_wrong_readings = Reading.where.not(reading: correct_readings).pluck(:reading).sample(3)
      # e.g. ["亜", "ア", ["スウ", "ソ", "たわむ-れる"]]
      [quiz_kanji.kanji, answer_reading, three_wrong_readings]
    end
  end


  get '/management' do
    erb :management
  end

  delete '/management/delUser' do
    User.destroy(params[:id])
    redirect '/management'
  end

  run!
end

