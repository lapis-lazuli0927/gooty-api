class HealthController < ApplicationController
  def check
    render json: { 
      status: 'ok', 
      timestamp: Time.current,
      service: 'gooty-api'
    }
  end
end