BlacklightDeveloppement5150::Application.routes.draw do
  
  Blacklight::Marc.add_routes(self)
  root to: "catalog#index"
  blacklight_for :catalog
  match 'user/login',          :to => 'user#login',       :as => 'new_user_session', :via => [:get,:post]
  match 'user/logout',         :to => 'user#logout',      :as => 'destroy_user_session', :via => [:get,:post]
  match 'user/compte',   :to => 'user#compte', :as => 'edit_user_registration', :via => [:get,:post]
  match 'user/reservation',   :to => 'user#reservation', :as => 'user_reservation', :via => [:get,:post]
  match 'user/renew_loan',   :to => 'user#renew_loan', :as => 'user_renew_loan', :via => [:get,:post]
  match 'user/communication',   :to => 'user#communication', :as => 'user_communication', :via => [:get,:post]
  match 'nouveautes/:id',   :to => 'catalog#index', :constraints => { :id => /.*/ }, :via => [:get,:post]
  match 'suggestion/demande',   :to => 'suggestion#index', :as => 'suggestion_demande', :via => [:get,:post]
  
  
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
