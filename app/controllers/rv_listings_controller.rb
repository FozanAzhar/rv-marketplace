class RvListingsController < ApplicationController
  before_action :authenticate_user!, only: [ :create, :update, :destroy ]
  before_action :set_listing, only: [ :show, :update, :destroy ]
  before_action :authorize_owner!, only: [ :update, :destroy ]

  def index
    render json: RvListing.all
  end

  def show
    render json: @listing, include: [ :user ]
  end

  def create
    @listing = current_user.rv_listings.build(listing_params)

    if @listing.save
      render json: @listing, status: :created
    else
      render_validation_errors(@listing)
    end
  end

  def update
    if @listing.update(listing_params)
      render json: @listing
    else
      render_validation_errors(@listing)
    end
  end

  def destroy
    @listing.destroy
    head :no_content
  end

  private

  def set_listing
    @listing = RvListing.find(params[:id])
  end

  def authorize_owner!
    return if @listing.user_id == current_user.id

    render json: { error: "You are not authorized to perform this action" }, status: :forbidden
  end

  def listing_params
    params.require(:rv_listing).permit(:title, :description, :location, :price_per_day)
  end
end
