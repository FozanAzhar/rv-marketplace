class ApplicationController < ActionController::API
  include Authenticatable
  include ErrorHandling
end
