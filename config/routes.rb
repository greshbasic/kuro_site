Rails.application.routes.draw do
  root "pages#home"

  get "/kuro_pictures", to: "pages#kuro_pictures"
  get "/kuro_toys", to: "pages#kuro_toys"
  get "/kuro_places", to: "pages#places"
  get "/blog", to: "pages#blog"

  get "up" => "rails/health#show", as: :rails_health_check
end
