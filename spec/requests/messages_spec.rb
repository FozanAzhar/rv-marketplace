require "swagger_helper"

RSpec.describe "Messages", type: :request do
  let(:owner) { create(:user) }
  let(:hirer) { create(:user) }
  let(:other_user) { create(:user) }
  let(:listing) { create(:rv_listing, user: owner) }

  path "/listings/{listing_id}/messages" do
    parameter name: :listing_id, in: :path, type: :integer, description: "Listing ID"

    get "List messages for a listing" do
      tags "Messages"
      security [ bearer_auth: [] ]
      parameter name: "Authorization", in: :header, type: :string, description: "Bearer token"

      let!(:message) { create(:message, rv_listing: listing, user: hirer, content: "Is this still available?") }

      response "200", "messages found" do
        schema type: :array,
          items: { "$ref" => "#/components/schemas/message" }

        let(:listing_id) { listing.id }
        let(:Authorization) { auth_headers(owner)["Authorization"] }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data.first["content"]).to eq("Is this still available?")
          expect(data.first["user"]).to be_present
        end
      end

      response "403", "forbidden" do
        schema "$ref" => "#/components/schemas/error"

        let(:listing_id) { listing.id }
        let(:Authorization) { auth_headers(other_user)["Authorization"] }

        run_test!
      end

      response "401", "unauthorized" do
        schema "$ref" => "#/components/schemas/error"

        let(:listing_id) { listing.id }
        let(:Authorization) { nil }

        run_test!
      end
    end

    post "Send a message about a listing" do
      tags "Messages"
      security [ bearer_auth: [] ]
      consumes "application/json"
      parameter name: "Authorization", in: :header, type: :string, description: "Bearer token"
      parameter name: :message, in: :body, schema: {
        type: :object,
        properties: {
          message: {
            type: :object,
            properties: {
              content: { type: :string }
            },
            required: [ "content" ]
          }
        },
        required: [ "message" ]
      }

      response "201", "message created" do
        schema "$ref" => "#/components/schemas/message"

        let(:listing_id) { listing.id }
        let(:Authorization) { auth_headers(hirer)["Authorization"] }
        let(:message) { { message: { content: "Can I pick it up on Friday?" } } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data["content"]).to eq("Can I pick it up on Friday?")
          expect(data["user_id"]).to eq(hirer.id)
        end
      end

      response "422", "validation error" do
        schema "$ref" => "#/components/schemas/validation_errors"

        let(:listing_id) { listing.id }
        let(:Authorization) { auth_headers(hirer)["Authorization"] }
        let(:message) { { message: { content: "" } } }

        run_test!
      end

      response "401", "unauthorized" do
        schema "$ref" => "#/components/schemas/error"

        let(:listing_id) { listing.id }
        let(:Authorization) { nil }
        let(:message) { { message: { content: "Hello" } } }

        run_test!
      end
    end
  end
end
