# Gooty API

Rails APIアプリケーションです。

## 必要な環境

- Docker
- Docker Compose

## セットアップ

### Dockerコンテナの起動

```bash
# コンテナのビルドと起動
docker compose up --build

# バックグラウンドで起動
docker compose up -d --build
```

### データベースのセットアップ

```bash
# データベースの作成とマイグレーション実行
docker compose exec api rails db:create
docker compose exec api rails db:migrate

# シードデータの投入（必要に応じて）
docker compose exec api rails db:seed
```

## 開発作業

### Railsコンソールの起動

```bash
# Railsコンソールを起動
docker compose exec api rails console

# または短縮形
docker compose exec api rails c
```

### マイグレーションの実行

```bash
# 新しいマイグレーションファイルの生成
docker compose exec api rails generate migration CreateUsers name:string email:string

# マイグレーションの実行
docker compose exec api rails db:migrate

# マイグレーションのロールバック
docker compose exec api rails db:rollback

# 特定のステップ数だけロールバック
docker compose exec api rails db:rollback STEP=2
```

### その他の便利なコマンド

```bash
# テストの実行
docker compose exec api rails test

# ルートの確認
docker compose exec api rails routes

# ログの確認
docker compose logs api

# OpenAPIドキュメントのlint
# Spectral CLIでlint
docker compose exec api spectral lint doc/openapi.yaml

# Redocly CLIでlint
docker compose exec api redocly lint doc/openapi.yaml

# コンテナの停止
docker compose down

# ボリュームも含めて完全に削除
docker compose down -v
```

## アクセス情報

- API: http://localhost:3002
- データベース: localhost:3308 (MySQL)
  - ユーザー名: gooty
  - パスワード: password
  - データベース名: gooty_development

## APIドキュメント

詳細なAPIドキュメントは [doc/API_DOCUMENTATION.md](./doc/API_DOCUMENTATION.md) を参照してください。

OpenAPI仕様書は [doc/openapi.yaml](./doc/openapi.yaml) を参照してください。
