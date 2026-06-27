require "swagger_helper"

RSpec.describe "Bookings", type: :request do
  let(:owner) { create(:user) }
  let(:hirer) { create(:user) }
  let(:other_user) { create(:user) }
  let(:listing) { create(:rv_listing, user: owner) }

  let(:booking_body) do
    {
      booking: {
        start_date: (Date.current + 1.day).to_s,
        end_date: (Date.current + 7.days).to_s
      }
    }
  end

  path "/listings/{listing_id}/bookings" do
    parameter name: :listing_id, in: :path, type: :integer, description: "Listing ID"

    post "Request a booking" do
      tags "Bookings"
      security [ bearer_auth: [] ]
      consumes "application/json"
      parameter name: "Authorization", in: :header, type: :string, description: "Bearer token"
      parameter name: :booking, in: :body, schema: {
        type: :object,
        properties: {
          booking: {
            type: :object,
            properties: {
              start_date: { type: :string, format: :date },
              end_date: { type: :string, format: :date }
            },
            required: %w[start_date end_date]
          }
        },
        required: [ "booking" ]
      }

      response "201", "booking created" do
        schema "$ref" => "#/components/schemas/booking"

        let(:listing_id) { listing.id }
        let(:Authorization) { auth_headers(hirer)["Authorization"] }
        let(:booking) { booking_body }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data["status"]).to eq("pending")
          expect(data["user_id"]).to eq(hirer.id)
        end
      end

      response "403", "owner cannot book own listing" do
        schema "$ref" => "#/components/schemas/error"

        let(:listing_id) { listing.id }
        let(:Authorization) { auth_headers(owner)["Authorization"] }
        let(:booking) { booking_body }

        run_test!
      end

      response "401", "unauthorized" do
        schema "$ref" => "#/components/schemas/error"

        let(:Authorization) { nil }
        let(:listing_id) { listing.id }
        let(:booking) { booking_body }

        run_test!
      end
    end
  end

  path "/bookings" do
    get "List bookings for current user" do
      tags "Bookings"
      security [ bearer_auth: [] ]
      parameter name: "Authorization", in: :header, type: :string, description: "Bearer token"

      let!(:hirer_booking) { create(:booking, user: hirer, rv_listing: listing) }
      let!(:other_listing) { create(:rv_listing, user: owner) }
      let!(:owner_booking) { create(:booking, user: other_user, rv_listing: other_listing) }

      response "200", "bookings found" do
        schema type: :array,
          items: { "$ref" => "#/components/schemas/booking" }

        let(:Authorization) { auth_headers(owner)["Authorization"] }

        run_test! do |response|
          ids = JSON.parse(response.body).map { |b| b["id"] }
          expect(ids).to include(hirer_booking.id, owner_booking.id)
        end
      end

      response "401", "unauthorized" do
        schema "$ref" => "#/components/schemas/error"

        let(:Authorization) { nil }

        run_test!
      end
    end
  end

  path "/bookings/{id}/confirm" do
    parameter name: :id, in: :path, type: :integer, description: "Booking ID"

    patch "Confirm a booking" do
      tags "Bookings"
      security [ bearer_auth: [] ]
      parameter name: "Authorization", in: :header, type: :string, description: "Bearer token"

      let!(:booking) { create(:booking, user: hirer, rv_listing: listing) }

      response "200", "booking confirmed" do
        schema "$ref" => "#/components/schemas/booking"

        let(:id) { booking.id }
        let(:Authorization) { auth_headers(owner)["Authorization"] }

        run_test! do |response|
          expect(JSON.parse(response.body)["status"]).to eq("confirmed")
        end
      end

      response "403", "forbidden" do
        schema "$ref" => "#/components/schemas/error"

        let(:id) { booking.id }
        let(:Authorization) { auth_headers(hirer)["Authorization"] }

        run_test!
      end

      response "422", "booking not pending" do
        schema "$ref" => "#/components/schemas/error"

        let(:id) { booking.id }
        let(:Authorization) { auth_headers(owner)["Authorization"] }

        before { booking.update!(status: "confirmed") }

        run_test!
      end
    end
  end

  path "/bookings/{id}/reject" do
    parameter name: :id, in: :path, type: :integer, description: "Booking ID"

    patch "Reject a booking" do
      tags "Bookings"
      security [ bearer_auth: [] ]
      parameter name: "Authorization", in: :header, type: :string, description: "Bearer token"

      let!(:booking) { create(:booking, user: hirer, rv_listing: listing) }

      response "200", "booking rejected" do
        schema "$ref" => "#/components/schemas/booking"

        let(:id) { booking.id }
        let(:Authorization) { auth_headers(owner)["Authorization"] }

        run_test! do |response|
          expect(JSON.parse(response.body)["status"]).to eq("rejected")
        end
      end

      response "403", "forbidden" do
        schema "$ref" => "#/components/schemas/error"

        let(:id) { booking.id }
        let(:Authorization) { auth_headers(hirer)["Authorization"] }

        run_test!
      end
    end
  end
end
