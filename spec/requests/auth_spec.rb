require "swagger_helper"

RSpec.describe "Auth", type: :request do
  path "/auth/signup" do
    post "Sign up" do
      tags "Authentication"
      consumes "application/json"
      parameter name: :user, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string, example: "Jane Doe" },
          email: { type: :string, format: :email, example: "jane@example.com" },
          password: { type: :string, example: "password123" },
          password_confirmation: { type: :string, example: "password123" }
        },
        required: %w[name email password password_confirmation]
      }

      response "201", "user created" do
        schema "$ref" => "#/components/schemas/user"

        let(:user) do
          {
            name: "Jane Doe",
            email: "jane@example.com",
            password: "password123",
            password_confirmation: "password123"
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data["token"]).to be_present
          expect(data).not_to have_key("password_digest")
        end
      end

      response "422", "validation error" do
        schema "$ref" => "#/components/schemas/validation_errors"

        let(:user) do
          {
            name: "Jane Doe",
            email: "",
            password: "password123",
            password_confirmation: "password123"
          }
        end

        run_test!
      end
    end
  end

  path "/auth/login" do
    post "Log in" do
      tags "Authentication"
      consumes "application/json"
      parameter name: :credentials, in: :body, schema: {
        type: :object,
        properties: {
          email: { type: :string, format: :email },
          password: { type: :string }
        },
        required: %w[email password]
      }

      let!(:existing_user) do
        create(:user, email: "login@example.com", password: "password123", password_confirmation: "password123")
      end

      response "200", "authenticated" do
        schema "$ref" => "#/components/schemas/user"

        let(:credentials) { { email: "login@example.com", password: "password123" } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data["token"]).to be_present
        end
      end

      response "401", "invalid credentials" do
        schema "$ref" => "#/components/schemas/error"

        let(:credentials) { { email: "login@example.com", password: "wrong" } }

        run_test!
      end
    end
  end
end
