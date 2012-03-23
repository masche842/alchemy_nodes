Dummy::Application.routes.draw do
  resources :products

  mount Alchemy::Engine => '/'
end
