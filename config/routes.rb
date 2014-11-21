Rails.application.routes.draw do
  resources :contacts

  namespace :api, defaults: {format: 'json'} do
    namespace :v1 do
      resources :products
      resources :orders
      resources :carts
      resources :line_items
      resources :contacts
    end
  end

get 'admin' => 'admin#index'
  
  controller :sessions do
    get  'login' => :new
    post 'login' => :create
    delete 'logout' => :destroy
  end
  
  get "sessions/create"
  get "sessions/destroy"
  
  resources :users
  
  resources :products do
    get :who_bought, on: :member
  end

resources :contacts 

  scope '(:locale)' do
    resources :orders
    resources :line_items
    resources :carts
    
    root 'store#index', as: 'store', via: :all
  end
  put  "/paylane/payment",             to: "payments#pay",            as: 'make_payment'
    put  "/paylane/authorize",           to: "payments#authorize",      as: 'make_authorization'
    get  "/paylane/order/:id",           to: "payments#order_summary",  as: 'order_summary'
    get  "/paylane/order/:id/callback",  to: "payments#order_callback", as: 'order_callback'
end

