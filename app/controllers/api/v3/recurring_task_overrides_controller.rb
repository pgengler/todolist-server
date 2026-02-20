module Api
  module V3
    class RecurringTaskOverridesController < ApplicationController
      include JSONAPI::ActsAsResourceController
      
      before_action :authenticate_user!

      private

      def context
        { current_user: current_user }
      end
    end
  end
end
