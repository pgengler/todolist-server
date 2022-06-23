class ListsController < ApplicationController
  before_action :doorkeeper_authorize!

  def destroy
    list = List.find(params[:id])

    # only allow 'list' type lists to be deleted, and only if they're empty
    if list.list_type != 'list' || list.tasks.count != 0
      return head :unprocessable_entity
    end

    list.deleted = true
    list.save!
    head :no_content
  end
end
