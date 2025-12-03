class ShopsController < ApplicationController
  def index
    shop = Shop.all
    render json: { 
      data: shop,
      success: true
  }
  end
end
