# Messaging between owners and hirers about a specific listing.
# POST is open to any logged-in user; GET is restricted to participants.
class MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_listing
  before_action :authorize_viewer!, only: [ :index ]

  def index
    messages = @listing.messages.order(:created_at)
    render json: messages, include: [ :user ]
  end

  def create
    @message = @listing.messages.build(message_params)
    @message.user = current_user

    if @message.save
      render json: @message, include: [ :user ], status: :created
    else
      render_validation_errors(@message)
    end
  end

  private

  def set_listing
    @listing = RvListing.find(params[:listing_id])
  end

  # Only the listing owner, a hirer with a booking, or someone who has
  # already messaged on this listing can read the thread.
  def authorize_viewer!
    return if @listing.user_id == current_user.id
    return if @listing.bookings.exists?(user_id: current_user.id)
    return if @listing.messages.exists?(user_id: current_user.id)

    render json: { error: "You are not authorized to perform this action" }, status: :forbidden
  end

  def message_params
    params.require(:message).permit(:content)
  end
end
