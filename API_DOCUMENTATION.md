# Gooty API ドキュメント

## ベースURL

```
http://localhost:3002
```

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

### 2. Demo Shops

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

### 3. Stardusts

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
- 現在、認証機能は実装されていません

