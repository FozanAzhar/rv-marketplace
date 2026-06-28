# frozen_string_literal: true

require "rails_helper"

RSpec.configure do |config|
  config.openapi_root = Rails.root.join("swagger").to_s

  config.openapi_specs = {
    "v1/swagger.yaml" => {
      openapi: "3.0.1",
      info: {
        title: "RV Marketplace API",
        version: "v1",
        description: "REST API for listing RVs, messaging about listings, requesting bookings, and managing reservations."
      },
      paths: {},
      servers: [
        {
          url: "http://localhost:3000",
          description: "Development"
        }
      ],
      components: {
        securitySchemes: {
          bearer_auth: {
            type: :http,
            scheme: :bearer,
            bearerFormat: :JWT,
            description: "JWT token from POST /auth/signup or POST /auth/login"
          }
        },
        schemas: {
          user: {
            type: :object,
            properties: {
              id: { type: :integer },
              name: { type: :string },
              email: { type: :string, format: :email },
              token: { type: :string }
            }
          },
          rv_listing: {
            type: :object,
            properties: {
              id: { type: :integer },
              title: { type: :string },
              description: { type: :string },
              location: { type: :string },
              price_per_day: { type: :string },
              user_id: { type: :integer },
              created_at: { type: :string, format: :"date-time" },
              updated_at: { type: :string, format: :"date-time" },
              user: { "$ref": "#/components/schemas/user" }
            }
          },
          booking: {
            type: :object,
            properties: {
              id: { type: :integer },
              start_date: { type: :string, format: :date },
              end_date: { type: :string, format: :date },
              status: { type: :string, enum: %w[pending confirmed rejected] },
              user_id: { type: :integer },
              rv_listing_id: { type: :integer },
              created_at: { type: :string, format: :"date-time" },
              updated_at: { type: :string, format: :"date-time" }
            }
          },
          message: {
            type: :object,
            properties: {
              id: { type: :integer },
              content: { type: :string },
              user_id: { type: :integer },
              rv_listing_id: { type: :integer },
              created_at: { type: :string, format: :"date-time" },
              updated_at: { type: :string, format: :"date-time" },
              user: { "$ref": "#/components/schemas/user" }
            }
          },
          error: {
            type: :object,
            properties: {
              error: { type: :string }
            }
          },
          validation_errors: {
            type: :object,
            properties: {
              errors: {
                type: :array,
                items: { type: :string }
              }
            }
          }
        }
      }
    }
  }

  config.openapi_format = :yaml
end
