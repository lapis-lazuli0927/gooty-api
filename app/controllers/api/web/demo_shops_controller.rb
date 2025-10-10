class Api::Web::DemoShopsController < ApplicationController
  before_action :set_demo_shop, only: [:show, :update, :destroy]

  # GET /api/web/demo_shops
  def index
    render json: {
      data: demo_shops_data,
      meta: {
        total: demo_shops_data.length,
        page: params[:page] || 1,
        per_page: params[:per_page] || 10
      }
    }
  end

  # GET /api/web/demo_shops/:id
  def show
    if @demo_shop
      render json: { data: @demo_shop }
    else
      render json: { error: 'Demo shop not found' }, status: :not_found
    end
  end

  # POST /api/web/demo_shops
  def create
    new_shop = {
      id: generate_id,
      name: params[:name] || 'New Demo Shop',
      description: params[:description] || 'A demo shop',
      address: params[:address] || '123 Demo Street',
      phone: params[:phone] || '555-0123',
      email: params[:email] || 'demo@example.com',
      status: params[:status] || 'active',
      created_at: Time.current,
      updated_at: Time.current
    }

    render json: { data: new_shop }, status: :created
  end

  # PATCH/PUT /api/web/demo_shops/:id
  def update
    if @demo_shop
      updated_shop = @demo_shop.merge(
        name: params[:name] || @demo_shop[:name],
        description: params[:description] || @demo_shop[:description],
        address: params[:address] || @demo_shop[:address],
        phone: params[:phone] || @demo_shop[:phone],
        email: params[:email] || @demo_shop[:email],
        status: params[:status] || @demo_shop[:status],
        updated_at: Time.current
      )
      render json: { data: updated_shop }
    else
      render json: { error: 'Demo shop not found' }, status: :not_found
    end
  end

  # DELETE /api/web/demo_shops/:id
  def destroy
    if @demo_shop
      render json: { message: 'Demo shop deleted successfully' }
    else
      render json: { error: 'Demo shop not found' }, status: :not_found
    end
  end

  private

  def set_demo_shop
    @demo_shop = demo_shops_data.find { |shop| shop[:id] == params[:id].to_i }
  end

  def demo_shops_data
    [
      {
        id: 1,
        name: 'Tokyo Electronics',
        description: 'Premium electronics store in Tokyo',
        address: '1-1-1 Shibuya, Shibuya-ku, Tokyo',
        phone: '03-1234-5678',
        email: 'tokyo@electronics.com',
        status: 'active',
        created_at: '2024-01-15T10:00:00Z',
        updated_at: '2024-01-15T10:00:00Z'
      },
      {
        id: 2,
        name: 'Osaka Fashion',
        description: 'Trendy fashion boutique in Osaka',
        address: '2-2-2 Namba, Chuo-ku, Osaka',
        phone: '06-2345-6789',
        email: 'osaka@fashion.com',
        status: 'active',
        created_at: '2024-01-20T14:30:00Z',
        updated_at: '2024-01-20T14:30:00Z'
      },
      {
        id: 3,
        name: 'Kyoto Traditional',
        description: 'Traditional crafts and souvenirs',
        address: '3-3-3 Gion, Higashiyama-ku, Kyoto',
        phone: '075-3456-7890',
        email: 'kyoto@traditional.com',
        status: 'inactive',
        created_at: '2024-01-25T09:15:00Z',
        updated_at: '2024-01-25T09:15:00Z'
      },
      {
        id: 4,
        name: 'Yokohama Books',
        description: 'Large bookstore with cafe',
        address: '4-4-4 Minato Mirai, Nishi-ku, Yokohama',
        phone: '045-4567-8901',
        email: 'yokohama@books.com',
        status: 'active',
        created_at: '2024-02-01T16:45:00Z',
        updated_at: '2024-02-01T16:45:00Z'
      },
      {
        id: 5,
        name: 'Sapporo Sports',
        description: 'Outdoor and winter sports equipment',
        address: '5-5-5 Susukino, Chuo-ku, Sapporo',
        phone: '011-5678-9012',
        email: 'sapporo@sports.com',
        status: 'active',
        created_at: '2024-02-05T11:20:00Z',
        updated_at: '2024-02-05T11:20:00Z'
      }
    ]
  end

  def generate_id
    demo_shops_data.map { |shop| shop[:id] }.max + 1
  end
end
