class ShopsController < ApplicationController
  def index
    shop = Shop.all
    render json: {
      data: shop.as_json(except: [:updated_at, :station_id]),
      success: true
  }
  end
end
