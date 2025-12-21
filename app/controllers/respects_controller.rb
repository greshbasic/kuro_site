class RespectsController < ApplicationController
  protect_from_forgery with: :exception

  def create
    respect = Respect.instance
    respect.increment!(:count)

    redirect_back fallback_location: root_path
  end
end
