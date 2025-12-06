class ShopsController < ApplicationController
  def index
    shop = Shop.all
    render json: {
      data: shop.as_json(
        except: [:url, :updated_at, :station_id],
        methods: :station_name
        ),
      success: true
    }
  end
end