# Sansan Mobile 1Day インターン アプリ (iOS)
このアプリはモバイル1Dayインターン用です
## 開発環境
以下の環境で開発しています｡ 特にXcodeバージョンについてはmacOSとの互換性によりXcode14.3以降での検証ができていないため､以下のバージョンを推奨します｡
- Xcodeバージョン: 14.2

特定バージョンのXcodeをインストールする方法としては､Apple Developerの公式ページからダウンロードする方法と､OSSかアプリケーションからダウンロードする方法があります｡
### Apple Developerからダウンロードする
- 以下のページから､`コマンドラインツールおよびXcodeの旧バージョン` に飛び任意のバージョンのXcodeをダウンロードできます
- <https://developer.apple.com/jp/xcode/resources/>

### OSSアプリケーションを利用する
- 以下のアプリケーションをダウンロードしアプリケーション内にてAppleIDでログインすることで､任意のバージョンのXcodeをダウンロードできます
- <https://github.com/XcodesOrg/XcodesApp>

## 動作環境
このアプリを実行できる最低OSバージョンは以下となっています｡
- deployment target: iOS 15.0

## 事前準備
1. ライブラリインストール
   1. bundlerをインストールする
   ```
   bundle install
   ```
   2. podからライブラリをインストールする
   ```
   bundle exec pod install
   ```
2. `Sansan-Mobile-Internship.xcworkspace` からプロジェクトを開く
3. アプリのビルドが成功する事を確認する
 - ここでエラーが出てしまい個人で対処できかった場合はメンターに共有お願いします

## このアプリについて
**名刺画像をOCRした後に名刺要素を抽出し名刺として保存するアプリです**
### 画面
- 名刺一覧画面 (HomeList)
  - 端末内に保存されている名刺を読み込み一覧として表示する
  - タップされた名刺の詳細画面への遷移を行う
- 名刺撮影画面 (Camera)
  - 端末のカメラを利用して画像を撮影する
  - プレビュー内の青枠線にそって撮影した画像をトリミングする
- 名刺詳細画面 (BizCardDetail)
  - 画面として3つのモードがある
    - 名刺作成
      - 画面の引数として名刺画像を受け取った後､OCRを行い名刺情報の作成を行う
    - 名刺編集
      - 既に端末内にある名刺情報を編集し再保存する
    - 名刺詳細
      - 既に端末内にある名刺情報を表示する

## アーキテクチャ
**MVVMをベースにClean Architectureを参考にしたものになっています**
- [MVVM+CreanArchtecture](https://github.com/kudoleh/iOS-Clean-Architecture-MVVM)

<img src="./ReadmeAssets/mvvmr.png" width="800px">

### Router
- Moduleの初期化を行い､ViewModelに依存物を渡す
- ViewModelから画面遷移の命令が来たら､別のModuleのRouterを初期化し遷移を行う
### ViewModel
- Viewからのイベントに応じてプレゼンテーションロジックを実行し､Viewの状態を変更する
- 必要に応じてUseCaseやAPIを用いてデータの取得を行う
- Routerを所持することで､プレゼンテーションロジックによる処理後に画面遷移を行うことが可能
### View (Controller)
- 画面のレイアウトを行う
- 状態に応じて変化する要素はViewModelに従う
### UseCase
- プレゼンテーションロジック以外のビジネスロジックの実装を行う
- データの変換処理や､データ取得処理等
### Entity
- アプリ内で共通のデータモデル
- APIからのレスポンス等もここでDecodableに準拠したモデルにする
### Repository
- アプリ内で複数のモジュールで必要なデータや永続化が必要なデータを保持する
- データの永続化にはRealm, CoreData, SQLite, UserDefaults等を用いる方法が一般的です
### API
- 外部のAPIサーバーと通信を行う｡
- 本プロジェクトではAPIKitというライブラリを利用しており､DataLayer部分の処理をライブラリ内で行っている｡ そのためAPIの利用箇所がDomainLayerとなり、アプリのコード内ではViewModelから直接APIクラスを利用している
