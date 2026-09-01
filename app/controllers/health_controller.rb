class HealthController < ActionController::API
  def show
    render json: { status: "ok" }
  end
end
