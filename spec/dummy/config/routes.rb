Dummy::Application.routes.draw do

  resources :products

  namespace :admin do
    resources :products
  end

  mount AlchemyNodes::Engine => '/'
  mount Alchemy::Engine => '/'
end
