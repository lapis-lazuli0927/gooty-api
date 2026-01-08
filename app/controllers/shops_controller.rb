class ShopsController < ApplicationController
  def index
    shop = Shop.all
    render json: {
      data: shop.as_json(
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
        except: [:updated_at, :station_id, :is_ai_generated, :created_at, :url],
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


end
