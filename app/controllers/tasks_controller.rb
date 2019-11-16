class TasksController < ApplicationController
  before_action :doorkeeper_authorize!
end
