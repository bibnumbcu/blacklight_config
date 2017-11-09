Rails.application.routes.draw do
  
  mount Blacklight::Engine => '/'
  mount BlacklightAdvancedSearch::Engine => '/'

 


  Blacklight::Marc.add_routes(self)
  root to: "catalog#index"
    concern :searchable, Blacklight::Routes::Searchable.new

  resource :catalog, only: [:index], as: 'catalog', path: '/catalog', controller: 'catalog' do
    concerns :searchable
  end

  concern :exportable, Blacklight::Routes::Exportable.new

  resources :solr_documents, only: [:show], path: '/catalog', controller: 'catalog' do
    concerns :exportable
  end

  resources :bookmarks do
    concerns :exportable

    collection do
      delete 'clear'
    end
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
    
  match 'user/login',          :to => 'user#login',       :as => 'new_user_session', :via => [:get,:post]
  match 'user/logout',         :to => 'user#logout',      :as => 'destroy_user_session', :via => [:get,:post]
  match 'user/compte',   :to => 'user#compte', :as => 'edit_user_registration', :via => [:get,:post]
  match 'user/reservation',   :to => 'user#reservation', :as => 'user_reservation', :via => [:get,:post]
  match 'user/renew_loan',   :to => 'user#renew_loan', :as => 'user_renew_loan', :via => [:get,:post]
  match 'user/communication',   :to => 'user#communication', :as => 'user_communication', :via => [:get,:post]
  match 'nouveautes/:id',   :to => 'catalog#index', :constraints => { :id => /.*/ }, :via => [:get,:post]
  match 'suggestion/demande',   :to => 'suggestion#index', :as => 'suggestion_demande', :via => [:get,:post]


end
