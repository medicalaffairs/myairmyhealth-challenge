Myairmyhealth::Application.routes.draw do

#  get "singly/new"
#  get "singly/create"
#  get "singly/failure"
  
 # get   '/singlylogin', :to => 'singly#new', :as => :singlylogin
  match '/auth/:provider/callback', :to => 'singly#create'
  match '/auth/failure', :to => 'singly#failure'

  match '/cosm/select_feed', :to => 'cosm#get_feed_id'
  match '/cosm/callback', :to => 'cosm#create'
  match '/cosm/authorize', :to => 'cosm#authorize'

  match '/foursquare/callback', :to => 'foursquare#create'
  match '/foursquare/authorize', :to => 'foursquare#authorize'

  match '/bodymedia/callback', :to => 'bodymedia#create'
  match '/bodymedia/authorize', :to => 'bodymedia#authorize'

  post '/nanotracer/:id', :to => 'nanotracer#add' 
  post '/nanoreporter/callback', :to => 'nanotracer#create'
  get '/nanoreporter/authorize', :to => 'nanotracer#authorize'
  put '/nanoreporter/upload', :to => 'nanotracer#upload'

  post '/respflowdata/:id', :to => 'respiratory#add' 
  post '/respiratory/callback', :to => 'respiratory#create'
  get '/respiratory/authorize', :to => 'respiratory#authorize'

  match '/gps/:id', :to => 'btraced#add' 
  post '/btraced/callback', :to => 'btraced#create'
  get '/btraced/authorize', :to => 'btraced#authorize'

  devise_for :users, :controllers => {:registrations => 'registrations', :sessions => 'sessions'}
  as :users do
    get "/users/profile/(:id)", :to => 'users#show', :as => :user_profile
    get "/users/unauthorized", :to => 'users#unauthorized', :as => :user_unauthorized
  end

  resources :devices 
  match '/analyze', :to => 'analyze#index'  
  match '/contact', :to => 'pages#contact'
  match '/about', :to => 'pages#about'
  match '/help', :to => 'pages#help'

  match '/map/markers', :to => 'map#markers'
  match '/physiology/data', :to => 'physiology#data'
  match '/air_quality/data', :to => 'air_quality#data'
  
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  
  root :to => 'pages#home'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
