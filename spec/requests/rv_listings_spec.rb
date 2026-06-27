require "rails_helper"

RSpec.describe "RvListings", type: :request do
  let(:owner) { create(:user) }
  let(:other_user) { create(:user) }
  let!(:listing) { create(:rv_listing, user: owner, title: "Family Camper") }

  describe "GET /listings" do
    it "returns all listings without authentication" do
      get "/listings"

      expect(response).to have_http_status(:ok)
      expect(json_response).to be_an(Array)
      expect(json_response.first["title"]).to eq("Family Camper")
    end
  end

  describe "GET /listings/:id" do
    it "returns a single listing with owner" do
      get "/listings/#{listing.id}"

      expect(response).to have_http_status(:ok)
      expect(json_response["title"]).to eq("Family Camper")
      expect(json_response["user"]).to be_present
    end

    it "returns not found for missing listing" do
      get "/listings/0"

      expect(response).to have_http_status(:not_found)
      expect(json_response["error"]).to eq("Record not found")
    end
  end

  describe "POST /listings" do
    let(:listing_params) do
      {
        rv_listing: {
          title: "New RV",
          description: "Spacious",
          location: "Denver",
          price_per_day: 150
        }
      }
    end

    it "creates a listing for the authenticated user" do
      post "/listings", params: listing_params, headers: auth_headers(owner)

      expect(response).to have_http_status(:created)
      expect(json_response["title"]).to eq("New RV")
      expect(json_response["user_id"]).to eq(owner.id)
    end

    it "returns unauthorized without a token" do
      post "/listings", params: listing_params

      expect(response).to have_http_status(:unauthorized)
      expect(json_response["error"]).to eq("Unauthorized")
    end

    it "returns unauthorized with an invalid token" do
      post "/listings",
        params: listing_params,
        headers: { "Authorization" => "Bearer invalid.token" }

      expect(response).to have_http_status(:unauthorized)
      expect(json_response["error"]).to eq("Unauthorized")
    end
  end

  describe "PATCH /listings/:id" do
    it "allows the owner to update" do
      patch "/listings/#{listing.id}",
        params: { rv_listing: { title: "Updated Camper" } },
        headers: auth_headers(owner)

      expect(response).to have_http_status(:ok)
      expect(json_response["title"]).to eq("Updated Camper")
    end

    it "forbids non-owners" do
      patch "/listings/#{listing.id}",
        params: { rv_listing: { title: "Hijacked" } },
        headers: auth_headers(other_user)

      expect(response).to have_http_status(:forbidden)
      expect(json_response["error"]).to eq("You are not authorized to perform this action")
    end
  end

  describe "DELETE /listings/:id" do
    it "allows the owner to delete" do
      delete "/listings/#{listing.id}", headers: auth_headers(owner)

      expect(response).to have_http_status(:no_content)
      expect(RvListing.find_by(id: listing.id)).to be_nil
    end

    it "forbids non-owners" do
      delete "/listings/#{listing.id}", headers: auth_headers(other_user)

      expect(response).to have_http_status(:forbidden)
      expect(RvListing.find_by(id: listing.id)).to be_present
    end
  end
end
