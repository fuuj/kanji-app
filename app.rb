# coding:utf-8

# Gemfileのgemをrequireする
require 'bundler/setup'
Bundler.require
# init.rbに書かれているmodelsをrequireする.
require_relative 'models/init'

class KanjiApp < Sinatra::Base
  # Sinatra起動中にこのファイルに加えた変更がリアルタイムに反映されるのでとっても楽.
  register Sinatra::Reloader
  # いくつかのページへのアクセスでユーザー以外を弾く仕組みに使った.
  register Sinatra::Namespace
  # sessionというハッシュ(JavaでいうHashMap)を有効化する. これはCookieを表しているのだと思う. ここにユーザーのIDを保存したりする.
  enable :sessions

  get '/' do
    erb :index
  end

  get '/login' do
    erb :login
  end

  post '/login' do
    # ログインページから送られてきたメアドとパスワードはparamsハッシュに入っている. これらが正しい組み合わせならこのユーザーをログイン状態とし(すなわちsessionハッシュにuser.idを加えること), マイページへ飛ばす.
    user = User.find_by(email: params[:email])
    if user && user.authenticate(params[:password])
      session.clear
      session[:user_id] = user.id
      redirect '/user/mypage'
    else
      @error = 'メールアドレスとパスワードの組み合わせが正しくありません.'
      erb :login
    end
  end

  get '/signup' do
    erb :signup
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
      session[:user_id] = user.id
      redirect '/user/mypage'
    else
      @error = user.errors.full_messages
      erb :signup
    end
  end

  get '/logout' do
    session.clear
    redirect '/'
  end

  namespace '/user' do
    # このnamespace内のアクションはユーザー様以外お断り
    before { redirect '/' unless current_user }

    get '/mypage' do
      erb :mypage
    end

    post '/kanji_register' do
      kanji = Kanji.find_by(kanji: params[:kanji])
      if not kanji
        # 漢字がDBになければエラーメッセージを返す
        @error = ['その漢字は登録できません']
      elsif not current_user.kanjis.exists?(id: kanji.id)
        # ドリルに漢字を登録する
        creation = current_user.creations.create(kanji_id: kanji.id)
        if creation.save
          @message= '「' + kanji.kanji + '」を登録しました.'
        else
          @error = creation.errors.full_messages
        end
      end
      redirect '/mypage'
    end

    get '/mydrill' do
      erb :mydrill
    end

    get '/mytest' do
      erb :mytest
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

    def kanji_quiz()
      # ユーザークイズはユーザーが保存した漢字から問題を作る. ゲストクイズならすべての漢字から作る.
      kanjis = current_user ? current_user.kanjis : Kanji.all
      # kanjisから漢字を1つランダムに取る
      quiz_kanji = kanjis.sample
      # その漢字の読みを1つランダムに取る
      answer_reading = quiz_kanji.readings.sample
      # 間違った読みを3つ取る
      three_wrong_readings = Reading.where.not(reading: quiz_kanji.readings).sample(3)
      # e.g. ["亜", "ア", ["スウ", "ソ", "たわむ-れる"]]
      [quiz_kanji.kanji, answer_reading.reading, three_wrong_readings.map {|reading| reading.reading}]
    end
  end

  get '/management' do
    erb :management
  end

  delete '/management/delUser' do
    User.destroy(params[:id])
    redirect '/management'
  end

  # Users.all.sampleなどをコンソールで使ってみたいとき, 下の文のコメントを外してbundle exec ruby app.rbする.
  # binding.pry
  run!
end

