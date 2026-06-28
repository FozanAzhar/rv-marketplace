# Base API controller — JWT auth and JSON error handling shared by all endpoints.
class ApplicationController < ActionController::API  include Authenticatable
  include ErrorHandling
end
