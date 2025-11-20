class StardustsController < ApplicationController
  before_action :set_stardust, only: [:show, :update, :destroy]

  # GET /stardusts
  def index
    @stardusts = Stardust.all
    render json: { data: @stardusts }
  end

  # POST /stardusts
  def create
    @stardust = Stardust.new(stardust_params)

    if @stardust.save
      render json: { data: @stardust }, status: :created
    else
      render json: { errors: @stardust.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # GET /stardusts/:id
  def show
    render json: { data: @stardust }
  end

  # PUT/PATCH /stardusts/:id
  def update
    if @stardust.update(stardust_params)
      render json: { data: @stardust }
    else
      render json: { errors: @stardust.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE /stardusts/:id
  def destroy
    if @stardust.destroy
      render json: { message: 'Stardust deleted successfully' }
    else
      render json: { errors: @stardust.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_stardust
    @stardust = Stardust.find_by(id: params[:id])
    render json: { error: 'Stardust not found' }, status: :not_found unless @stardust
  end

  def stardust_params
    params.require(:stardust).permit(:value)
  end
end

