require "rails_helper"

RSpec.describe "Auth", type: :request do
  describe "POST /auth/signup" do
    let(:valid_params) do
      {
        name: "Jane Doe",
        email: "jane@example.com",
        password: "password123",
        password_confirmation: "password123"
      }
    end

    it "creates a user and returns a token" do
      post "/auth/signup", params: valid_params

      expect(response).to have_http_status(:created)
      expect(json_response).to include(
        "name" => "Jane Doe",
        "email" => "jane@example.com"
      )
      expect(json_response["token"]).to be_present
      expect(json_response).not_to have_key("password_digest")
    end

    it "returns validation errors for invalid data" do
      post "/auth/signup", params: valid_params.merge(email: "")

      expect(response).to have_http_status(:unprocessable_entity)
      expect(json_response["errors"]).to be_present
    end
  end

  describe "POST /auth/login" do
    let!(:user) { create(:user, email: "login@example.com", password: "password123", password_confirmation: "password123") }

    it "returns a token for valid credentials" do
      post "/auth/login", params: { email: "login@example.com", password: "password123" }

      expect(response).to have_http_status(:ok)
      expect(json_response["token"]).to be_present
      expect(json_response["email"]).to eq("login@example.com")
    end

    it "returns unauthorized for invalid credentials" do
      post "/auth/login", params: { email: "login@example.com", password: "wrong" }

      expect(response).to have_http_status(:unauthorized)
      expect(json_response["error"]).to eq("Invalid email or password")
    end
  end
end
