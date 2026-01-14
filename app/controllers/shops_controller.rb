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
    # 1.station_nameが一致するstationリソースが存在しているか確認する
    station_name_from_input = shop_params[:station_name]
    # 2.無ければstationを作成する
    # 3.上記で、stationのインスタンスが取得できているはず
    # 4.shopインスタンスを作成しレコードを追加する
    # 5.jsonで結果を返す
    # 備考：自動入力との条件分岐は後日実装。今回のスコープは手動入寮までとする
    
    shops_attributes = shop_params.to_h.except(:station_name)
    
    # station_nameが空でない場合のみ、stationの取得・作成を行う
    unless station_name_from_input.blank?
      station = Station.find_or_create_by(name: station_name_from_input)
      shops_attributes = shops_attributes.merge(station_id: station.id)
    end
    
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
