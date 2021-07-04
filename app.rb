# coding:utf-8

# Gemfileのgemをrequireする
require 'bundler/setup'
Bundler.require

ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'] || :development)

require './models/user'
require './models/kanji'
require './models/reading'
require './models/creation'
require './models/answer'

require 'sinatra/json'

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
        name: params[:email],
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

  get '/quiz' do
    locals = { n: params[:n].to_i, isTest: params[:isTest] == 'true' }
    erb :quiz, layout: nil, locals: locals
  end

  get '/management' do
    erb :management
  end

  post '/delUser' do
    User.destroy(params[:id])
    redirect '/management'
  end

  namespace '/user' do
    # このnamespace内のアクションはユーザー様以外お断り
    before { redirect '/' unless current_user }

    get '/enquete' do
      erb :enquete
    end

    post '/enquete' do
      current_user.update_attribute('message', params.to_s)
    end

    get '/mypage' do
      erb :mypage
    end

    post '/add_kanji' do
      puts('params:', params)
      cannot_add = ''
      added = ''
      not_added = ''
      params[:kanji].each_char do |c|
        # cが漢字のとき
        if c =~ /\p{Han}/
          kanji = Kanji.find_by(kanji: c)
          # 漢字がkanjisにないとき
          if not kanji
            cannot_add += c + ' '
          # 漢字をユーザーが未登録のとき
          elsif not current_user.kanjis.exists?(id: kanji.id)
            creation = current_user.creations.create(kanji_id: kanji.id)
            if creation.save
              added += kanji.kanji + ' '
            else
              not_added += kanji.kanji + ' '
            end
          # 登録済みのとき
          else
            not_added += kanji.kanji + ' '
          end
        end
      end
      data = {
        cannot_add: cannot_add,
        added: added,
        not_added: not_added
      }
      json data
    end

    get '/mydrill' do
      erb :mydrill
    end

    get '/mytest' do
      erb :mytest
    end

    post '/record' do
      answer = Answer.new(
        creation_id: params[:creation_id],
        correct: params[:ox]
      )
      answer.save!
      creation = Creation.find(params[:creation_id])
      data = {
        kanji_accuracy: kanji_accuracy(creation),
        total_accuracy: total_accuracy(creation)
      }
      json data
    end
  end # namespace end

  helpers do
    def current_user
      if session[:user_id]
        User.find(session[:user_id])
      else
        nil
      end
    end

    def user_kanjis()
      kanjis = []
      current_user.creations.each do |c| #current_userの持つ漢字全てに以下の条件で試す.
        i = 0
        acc = kanji_accuracy(c)
        if acc <= 0.50 then #正答率0~50%
          #出題するクイズを持ってくる入れ物の中に8回入れる
          while i < 8 do
            kanjis.push(c.kanji)
            i = i + 1
          end
        else #正答率50%~
          #出題するクイズを持ってくる入れ物の中に1回入れる
          kanjis.push(c.kanji)
        end
      end
      return kanjis
    end

    def has_kanjis()
      current_user ? current_user.kanjis.length > 0 : false
    end

    def kanji_quiz(kanjis)
      # kanjisから漢字を1つランダムに取る
      quiz_kanji_record = kanjis.sample
      # その漢字の読みを1つランダムに取る
      answer_reading = quiz_kanji_record.readings.sample.reading
      # 選択肢(読み)の配列
      final_readings = [answer_reading]
      # 間違いの選択肢を作る
      loop do
        reading = Reading.all.sample.reading
        final_readings.append(reading) unless final_readings.include?(reading)
        break if final_readings.length == 4
      end
      # final_readingsをシャッフルする。final_shuffleを上書きするので、answer_readingはどこにいるかわからない。
      final_readings.shuffle!
      # answer_readingの場所を特定する。
      for num in 0..3
        if final_readings[num] == answer_reading then
          answer_reading_place = num
        end
      end
      # ユーザーの回答をDBにインサートするためにはcreationが必要. ゲストならnilにしてインサートは行わない.
      creation = current_user ? current_user.creations.where(kanji_id: quiz_kanji_record.id).first : nil
      # [String, Array<String>, Integer, Creation]
      [quiz_kanji_record.kanji, final_readings, answer_reading_place, creation]
    end

    def reading_quiz(kanjis)
      # kanjisから漢字を1つランダムに取る、それをクイズの回答とする
      answer_kanji_record = kanjis.sample
      # その漢字の読みを1つランダムに取る
      quiz_reading_record = answer_kanji_record.readings.sample
      # 選択肢の配列
      final_kanjis = [answer_kanji_record.kanji]
      # 間違った漢字を3つ取る
      loop do
        kanji_record = Kanji.all.sample
        final_kanjis.append(kanji_record.kanji) unless kanji_record.readings.include?(quiz_reading_record.reading)
        break if final_kanjis.length == 4
      end
      # 正解・不正解4つのKanjiをシャッフルする
      final_kanjis.shuffle!
      # answer_readingの場所を特定する。
      for num in 0..3
        if final_kanjis[num] == answer_kanji_record.kanji
          answer_kanji_place = num
        end
      end
      # ユーザーの回答をDBにインサートするためにはcreationが必要. ゲストならnilにしてインサートは行わない.
      creation = current_user ? current_user.creations.where(kanji_id:answer_kanji_record.id).first : nil
      # [String, Array<String>, Integer, Creation]
      [quiz_reading_record.reading, final_kanjis, answer_kanji_place, creation]
    end

    def accuracy(binaries)
      accuracy_final = binaries.length == 0 ? 0 : binaries.sum.to_f / binaries.length
      accuracy_final = accuracy_final.round(2)
      accuracy_final
    end

    def kanji_accuracy(creation)
      binaries = creation.answers.pluck(:correct)
      accuracy(binaries)
    end

    def total_accuracy(creation)
      binaries = current_user.answers.pluck(:correct)
      accuracy(binaries)
    end

  end # helpers end

  run!
end # Class end

