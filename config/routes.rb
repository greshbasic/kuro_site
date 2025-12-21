Rails.application.routes.draw do
  root "pages#home"

  get "/kuro_pictures", to: "pages#kuro_pictures"
  get "/kuro_toys", to: "pages#kuro_toys"
  get "/kuro_places", to: "pages#places"
  get "/blog", to: "pages#blog"
  get "/blog/:filename", to: "pages#show_post", as: "blog_show"


  get "up" => "rails/health#show", as: :rails_health_check

  resources :comments, only: [:create]
end
