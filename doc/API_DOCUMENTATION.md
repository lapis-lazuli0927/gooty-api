# Gooty API ドキュメント

## ベースURL

```
http://localhost:3002
```

## 認証

このAPIはBearer認証とCookie認証の両方をサポートしています。

### Bearer認証

リクエストヘッダーにアクセストークンを設定します。

```bash
curl -H "Authorization: Bearer YOUR_ACCESS_TOKEN" http://localhost:3002/users
```

### Cookie認証

ログイン時に自動的に`access_token`Cookieが設定されます。以降のリクエストでは自動的に認証されます。

```bash
curl -c cookies.txt -b cookies.txt http://localhost:3002/users
```

### トークンの有効期限

アクセストークンは発行から30日間有効です。

---

## エンドポイント一覧

### 1. Health Check

#### GET /health

APIのヘルスチェックエンドポイントです。

**リクエスト例:**
```bash
curl http://localhost:3002/health
```

**レスポンス例:**
```json
{
  "status": "ok",
  "timestamp": "2024-11-20T10:00:00.000Z",
  "service": "gooty-api"
}
```

**ステータスコード:**
- `200 OK`: 正常

---

#### GET /up

Railsのヘルスチェックエンドポイントです。アプリケーションが正常に起動している場合に200を返します。

**リクエスト例:**
```bash
curl http://localhost:3002/up
```

**ステータスコード:**
- `200 OK`: 正常
- `500 Internal Server Error`: エラー

---

### 2. Auth（認証）

#### POST /signup

新規ユーザーを登録します。

**リクエスト例:**
```bash
curl -X POST http://localhost:3002/signup \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "password123",
    "name": "山田太郎"
  }'
```

**リクエストボディ:**
| パラメータ | 型 | 必須 | 説明 |
|-----------|-----|------|------|
| email | string | ○ | メールアドレス |
| password | string | ○ | パスワード（6文字以上） |
| name | string | ○ | ユーザー名 |

**レスポンス例:**
```json
{
  "data": {
    "id": 1,
    "email": "user@example.com",
    "name": "山田太郎"
  },
  "token": "abc123xyz789...",
  "success": true
}
```

**ステータスコード:**
- `201 Created`: 登録成功
- `400 Bad Request`: バリデーションエラー

---

#### POST /login

ログインしてアクセストークンを取得します。

**リクエスト例:**
```bash
curl -X POST http://localhost:3002/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "password123"
  }'
```

**リクエストボディ:**
| パラメータ | 型 | 必須 | 説明 |
|-----------|-----|------|------|
| email | string | ○ | メールアドレス |
| password | string | ○ | パスワード |

**レスポンス例:**
```json
{
  "data": {
    "id": 1,
    "email": "user@example.com",
    "name": "山田太郎"
  },
  "token": "abc123xyz789...",
  "success": true
}
```

**エラーレスポンス例:**
```json
{
  "error": "メールアドレスまたはパスワードが正しくありません",
  "success": false
}
```

**ステータスコード:**
- `200 OK`: ログイン成功
- `401 Unauthorized`: 認証失敗

---

#### DELETE /logout

ログアウトしてアクセストークンを無効化します。

**リクエスト例:**
```bash
curl -X DELETE http://localhost:3002/logout \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

**レスポンス例:**
```json
{
  "success": true
}
```

**ステータスコード:**
- `200 OK`: ログアウト成功

---

### 3. Users（ユーザー管理）

> ⚠️ 以下のエンドポイントは認証が必要です

#### GET /users

ユーザー一覧を取得します。

**リクエスト例:**
```bash
curl http://localhost:3002/users \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

**レスポンス例:**
```json
{
  "data": [
    {
      "id": 1,
      "email": "user@example.com",
      "name": "山田太郎",
      "created_at": "2026-01-16T10:00:00.000Z"
    }
  ],
  "success": true
}
```

**ステータスコード:**
- `200 OK`: 正常
- `401 Unauthorized`: 認証エラー

---

#### GET /users/:id

指定されたIDのユーザー情報を取得します。

**パラメータ:**
- `id` (integer, required): ユーザーID

**リクエスト例:**
```bash
curl http://localhost:3002/users/1 \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

**レスポンス例:**
```json
{
  "data": {
    "id": 1,
    "email": "user@example.com",
    "name": "山田太郎",
    "created_at": "2026-01-16T10:00:00.000Z"
  },
  "success": true
}
```

**エラーレスポンス例:**
```json
{
  "error": "ユーザーが見つかりません",
  "success": false
}
```

**ステータスコード:**
- `200 OK`: 正常
- `401 Unauthorized`: 認証エラー
- `404 Not Found`: ユーザーが見つからない

---

#### PUT /users/:id

指定されたIDのユーザー情報を更新します。

**パラメータ:**
- `id` (integer, required): ユーザーID

**リクエスト例:**
```bash
curl -X PUT http://localhost:3002/users/1 \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "山田花子",
    "email": "hanako@example.com"
  }'
