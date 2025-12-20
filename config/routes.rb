Rails.application.routes.draw do
  root "pages#home"
  get "/pictures", to: "pages#pictures"

  get "up" => "rails/health#show", as: :rails_health_check
end
