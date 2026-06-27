require "swagger_helper"

RSpec.describe "RvListings", type: :request do
  let(:owner) { create(:user) }
  let(:other_user) { create(:user) }
  let!(:listing) { create(:rv_listing, user: owner, title: "Family Camper") }

  path "/listings" do
    get "List all listings" do
      tags "Listings"

      response "200", "listings found" do
        schema type: :array,
          items: { "$ref" => "#/components/schemas/rv_listing" }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data.first["title"]).to eq("Family Camper")
        end
      end
    end

    post "Create a listing" do
      tags "Listings"
      security [ bearer_auth: [] ]
      consumes "application/json"
      parameter name: "Authorization", in: :header, type: :string, description: "Bearer token"
      parameter name: :rv_listing, in: :body, schema: {
        type: :object,
        properties: {
          rv_listing: {
            type: :object,
            properties: {
              title: { type: :string },
              description: { type: :string },
              location: { type: :string },
              price_per_day: { type: :number }
            },
            required: %w[title description location price_per_day]
          }
        },
        required: [ "rv_listing" ]
      }

      response "201", "listing created" do
        schema "$ref" => "#/components/schemas/rv_listing"

        let(:Authorization) { auth_headers(owner)["Authorization"] }
        let(:rv_listing) do
          {
            rv_listing: {
              title: "New RV",
              description: "Spacious",
              location: "Denver",
              price_per_day: 150
            }
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data["user_id"]).to eq(owner.id)
        end
      end

      response "401", "unauthorized" do
        schema "$ref" => "#/components/schemas/error"

        let(:Authorization) { nil }
        let(:rv_listing) do
          {
            rv_listing: {
              title: "New RV",
              description: "Spacious",
              location: "Denver",
              price_per_day: 150
            }
          }
        end

        run_test!
      end
    end
  end

  path "/listings/{id}" do
    parameter name: :id, in: :path, type: :integer, description: "Listing ID"

    get "Show a listing" do
      tags "Listings"

      response "200", "listing found" do
        schema "$ref" => "#/components/schemas/rv_listing"

        let(:id) { listing.id }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data["user"]).to be_present
        end
      end

      response "404", "not found" do
        schema "$ref" => "#/components/schemas/error"

        let(:id) { 0 }

        run_test!
      end
    end

    patch "Update a listing" do
      tags "Listings"
      security [ bearer_auth: [] ]
      consumes "application/json"
      parameter name: "Authorization", in: :header, type: :string, description: "Bearer token"
      parameter name: :rv_listing, in: :body, schema: {
        type: :object,
        properties: {
          rv_listing: {
            type: :object,
            properties: {
              title: { type: :string },
              description: { type: :string },
              location: { type: :string },
              price_per_day: { type: :number }
            }
          }
        },
        required: [ "rv_listing" ]
      }

      response "200", "listing updated" do
        schema "$ref" => "#/components/schemas/rv_listing"

        let(:id) { listing.id }
        let(:Authorization) { auth_headers(owner)["Authorization"] }
        let(:rv_listing) { { rv_listing: { title: "Updated Camper" } } }

        run_test!
      end

      response "403", "forbidden" do
        schema "$ref" => "#/components/schemas/error"

        let(:id) { listing.id }
        let(:Authorization) { auth_headers(other_user)["Authorization"] }
        let(:rv_listing) { { rv_listing: { title: "Hijacked" } } }

        run_test!
      end
    end

    delete "Delete a listing" do
      tags "Listings"
      security [ bearer_auth: [] ]
      parameter name: "Authorization", in: :header, type: :string, description: "Bearer token"

      response "204", "listing deleted" do
        let(:id) { listing.id }
        let(:Authorization) { auth_headers(owner)["Authorization"] }

        run_test! do
          expect(RvListing.find_by(id: listing.id)).to be_nil
        end
      end

      response "403", "forbidden" do
        schema "$ref" => "#/components/schemas/error"

        let(:id) { listing.id }
        let(:Authorization) { auth_headers(other_user)["Authorization"] }

        run_test!
      end
    end
  end
end
