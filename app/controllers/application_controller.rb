class ApplicationController < ActionController::API
  include JSONAPI::ActsAsResourceController

  skip_forgery_protection
end
