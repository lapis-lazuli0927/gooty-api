class DemoShopsController < ApplicationController
  before_action :set_demo_shop, only: [:show]

  # GET /demo_shops
  def index
    render json: {
      data: demo_shops_data
    }
  end

  # GET /demo_shops/:id
  def show
    render json: { data: @demo_shop }
  end

  private

  def set_demo_shop
    @demo_shop = demo_shops_data.find { |shop| shop[:id] == params[:id].to_i }
    render json: { error: 'Demo shop not found' }, status: :not_found unless @demo_shop
  end

  def demo_shops_data
    [
      {
        id: 1,
        name: 'Switch',
        type: 1,
        station: 'Shibuya Station',
        review_level: 4.5,
        created_at: '2024-01-15T10:00:00Z',
        updated_at: '2024-01-15T10:00:00Z'
      },
      {
        id: 2,
        name: 'てっかば',
        type: 2,
        station: 'Namba Station',
        review_level: 4.2,
        created_at: '2024-01-20T14:30:00Z',
        updated_at: '2024-01-20T14:30:00Z'
      },
      {
        id: 3,
        name: '爛漫東京',
        type: 3,
        station: 'Gion Station',
        review_level: 4.8,
        created_at: '2024-01-25T09:15:00Z',
        updated_at: '2024-01-25T09:15:00Z'
      },
      {
        id: 4,
        name: '燗アガリ',
        type: 1,
        station: 'Minato Mirai Station',
        review_level: 4.0,
        created_at: '2024-02-01T16:45:00Z',
        updated_at: '2024-02-01T16:45:00Z'
      },
      {
        id: 5,
        name: 'おつくり亭',
        type: 2,
        station: 'Susukino Station',
        review_level: 4.3,
        created_at: '2024-02-05T11:20:00Z',
        updated_at: '2024-02-05T11:20:00Z'
      },
      {
        id: 6,
        name: '魚河岸',
        type: 3,
        station: 'Tsukiji Station',
        review_level: 4.7,
        created_at: '2024-02-10T08:30:00Z',
        updated_at: '2024-02-10T08:30:00Z'
      },
      {
        id: 7,
        name: '酒蔵',
        type: 1,
        station: 'Shinjuku Station',
        review_level: 4.1,
        created_at: '2024-02-15T19:00:00Z',
        updated_at: '2024-02-15T19:00:00Z'
      },
      {
        id: 8,
        name: '居酒屋 花',
        type: 2,
        station: 'Ikebukuro Station',
        review_level: 4.4,
        created_at: '2024-02-20T12:15:00Z',
        updated_at: '2024-02-20T12:15:00Z'
      },
      {
        id: 9,
        name: '寿司 海',
        type: 3,
        station: 'Ginza Station',
        review_level: 4.9,
        created_at: '2024-02-25T17:45:00Z',
        updated_at: '2024-02-25T17:45:00Z'
      },
      {
        id: 10,
        name: '焼鳥 炭火',
        type: 1,
        station: 'Roppongi Station',
        review_level: 4.6,
        created_at: '2024-03-01T20:30:00Z',
        updated_at: '2024-03-01T20:30:00Z'
      }
    ]
  end
end
