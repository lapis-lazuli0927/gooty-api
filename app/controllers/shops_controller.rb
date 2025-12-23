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
    station_name_from_input = params[:station_name]
    # 2.無ければstationを作成する
    # 3.上記で、stationのインスタンスが取得できているはず
    # 4.shopインスタンスを作成しレコードを追加する
    # 5.jsonで結果を返す
    # 備考：自動入力との条件分岐は後日実装。今回のスコープは手動入寮までとする
    station = Station.find_or_create_by(name: station_name_from_input)
    shops_attributes = shop_params.to_h.except(:station_name).merge(station_id: station.id)
    @shop = Shop.new(shops_attributes)
    if @shop.save
      render json: {
        success: true
      }
    else
      render json: {
        success: false
      }
    end
  end

  private
 
  def shop_params
    params.permit(:name,:url,:station_name,:address,:tel,:memo,:review,:is_instagram,:is_ai_generated)
  end

  def show
    @shop = Shop.find_by(id: params[:id])

    if @shop
      render json: {
        data: @shop.as_json(
          except: [:updated_at, :station_id, :is_ai_generated, :created_at, :url],
          methods: :station_name
        ),
        success: true
      }
    else
      render json: {
        error: "shop not found",
        success: false
      }, status: :not_found
    end
  end
end