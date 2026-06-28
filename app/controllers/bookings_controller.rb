# Booking requests and owner approval flow (pending → confirmed/rejected).
class BookingsController < ApplicationController  before_action :authenticate_user!
  before_action :set_listing, only: [ :create ]
  before_action :set_booking, only: [ :confirm, :reject ]
  before_action :authorize_listing_owner!, only: [ :confirm, :reject ]
  before_action :ensure_pending!, only: [ :confirm, :reject ]

  def index
    # Return bookings where the user is the hirer OR the listing owner.
    bookings = Booking.joins(:rv_listing)      .where(user_id: current_user.id)
      .or(Booking.joins(:rv_listing).where(rv_listings: { user_id: current_user.id }))

    render json: bookings, include: [ :user, :rv_listing ]
  end

  def create
    # Hirers only — owners cannot book their own listings (test requirement).
    if @listing.user_id == current_user.id      return render json: { error: "You cannot book your own listing" }, status: :forbidden
    end

    @booking = @listing.bookings.build(booking_params)
    @booking.user = current_user

    if @booking.save
      render json: @booking, status: :created
    else
      render_validation_errors(@booking)
    end
  end

  def confirm
    if @booking.update(status: "confirmed")
      render json: @booking
    else
      render_validation_errors(@booking)
    end
  end

  def reject
    if @booking.update(status: "rejected")
      render json: @booking
    else
      render_validation_errors(@booking)
    end
  end

  private

  def set_listing
    @listing = RvListing.find(params[:listing_id])
  end

  def set_booking
    @booking = Booking.find(params[:id])
  end

  def authorize_listing_owner!
    return if @booking.rv_listing.user_id == current_user.id

    render json: { error: "You are not authorized to perform this action" }, status: :forbidden
  end

  def ensure_pending!
    return if @booking.status == "pending"

    render json: { error: "Booking is not pending" }, status: :unprocessable_entity
  end

  def booking_params
    params.require(:booking).permit(:start_date, :end_date)
  end
end
