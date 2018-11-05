# kanji-app
授業内制作物

## 何をすると何が起こるのか
You did | Happens
------- | -------
ターミナルで`bundle exec ruby app.rb` | app.rbを実行, Sinatra Controller(app.rb内のKanjiAppクラス)はHTTPリクエストを待ち受ける
ブラウザで localhost:4567 へアクセスする | 送られて来た `GET '/'`リクエストに対してSinatra Controllerは`get '/'`をルーティングする(ブロックを実行する). その中の`erb :index`文によりviews/index.erb(とヘッダーなどが書いてあるlayout.erb)からhtmlページを作り, クライアントへ送信する
ブラウザでSign Upリンクをクリックする | 送られてきた`GET '/signup'`を上記の流れでルーティング, signupページを返す
ブラウザでフォームを入力,ボタンをクリック | 送られてきた`POST 'signup'`のparamsの内容から, ActiveRecordのメソッドを用いてデータベースにインサート(database.ymlにデータベースファイル:kanjiApp.dbが指定されていて, その中のusersテーブルがきちんと選ばれる), 同時に`user`オブジェクトを作成. その`user.id`を`session`ハッシュに登録. ログイン中であると解釈されるので, そのままmypageページに飛ばす
ブラウザでログアウトをクリック | `GET 'logout'`が送られてきたので`session`ハッシュを空にして(=ログアウト), indexページにリダイレクト


## git clone してアプリを起動するのに必要なこと
自前のLinuxの場合, RubyやSQLite3がインストールされている必要があります. 多分どちらも最新でOK. 他にもインストールを要求されるかもしれません. Windowsは自分で頑張ってみてください.
```
# kanji-appリポジトリがローカルにコピーされる. 別にホームディレクトリ(~)に置かなくてもいいですが, その場合は以降のコマンドを読み替えてください
cd ~
git clone https://github.com/fuuj/kanji-app
cd kanji-app

# ここで分岐:
# (a) AV室のUbuntuの場合: チームMLのOneDriveから, localAppsフォルダとkanjiApp.dbを ~/kanji-app にコピーする
# bundle install の際, localAppsの中のsqlite3を使うように設定する
bundle config --local build.sqlite3 --with-sqlite3-dir=$HOME/kanji-app/localApps --with-sqlite3-include=$HOME/kanji-app/localApps --with-sqlite3-lib=$HOME/kanji-app/localApps/lib/

# (b) 自前のLinuxの場合: チームMLのOneDriveから, kanjiApp.dbだけを ~/kanji-app にコピーする

# vendor/bundle以下にgemをインストールする
bundle install --path=vendor/bundle
# アプリを起動する
bundle exec ruby app.rb
# ブラウザで"localhost:4567"にアクセスする
```

## 参考にしたサイト
- Sign up, Login/out のルーティングについて: [How To Implement Simple Authentication Without Devise](https://www.rubypigeon.com/posts/how-to-implement-simple-authentication-without-devise/)
- gitとGithub: [今日からはじめるGitHub 〜 初心者がGitをインストールして、プルリクできるようになるまでを解説](https://employment.en-japan.com/engineerhub/entry/2017/01/31/110000)
- ActiveRecordとSQLite3の扱い方: [Sinatra＋ActiveRecord＋SQLite3で，軽量なWeb-DB連携例](https://tamosblog.wordpress.com/2012/10/26/sinatra/)