```

**リクエストボディ:**
| パラメータ | 型 | 必須 | 説明 |
|-----------|-----|------|------|
| email | string | - | メールアドレス |
| name | string | - | ユーザー名 |
| password | string | - | パスワード（6文字以上） |

**レスポンス例:**
```json
{
  "data": {
    "id": 1,
    "email": "hanako@example.com",
    "name": "山田花子",
    "created_at": "2026-01-16T10:00:00.000Z"
  },
  "success": true
}
```

**ステータスコード:**
- `200 OK`: 更新成功
- `400 Bad Request`: バリデーションエラー
- `401 Unauthorized`: 認証エラー
- `404 Not Found`: ユーザーが見つからない

---

#### DELETE /users/:id

指定されたIDのユーザーを削除します。

**パラメータ:**
- `id` (integer, required): ユーザーID

**リクエスト例:**
```bash
curl -X DELETE http://localhost:3002/users/1 \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

**レスポンス例:**
```json
{
  "success": true
}
```

**ステータスコード:**
- `200 OK`: 削除成功
- `401 Unauthorized`: 認証エラー
- `404 Not Found`: ユーザーが見つからない

---

### 5. Demo Shops

#### GET /demo_shops

デモショップの一覧を取得します。

**リクエスト例:**
```bash
curl http://localhost:3002/demo_shops
```

**レスポンス例:**
```json
{
  "data": [
    {
      "id": 1,
      "name": "Switch",
      "type": 1,
      "station": "Shibuya Station",
      "review_level": 4.5,
      "created_at": "2024-01-15T10:00:00Z",
      "updated_at": "2024-01-15T10:00:00Z"
    },
    {
      "id": 2,
      "name": "てっかば",
      "type": 2,
      "station": "Namba Station",
      "review_level": 4.2,
      "created_at": "2024-01-20T14:30:00Z",
      "updated_at": "2024-01-20T14:30:00Z"
    }
  ]
}
```

**ステータスコード:**
- `200 OK`: 正常

---

#### GET /demo_shops/:id

指定されたIDのデモショップ情報を取得します。

**パラメータ:**
- `id` (integer, required): ショップID

**リクエスト例:**
```bash
curl http://localhost:3002/demo_shops/1
```

**レスポンス例:**
```json
{
  "data": {
    "id": 1,
    "name": "Switch",
    "type": 1,
    "station": "Shibuya Station",
    "review_level": 4.5,
    "created_at": "2024-01-15T10:00:00Z",
    "updated_at": "2024-01-15T10:00:00Z"
  }
}
```

**エラーレスポンス例:**
```json
{
  "error": "Demo shop not found"
}
```

**ステータスコード:**
- `200 OK`: 正常
- `404 Not Found`: ショップが見つからない場合

---

### 6. Stardusts

#### GET /stardusts

Stardustの一覧を取得します。

**リクエスト例:**
```bash
curl http://localhost:3002/stardusts
```

**レスポンス例:**
```json
{
  "data": [
    {
      "id": 1,
      "value": 100,
      "memo": "テストメモ",
      "created_at": "2024-11-20T10:00:00.000Z",
      "updated_at": "2024-11-20T10:00:00.000Z"
    }
  ]
}
```

**ステータスコード:**
- `200 OK`: 正常

---

#### POST /stardusts

新しいStardustを作成します。

**リクエスト例:**
```bash
curl -X POST http://localhost:3002/stardusts \
  -H "Content-Type: application/json" \
  -d '{
    "stardust": {
      "value": 100,
      "memo": "テストメモ"
    }
  }'
```

**リクエストボディ:**
```json
{
  "stardust": {
    "value": 100,
    "memo": "テストメモ"
  }
}
```

**パラメータ:**
- `value` (integer, required): 値
- `memo` (string, optional): メモ

**レスポンス例:**
```json
{
  "data": {
    "id": 1,
    "value": 100,
    "memo": "テストメモ",
    "created_at": "2024-11-20T10:00:00.000Z",
    "updated_at": "2024-11-20T10:00:00.000Z"
  }
}
```

**エラーレスポンス例:**
```json
{
  "errors": ["Value can't be blank"]
}
```

**ステータスコード:**
- `201 Created`: 作成成功
- `422 Unprocessable Entity`: バリデーションエラー

---

#### GET /stardusts/:id

指定されたIDのStardust情報を取得します。

**パラメータ:**
- `id` (integer, required): Stardust ID

**リクエスト例:**
```bash
curl http://localhost:3002/stardusts/1
```

**レスポンス例:**
```json
{
  "data": {
    "id": 1,
    "value": 100,
    "memo": "テストメモ",
    "created_at": "2024-11-20T10:00:00.000Z",
    "updated_at": "2024-11-20T10:00:00.000Z"
  }
}
```

**エラーレスポンス例:**
```json
{
  "error": "Stardust not found"
}
```

**ステータスコード:**
- `200 OK`: 正常
- `404 Not Found`: Stardustが見つからない場合

---

#### PUT /stardusts/:id
#### PATCH /stardusts/:id

