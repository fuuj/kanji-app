# kanji-app
授業内制作物

## 何をすると何が起こるのか
You did | Happens
------- | -------
ターミナルで`bundle exec ruby app.rb` | Gemfileに従ってapp.rbを実行, Sinatra Controller(app.rb内のKanjiAppクラス)がスタンバイする
ブラウザで localhost:4567 へアクセスする | 送られて来た `GET '/'`リクエストに対してSinatra Controllerは`get '/'`をルーティングする(ブロックを実行する). その中の`erb :index`文によりviews/index.erb(とヘッダーなどが書いてあるlayout.erb)からhtmlページを作り, クライアントへ送信する
ブラウザでSign Upリンクをクリックする | 送られてきた`GET '/signup'`を上記の流れでルーティング, signupページを返す
ブラウザでフォームを入力,ボタンをクリック | 送られてきた`POST 'signup'`のparamsの内容から, ActiveRecordのメソッドを用いてデータベースにインサート(database.ymlにデータベースファイル:kanjiApp.dbが指定されていて, その中のusersテーブルがきちんと選ばれる), 同時に`user`オブジェクトを作成. その`user.id`を`session`ハッシュに登録. ログイン中であると解釈されるので, そのままmypageページに飛ばす
ブラウザでログアウトをクリック | `GET 'logout'`が送られてきたので`session`ハッシュを空にして(=ログアウト), indexページにリダイレクト

## git clone して再現するのに必要なこと
- ruby(>=1.9.3)とbundler(Gemのひとつ)
- `~/Projects`みたいな適当なディレクトリに移動して`git clone https://github.com/fuuj/kanji-app`(kanji-appリポジトリ全体がローカルにコピーされる), SSHでcloneする場合は`git clone git@github.com:fuuj/kanji-app.git`
- `bundle install --path=vendor/bundle`
- `bundle exec ruby app.rb`
- ブラウザで `localhost:4567`にアクセス

## 参考にしたサイト
- Sign up, Login/out のルーティングについて: [How To Implement Simple Authentication Without Devise](https://www.rubypigeon.com/posts/how-to-implement-simple-authentication-without-devise/)
- gitとGithub: [今日からはじめるGitHub 〜 初心者がGitをインストールして、プルリクできるようになるまでを解説](https://employment.en-japan.com/engineerhub/entry/2017/01/31/110000)
- ActiveRecordとSQLite3の扱い方: [Sinatra＋ActiveRecord＋SQLite3で，軽量なWeb-DB連携例](https://tamosblog.wordpress.com/2012/10/26/sinatra/)
