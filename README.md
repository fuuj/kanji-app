# kanji-app
## できること
- サインアップ(Userテーブルの制約はまだ考えていない)
- ログイン, ログアウト
- 登録済みユーザーの確認(management.erb)
## 何をすると何が起こるのか
You did | Happens
------- | -------
ターミナルで`bundle exec ruby app.rb` | Gemfileに従ってapp.rbを実行, サーバー(Puma)とミドルウェア(Rack)とSinatra Controller(app.rb内のKanjiAppクラス)がスタンバイする
ブラウザで localhost:4567 へアクセスする | 送られて来た GET '/' リクエストに対してSinatra Controllerは get '/' をルーティングする(ブロックを実行する). `erb :index`文により`views/index.erb`(と`layout.erb`)からindexページを作ってクライアントへ送信する
ブラウザでSign Upリンクをクリックする | 送られてきた GET '/signup' を上記の流れでルーティング, signupページを返す
ブラウザでフォームを入力,ボタンをクリック | 送られてきた POST 'signup' のparamsの内容からActiveRecordの力でデータベースにインサート(database.ymlに指定したkanjiApp.db, その中のusersテーブルがきちんと選ばれる), 同時にuserオブジェクトを作成. そのidをセッションhashに登録. ログイン中であると解釈されるので, そのままmypageにリダイレクト
ブラウザでログアウトをクリック | POST 'logout' が送られてきたのでsessionハッシュを空にして(=ログアウト), indexにリダイレクト
## git clone して再現するのに必要なこと
- ruby(rbenvを使った), bundler 環境が整っている
`> ruby -v
ruby 2.4.1p111 (2017-03-22 revision 58053) [x86_64-linux]
> bundle -v
Bundler version 1.16.2`
- `~/Projects`みたいな適当なディレクトリに移動
- `git clone https://github.com/fuuj/kanji-app/tree/signup`でsignupディレクトリと中身をダウンロード
- `bundle exec ruby app.rb`
- ブラウザで `localhost:4567`にアクセス
## 参考にしたサイト
- Sign up, Login/out のルーティングについて:
[How To Implement Simple Authentication Without Devise](https://www.rubypigeon.com/posts/how-to-implement-simple-authentication-without-devise/)
- ActiveRecordとSQLite3の扱い方:
[Sinatra＋ActiveRecord＋SQLite3で，軽量なWeb-DB連携例](https://tamosblog.wordpress.com/2012/10/26/sinatra/)