指定されたIDのStardustを更新します。

**パラメータ:**
- `id` (integer, required): Stardust ID

**リクエスト例:**
```bash
curl -X PUT http://localhost:3002/stardusts/1 \
  -H "Content-Type: application/json" \
  -d '{
    "stardust": {
      "value": 200,
      "memo": "更新されたメモ"
    }
  }'
```

**リクエストボディ:**
```json
{
  "stardust": {
    "value": 200,
    "memo": "更新されたメモ"
  }
}
```

**パラメータ:**
- `value` (integer, optional): 値
- `memo` (string, optional): メモ

**レスポンス例:**
```json
{
  "data": {
    "id": 1,
    "value": 200,
    "memo": "更新されたメモ",
    "created_at": "2024-11-20T10:00:00.000Z",
    "updated_at": "2024-11-20T11:00:00.000Z"
  }
}
```

**エラーレスポンス例:**
```json
{
  "errors": ["Value can't be blank"]
}
```

**ステータスコード:**
- `200 OK`: 更新成功
- `404 Not Found`: Stardustが見つからない場合
- `422 Unprocessable Entity`: バリデーションエラー

---

#### DELETE /stardusts/:id

指定されたIDのStardustを削除します。

**パラメータ:**
- `id` (integer, required): Stardust ID

**リクエスト例:**
```bash
curl -X DELETE http://localhost:3002/stardusts/1
```

**レスポンス例:**
```json
{
  "message": "Stardust deleted successfully"
}
```

**エラーレスポンス例:**
```json
{
  "errors": ["Error message"]
}
```

**ステータスコード:**
- `200 OK`: 削除成功
- `404 Not Found`: Stardustが見つからない場合
- `422 Unprocessable Entity`: 削除エラー

---

## データモデル

### User

| フィールド | 型 | 説明 |
|----------|-----|------|
| id | integer | 主キー（自動生成） |
| email | string | メールアドレス（ユニーク） |
| password_digest | string | パスワードハッシュ |
| name | string | ユーザー名 |
| created_at | datetime | 作成日時（自動生成） |
| updated_at | datetime | 更新日時（自動生成） |

### AccessToken

| フィールド | 型 | 説明 |
|----------|-----|------|
| id | integer | 主キー（自動生成） |
| user_id | integer | ユーザーID（外部キー） |
| token | string | アクセストークン（ユニーク） |
| expires_at | datetime | 有効期限（発行から30日） |
| created_at | datetime | 作成日時（自動生成） |
| updated_at | datetime | 更新日時（自動生成） |

### Stardust

| フィールド | 型 | 説明 |
|----------|-----|------|
| id | integer | 主キー（自動生成） |
| value | integer | 値 |
| memo | string | メモ |
| created_at | datetime | 作成日時（自動生成） |
| updated_at | datetime | 更新日時（自動生成） |

### Demo Shop

| フィールド | 型 | 説明 |
|----------|-----|------|
| id | integer | 主キー |
| name | string | ショップ名 |
| type | integer | タイプ |
| station | string | 最寄り駅 |
| review_level | float | レビューレベル |
| created_at | datetime | 作成日時 |
| updated_at | datetime | 更新日時 |

### Shop

| フィールド | 型 | 説明 |
|----------|-----|------|
| id | integer | 主キー（自動生成） |
| name | string | ショップ名（必須、最大30文字） |
| url | text | URL |
| station_id | integer | 駅ID（外部キー） |
| user_id | integer | ユーザーID（外部キー、必須） |
| address | string | 住所（最大30文字） |
| tel | string | 電話番号 |
| memo | text | メモ |
| review | integer | レビュー |
| is_ai_generated | boolean | AI生成フラグ（必須） |
| is_instagram | boolean | Instagramフラグ（自動設定） |
| created_at | datetime | 作成日時（自動生成） |
| updated_at | datetime | 更新日時（自動生成） |

---

## エラーレスポンス

APIはエラー発生時に以下の形式でレスポンスを返します。

### バリデーションエラー (422)

```json
{
  "errors": [
    "Value can't be blank",
    "Memo is too long"
  ]
}
```

### リソースが見つからない場合 (404)

```json
{
  "error": "Stardust not found"
}
```

---

## 注意事項

- すべてのリクエストはJSON形式で送信してください
- Content-Typeヘッダーに`application/json`を指定してください
- 認証が必要なエンドポイントには、Bearer認証またはCookie認証が必要です
- アクセストークンの有効期限は30日間です

---

## Rakeタスク

### 既存Shopデータへのユーザー紐付け

既存のShopデータにデフォルトユーザーを紐付けるタスクです。

```bash
# デフォルト設定で実行（admin@example.com）
docker compose exec api rails shops:assign_default_user

# カスタム設定で実行
docker compose exec api rails shops:assign_default_user \
  DEFAULT_USER_EMAIL=custom@example.com \
  DEFAULT_USER_PASSWORD=custompassword \
  DEFAULT_USER_NAME="カスタムユーザー"
```

