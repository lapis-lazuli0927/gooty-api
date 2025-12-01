## shop一覧取得
- ショップの一覧を返すAPI

## エンドポイント
- GET "/shops"

## レスポンス
```json
// 成功時
200 OK
{
    data:[
        {
            "id": int, 
            "name": string,
            "station_name": string,
            "review": int,
            "is_ai_generated": boolean,
            "is_instagram": boolean,
            "created_at": Datetime
        },
        {},・・・
    ],
    success : boolean
}

// 失敗時
404 notfound
{
    "msg": string,
    "success": boolean
}
```

## レスポンスサンプル
```json
// 成功時
200 OK
{
    data:[
        {
            "id": 1, 
            "name": "switch",
            "station_name": "武蔵小金井駅",
            "review": 4,
            "is_ai_generated": true,
            "is_instagram": true,
            "created_at": "2025-01-15T10:30:00.000Z"
        },
        {},・・・
    ],
    success : true
}

// 失敗時
404 notfound
{
    "msg": "投稿が見つかりませんでした。",
    "success": false
}
```


## shop詳細取得
- ショップの詳細を返すAPI

## エンドポイント
- GET "/shops/:id"

## レスポンス
```json
// 成功時
200 OK
{
    data:
    {
        "id": int, 
        "name": string,
        "station_name": string,
        "address": string,
        "tel": string,
        "memo": text,
        "review": int,
        "is_instagram": boolean,
    },
    success : boolean
}

// 失敗時
404 notfound
{
    "msg": string,
    "success": boolean
}
```

## レスポンスサンプル
```json
// 成功時
200 OK
{
    data:
    {
        "id": 1, 
        "name": "switch",
        "station_name": "武蔵小金井駅",
        "address": "東京都小金井市本町5-18-15",
        "tel": 042-201-1478,
        "memo": "ワインが美味しいお店です。",
        "review": 4,
        "is_instagram": true,
    }
    success : true
}

// 失敗時
404 notfound
{
    "msg": "投稿が見つかりませんでした。",
    "success": false
}
```


## shop新規登録
- ショップの新規登録を保存するAPI

## エンドポイント
- POST "/shops/:id"

## レスポンス
```json
// 成功時
200 OK
{
    data:
    {
        "id": int, 
        "name": string,
        "station_name": string,
        "address": string,
        "tel": string,
        "memo": text,
        "review": int,
    },
    success : boolean
}

// 失敗時
400 badrequest
{
    "code": "VALIDATION_FAILED",
    "msg": string,
    "success": boolean
}
```

## レスポンスサンプル
```json
// 成功時
200 OK
{
    data:
    {
        "id": 1, 
        "name": "switch",
        "station_name": "武蔵小金井駅",
        "address": "東京都小金井市本町5-18-15",
        "tel": 042-201-1478,
        "memo": "ワインが美味しいお店です。",
        "review": 4,
    },
    success : true
}

// 失敗時
400 badrequest
{
    "code": "VALIDATION_FAILED",
    "msg": "必須項目が入力されていません。",
    "success": false
}
```