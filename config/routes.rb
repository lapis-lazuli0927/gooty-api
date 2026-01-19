Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Health check endpoint
  get '/health', to: 'health#check'
  
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # 認証系エンドポイント
  post "signup" => "auth#signup"
  post "login" => "auth#login"
  delete "logout" => "auth#logout"

  # ユーザー管理エンドポイント
  resources :users, only: [:index, :show, :update, :destroy]

  # API routes
  resources :demo_shops, only: [:index, :show]
  resources :stardusts, only: [:index, :create, :show, :update, :destroy]

  # Defines the root path route ("/")
  # root "posts#index"
  get "shops" => "shops#index"
  post "shops" => "shops#create"
  get "shops/:id" => "shops#show"
  delete "shops/:id" => "shops#destroy"
  put "shops/:id" => "shops#update"
end
