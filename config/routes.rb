AlchemyNodes::Engine.routes.draw do
  resources :containers

  resources :nodes

  namespace :admin do

    resources :nodes do

      resources :elements
      collection do
        post :order
        post :flush
        get :link
      end
      member do
        get :edit_content
        get :update_content
        post :unlock
        post :publish
        post :fold
        post :visit
        get :configure
        get :preview
      end


    end
  end

end
