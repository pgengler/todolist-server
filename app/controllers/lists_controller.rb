class ListsController < ApplicationController
  before_action :doorkeeper_authorize!
end
