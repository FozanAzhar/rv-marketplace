require "rails_helper"

RSpec.describe "Bookings", type: :request do
  let(:owner) { create(:user) }
  let(:hirer) { create(:user) }
  let(:other_user) { create(:user) }
  let(:listing) { create(:rv_listing, user: owner) }

  let(:booking_params) do
    {
      booking: {
        start_date: (Date.current + 1.day).to_s,
        end_date: (Date.current + 7.days).to_s
      }
    }
  end

  describe "POST /listings/:listing_id/bookings" do
    it "creates a booking for a non-owner" do
      post "/listings/#{listing.id}/bookings",
        params: booking_params,
        headers: auth_headers(hirer)

      expect(response).to have_http_status(:created)
      expect(json_response["status"]).to eq("pending")
      expect(json_response["user_id"]).to eq(hirer.id)
    end

    it "forbids the listing owner from booking their own RV" do
      post "/listings/#{listing.id}/bookings",
        params: booking_params,
        headers: auth_headers(owner)

      expect(response).to have_http_status(:forbidden)
      expect(json_response["error"]).to eq("You cannot book your own listing")
    end

    it "returns unauthorized without a token" do
      post "/listings/#{listing.id}/bookings", params: booking_params

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "GET /bookings" do
    let!(:hirer_booking) { create(:booking, user: hirer, rv_listing: listing) }
    let!(:other_listing) { create(:rv_listing, user: owner) }
    let!(:owner_booking) { create(:booking, user: other_user, rv_listing: other_listing) }

    it "returns bookings where the user is hirer or listing owner" do
      get "/bookings", headers: auth_headers(owner)

      expect(response).to have_http_status(:ok)
      ids = json_response.map { |b| b["id"] }
      expect(ids).to include(hirer_booking.id, owner_booking.id)
    end

    it "returns unauthorized without a token" do
      get "/bookings"

      expect(response).to have_http_status(:unauthorized)
    end
  end

  describe "PATCH /bookings/:id/confirm" do
    let!(:booking) { create(:booking, user: hirer, rv_listing: listing) }

    it "allows the listing owner to confirm a pending booking" do
      patch "/bookings/#{booking.id}/confirm", headers: auth_headers(owner)

      expect(response).to have_http_status(:ok)
      expect(json_response["status"]).to eq("confirmed")
    end

    it "forbids non-owners" do
      patch "/bookings/#{booking.id}/confirm", headers: auth_headers(hirer)

      expect(response).to have_http_status(:forbidden)
    end

    it "rejects confirming a non-pending booking" do
      booking.update!(status: "confirmed")

      patch "/bookings/#{booking.id}/confirm", headers: auth_headers(owner)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json_response["error"]).to eq("Booking is not pending")
    end
  end

  describe "PATCH /bookings/:id/reject" do
    let!(:booking) { create(:booking, user: hirer, rv_listing: listing) }

    it "allows the listing owner to reject a pending booking" do
      patch "/bookings/#{booking.id}/reject", headers: auth_headers(owner)

      expect(response).to have_http_status(:ok)
      expect(json_response["status"]).to eq("rejected")
    end

    it "forbids non-owners" do
      patch "/bookings/#{booking.id}/reject", headers: auth_headers(hirer)

      expect(response).to have_http_status(:forbidden)
    end
  end
end
