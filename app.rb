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

  post '/record' do
    answer = Answer.new(
      creation_id: params[:creation],
      correct: params[:ox]
      )
      answer.save!
    redirect '/user/mytest'
  end

  get '/management' do
    erb :management
  end

  delete '/management/delUser' do
    User.destroy(params[:id])
    redirect '/management'
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
      # wrong_readingsとanswer_readingを結合。final_answers[3]がanswer_reading
      final_readings = three_wrong_readings.push(answer_reading)
      # 文字列の配列にする
      final_readings = final_readings.map {|item| item.reading}
      # final_readingsをシャッフルする。final_shuffleを上書きするので、answer_readingはどこにいるかわからない。
      final_readings.shuffle!
      # answer_readingの場所を特定する。
      for num in 0..3
        if final_readings[num] == answer_reading.reading then
          answer_reading_place = num
        end
      end
      # ユーザーの回答をDBにインサートするためにはcreationが必要. ゲストならnilにしてインサートは行わない.
      creation = current_user ? current_user.creations.where(kanji_id:quiz_kanji.id).first : nil
      # [String, Array<String>, Integer, Creation]
      [quiz_kanji.kanji, final_readings, answer_reading_place, creation]
    end

    def reading_quiz()
      # ユーザークイズはユーザーが保存した漢字から問題を作る. ゲストクイズならすべての漢字から作る.
      kanjis = current_user ? current_user.kanjis : Kanji.all
      # kanjisから漢字を1つランダムに取る、それをクイズの回答とする
      answer_kanji = kanjis.sample
      # その漢字の読みを1つランダムに取る
      quiz_reading = answer_kanji.readings.sample
      # 間違った漢字を3つ取る
      three_wrong_kanjis = Reading.where.not(reading: answer_kanji).sample(3)
      while(three_wrong_kanjis.any? {|kanji| kanji.reading == quiz_reading})
        three_wrong_kanjis = Reading.where.not(reading: answer_kanji).sample(3)
      end
      wrong_kanjis = three_wrong_kanjis.map {|item| item.kanji.kanji }
      # 正解・不正解4つのKanjiをシャッフルする
      final_kanjis = wrong_kanjis.push(answer_kanji.kanji)
      final_kanjis.shuffle!
      # answer_readingの場所を特定する。
      for num in 0..3
        if final_kanjis[num] == answer_kanji.kanji
          answer_kanji_place = num
        end
      end
      # ユーザーの回答をDBにインサートするためにはcreationが必要. ゲストならnilにしてインサートは行わない.
      creation = current_user ? current_user.creations.where(kanji_id:answer_kanji.id).first : nil
      # [String, Array<String>, Integer, Creation]
      [quiz_reading.reading, final_kanjis, answer_kanji_place, creation]
    end
  end # helpers end

  run!
end # Class end


