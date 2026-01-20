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

      uri = URI('https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent')
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      request = Net::HTTP::Post.new(uri)
      request['X-goog-api-key'] = api_key
      request['Content-Type'] = 'application/json'
      request.body = { contents: contents }.to_json

      response = http.request(request)

      if response.code == '200'
        result = JSON.parse(response.body)
        
        if result['candidates'] && result['candidates'][0] && result['candidates'][0]['content']
          gemini_response = result['candidates'][0]['content']['parts'][0]['text']
          
          # JSONをパース
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
          render json: {
            success: false,
            message: 'Invalid response from Gemini API'
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
    instagram_url = shop_params[:url]

    <<~PROMPT
      あなたは飲食店情報を整理するアシスタントです。
      以下のInstagramのURLから、飲食店の情報を推測してJSON形式で返してください。

      Instagram URL: #{instagram_url}

      URLからアカウント名や店舗情報を推測し、以下のJSON形式で返してください。
      情報が不明な場合はnullを設定してください。
      思考プロセスは出力せず、JSONのみを返してください。

      {
        "name": "店舗名（InstagramのアカウントIDや表示名から推測）",
        "station_name": "最寄り駅名（推測できる場合）",
        "address": "住所（推測できる場合）",
        "tel": "電話番号（推測できる場合）",
        "memo": "店舗の特徴やジャンル（Instagramの内容から推測）"
      }

      重要:
      - JSONのみを返してください
      - 店舗名は必ず設定してください（不明な場合はInstagramのアカウントIDを使用）
      - URLからInstagramのアカウント情報を読み取り、店舗情報を推測してください
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
      url: shop_params[:url],
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
