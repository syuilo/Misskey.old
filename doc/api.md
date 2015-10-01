# Misskey API
## Misskey APIとは？
* WebベースのAPI
* 簡単にMisskeyの機能を利用したアプリケーションを作れる
* 認証が必要なAPIは正しいApp KeyとUser Keyを要求する

## 使い方
1. アプリケーションを登録する(App Keyの入手)
2. SAuthで認証する(User Keyの入手)
3. APIにアクセスする(App KeyとUser Keyを使用)
3. 桶屋が儲かる

## 用語一覧
### App Key
* アプリケーションを識別するための一意なキーコード
* アプリケーションを登録時に発行される
* 他の人に教えてはならない

### User Key
* アプリケーションと連携したユーザーに値付けられたキーコード
* アプリケーションを利用するユーザーのパスワードみたいなもの
* 他の人に教えてはならない

### SAuth
* OAuthを簡略化したMisskey独自の認証方式
* App Keyとユーザーのアカウントへのアクセス許可からUser Keyを得る処理

### Session Key
* SAuthの認証フォームを開くのに必要なキーコード

### PINコード
* User Key引換券
* 直接User Keyを取得できないのはセキュリティ上の理由

## アプリケーションの登録の仕方
1. [Misskey developer center](http://dev.misskey.xyz)にアクセス
2. ページ右上のアイコンをクリックしアプリケーション管理ページへ移動
3. +アイコンをクリックし新規アプリケーション登録ページへ移動
4. フォームに必要事項を記入し登録を申請
  - Name
    - アプリケーション名
    - 投稿のviaとして表示されるやつ
    - 後から変更不可
  - ID
    - アプリケーションID
    - 一部のアプリ情報ページでURLとして表示されたりする
    - 半角英数字及びハイフンが使用可能
    - 後から変更不可
  - Description
    - アプリケーションの説明
  - Callback URL
    - 認証時のコールバックURL
    - 作るアプリケーションがWebアプリケーションでない場合は空白のままで
5. アプリケーションが無事登録されるとアプリケーション設定ページに遷移する
  - 「App key」タブでApp keyが見れる
  - 続けてアイコンの設定もできる

## SAuthの認証の仕方
1. Session keyの取得
  - `https://api.misskey.xyz/sauth/get-authentication-session-key`にGETリクエスト
    - HTTPヘッダーの`sauth-app-key`にApp Keyをセット
    - レスポンスは`{"authenticationSessionKey": string}`の形式のJSON
      - authenticationSessionKeyがSession key
2. 認証フォームを開いてユーザーにアカウントへのアクセス許可をもらいPINコードを取得
  1. 認証フォーム `https://api.misskey.xyz/authorize@(Session key)` をユーザーのブラウザで開く
    - 例えばSession Keyが`kyoppie`ならURLは`https://api.misskey.xyz/authorize@kyoppie`
    - ユーザーがアカウントへのアクセスを許可したとき
      - Webアプリケーションの場合はCallback URLに遷移
        - GETパラメータの`pin-code`にPINコードがセットされる
      - Webアプリケーションでない場合はPINコードが表示される
        - ユーザーにPINコードをアプリケーションに入力してもらう
    - ユーザーがアカウントのアクセスを拒否するとSession Keyは無効になる
3. User Keyの取得
  - `https://api.misskey.xyz/sauth/get-user-key`にGETリクエスト
    - HTTPヘッダーの`sauth-app-key`にApp Keyをセット
    - GETパラメータの`pin-code`にPINコードをセット
    - GETパラメータの`authentication-session-key`にSession Keyをセット
    - レスポンスは`{"userKey": string}`の形式のJSON

## APIのアクセスの仕方
* 各種APIの指定されたエンドポイントに指定されたHTTPメソッドでリクエスト
* 認証が必要なAPIにはHTTPヘッダに以下の情報をセット
  * `sauth-app-key` - App Key
  * `sauth-user-key` - User Key
* エンドポイントの最後に拡張子をつけるとレスポンス形式を指定できる
  * デフォルトはJSON
  * 対応している拡張子は今のところ.json(JSON)と.yaml(YAML)の２つ

## レートリミッティングシステム
* 一部のAPIにはアクセス数のリミットが設定されている
* Misskeyへの過剰な負荷を防ぐため
* アクセス可能な上限とアクセス数カウントのリセット間隔はAPI毎に定められている
