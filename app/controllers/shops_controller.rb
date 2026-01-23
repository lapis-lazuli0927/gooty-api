require 'net/http'
require 'json'

class ShopsController < ApplicationController

  def index
    sort_column = params[:sort] || "created_at"
    sort_order = params[:order] || "desc"

    allowed_columns = ["created_at", "review"]
    sort_column = "created_at" unless allowed_columns.include?(sort_column)
    
    allowed_orders = ["asc", "desc"]
    sort_order = "desc" unless allowed_orders.include?(sort_order)

    shops = Shop.order("#{sort_column} #{sort_order}")
    render json: {
      data: shops.as_json(
        except: [:updated_at, :station_id],
        methods: :station_name
        ),
      success: true
    }
  end

  def create
    # is_ai_generatedがtrueの場合はAI生成モード
    if shop_params[:is_ai_generated] == true || shop_params[:is_ai_generated] == "true"
      create_with_ai
    else
      create_manually
    end
  end

  def show
    shop = Shop.find_by(id: show_params[:id])

    unless shop
      return render json: {
        error: "ショップが見つかりません",
        success: false
      }, status: :not_found
    end

    render json: {
      data: shop.as_json(
        except: [:updated_at, :station_id, :is_ai_generated, :created_at],
        methods: :station_name
      ),
      success: true
    }
  end

  def destroy
    shop = Shop.find_by(id: delete_params[:id])

    unless shop
      return render json: {
        error: "ショップが見つかりません",
        success: false
      }, status: :not_found
    end

    shop.destroy!

    render json: { success: true }, status: :ok
  end

  def update
    shop = Shop.find_by(id: update_params[:id])

    station_name_from_input = update_params[:station_name]
    update_attributes = update_params.to_h.except(:station_name)

    if station_name_from_input.blank?
      update_attributes = update_attributes.merge(station_id: nil)
    else
      station = Station.find_or_create_by(name: station_name_from_input)
      update_attributes = update_attributes.merge(station_id: station.id)
    end

    unless shop.update(update_attributes)
      return render json: {
        success: false,
        errors: shop.errors.full_messages
      }, status: :bad_request
    end

    render json: {
      success: true
    }, status: :ok
  end

  private

  def create_manually
    station_name_from_input = shop_params[:station_name]
    shops_attributes = shop_params.to_h.except(:station_name)
    
    # station_nameが空でない場合のみ、stationの取得・作成を行う
    unless station_name_from_input.blank?
      station = Station.find_or_create_by(name: station_name_from_input)
      shops_attributes = shops_attributes.merge(station_id: station.id)
    end

    # ログインユーザーを紐付け
    # shops_attributes = shops_attributes.merge(user_id: current_user.id)
    
    shop = Shop.new(shops_attributes)
    if shop.save
      render json: {
        success: true
      }, status: :created
    else
      render json: {
        success: false,
        errors: shop.errors.full_messages
      }, status: :bad_request
    end
  end

  def create_with_ai
    # APIキーの確認
    api_key = ENV['GEMINI_API_KEY']
    if api_key.blank?
      return render json: {
        success: false,
        message: 'Gemini API key is not configured'
      }, status: :unprocessable_entity
    end

    begin
      # ショップ情報生成用のプロンプト
      prompt = build_shop_generation_prompt

      # Gemini APIリクエスト
      contents = [
        {
          parts: [{ text: prompt }]
        }
      ]

      # Gemini 2.5 Flashを使用（URL contextをサポート）
      uri = URI('https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent')
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request = Net::HTTP::Post.new(uri)
      request['X-goog-api-key'] = api_key
      request['Content-Type'] = 'application/json'
      
      # URL Context: InstagramのURLを直接読み込み
      # Google Search: 住所・最寄り駅を検索
      request.body = {
        contents: contents,
        tools: [
          { url_context: {} },
          { google_search: {} }
        ]
      }.to_json

      response = http.request(request)

      if response.code == '200'
        result = JSON.parse(response.body)
        
        candidate = result['candidates'] && result['candidates'][0]
        content = candidate && candidate['content']
        parts = content && content['parts']
        
        if parts && parts[0] && parts[0]['text']
          gemini_response = parts[0]['text']
          shop_data = parse_shop_response(gemini_response)
          
          if shop_data
            # ショップを作成
            shop = create_shop_from_ai_data(shop_data)
            
            if shop.persisted?
              render json: {
                success: true,
                data: shop.as_json(
                  except: [:updated_at, :station_id],
                  methods: :station_name
                ),
                ai_generated: true
              }, status: :created
            else
              render json: {
                success: false,
                errors: shop.errors.full_messages
              }, status: :bad_request
            end
          else
            render json: {
              success: false,
              message: 'Failed to parse AI response'
            }, status: :bad_request
          end
        else
          # Geminiがテキストを返さなかった場合（店舗情報が見つからなかった可能性）
          Rails.logger.warn "Gemini returned no text content for URL: #{shop_params[:url]}"
          render json: {
            success: false,
            message: 'この店舗の情報を取得できませんでした。URLを確認するか、手動で入力してください。'
          }, status: :bad_request
        end
      else
        Rails.logger.error "Gemini API Error Response: #{response.code} - #{response.body}"
        render json: {
          success: false,
          message: 'Gemini API request failed',
          error: response.body
        }, status: :bad_request
      end
      
    rescue => e
      Rails.logger.error "AI Shop Creation Error: #{e.message}"
      render json: {
        success: false,
        message: 'Error occurred while processing request',
        error: e.message
      }, status: :internal_server_error
    end
  end

  def build_shop_generation_prompt
    instagram_url = clean_instagram_url(shop_params[:url])

    <<~PROMPT
      あなたは飲食店情報を整理するアシスタントです。
      以下のInstagramのURLから、飲食店の情報を取得してJSON形式で返してください。

      Instagram URL: #{instagram_url}

      以下の手順で情報を取得してください:
      
      ステップ1: このInstagramアカウントのプロフィール情報を実際に確認してください
      ステップ2: プロフィールから正式な店舗名（日本語の完全な名称）を特定してください
      ステップ3: 取得した正式な店舗名をメモしてください（この名前を使って検索します）
      ステップ4: その正式な店舗名を使って最寄り駅と住所をGoogle検索してください
      ステップ5: 検索結果から正確な住所と最寄り駅を特定してください
      
      以下のJSON形式で返してください。情報が不明な場合はnullを設定してください。
      思考プロセスは出力せず、JSONのみを返してください。

      {
        "name": "店舗名（例: やきとり柳田屋武蔵小金井店）",
        "station_name": "最寄り駅名（例: 武蔵小金井駅）※nameで取得した店舗名で検索すること",
        "address": "住所（例: 東京都小金井市...）※nameで取得した店舗名で検索すること",
        "tel": "電話番号",
        "memo": "店舗の特徴やジャンル"
      }

      【重要】店舗名の取得方法（必ず守ること）:
      
      ❌ やってはいけないこと:
      - URLからアカウントIDを抽出して店舗名とする（例: gidayajin, ramen_tokyo など）
      - アカウントIDをそのまま使用する
      
      ✅ 必ずやること:
      1. Instagramのプロフィールページを実際に確認する
      2. プロフィールの「本名」欄（Full Name、太字で大きく表示されている名前）を確認する
      3. プロフィール説明文（bio）から店舗の正式名称を探す（ここに正式名称が書かれていることが多い）
      4. 本名欄とプロフィール文の両方を確認し、より詳細で正式な店舗名を採用する
      5. それでも不明な場合は、投稿内容から店舗名を推測する
      
      優先順位: プロフィール説明文の正式名称 > 本名欄 > 投稿から推測
      
      例:
      - URL: https://www.instagram.com/gidayajin/
      - アカウントID: gidayajin （これは使わない❌）
      - プロフィールの本名欄または説明文: 「やきとり柳田屋武蔵小金井店」 （これを使う✅）
      - 結果: name = "やきとり柳田屋武蔵小金井店"
      
      【重要】最寄り駅名と住所の取得方法:
      
      ⚠️ 注意: 必ず上記で取得した正式な店舗名を使って検索してください
      例: 「やきとり柳田屋武蔵小金井店」を取得した場合
        - ✅ 正しい検索: 「やきとり柳田屋武蔵小金井店 住所」
        - ❌ 間違った検索: 「gidayajin 住所」（アカウントIDで検索しない）
      
      1. 上記ステップで取得した正式な店舗名（日本語の店舗名）を使ってGoogle検索する
      2. 「[正式な店舗名] 住所」で検索して住所を取得する
      3. 「[正式な店舗名] 最寄り駅」または「[正式な店舗名] アクセス」で検索して最寄り駅を取得する
      4. 店舗名に駅名が含まれている場合（例: 武蔵小金井店）は、その駅名を最寄り駅として使用する
      5. プロフィールに位置情報や住所が記載されていればそれも参考にする
      6. 食べログ、ぐるなび、Googleマップ、ホットペッパーなどの情報も活用する
      
      検索する店舗名が正しいか確認:
      - アカウントIDではなく、日本語の正式名称を使っているか？
      - 店舗の支店名や地名が含まれているか？
      
      【その他】:
      - 電話番号: プロフィールや投稿から取得
      - memo: 店舗のジャンル（和食、イタリアン、カフェ等）や特徴を記載
      
      【出力形式】:
      - JSONのみを返してください（説明文や思考プロセスは不要）
      - 店舗名は必ず設定してください
    PROMPT
  end

  def parse_shop_response(response_text)
    # JSONブロックを抽出
    json_match = response_text.match(/\{[\s\S]*\}/)
    return nil unless json_match

    JSON.parse(json_match[0])
  rescue JSON::ParserError => e
    Rails.logger.error "JSON Parse Error: #{e.message}"
    nil
  end

  def create_shop_from_ai_data(shop_data)
    shops_attributes = {
      name: shop_data['name'],
      url: clean_instagram_url(shop_params[:url]),
      address: shop_data['address'],
      tel: shop_data['tel'],
      memo: shop_data['memo'],
      is_ai_generated: true,
      # user_id: current_user.id
    }

    # station_nameがある場合はstationを作成/取得
    station_name = shop_data['station_name']
    unless station_name.blank?
      station = Station.find_or_create_by(name: station_name)
      shops_attributes[:station_id] = station.id
    end

    shop = Shop.new(shops_attributes)
    shop.save
    shop
  end

  def shop_params
    params.permit(:name, :url, :station_name, :address, :tel, :memo, :review, :is_ai_generated)
  end

  # InstagramのURLからクエリパラメータを削除する
  # 例: https://www.instagram.com/shop/?igsh=xxx -> https://www.instagram.com/shop/
  def clean_instagram_url(url)
    return nil if url.blank?
    URI.parse(url).tap { |uri| uri.query = nil }.to_s
  rescue URI::InvalidURIError
    url
  end

  def show_params
    params.permit(:id)
  end

  def delete_params
    params.permit(:id)
  end

  def update_params
    params.permit(:id, :name, :url, :station_name, :address, :tel, :memo, :review, :is_instagram)
  end


end
