ActionController::Routing::Routes.draw do |map|
  map.logout '/leave', :controller => 'sessions', :action => 'destroy'
  map.login '/order', :controller => 'sessions', :action => 'new'
  map.resources :users, {:member=>{:suspend=>:put, :unsuspend=>:put, :purge=>:delete},:collection=>{:settings=>[:get,:put,:delete,:post]}}

  map.resource :sessions , {:collection=>{:request_token=>[:post,:get]}}

  map.call_history '/call_history.:format', controller: 'dids', action: 'history', method: [:get,:post]

  map.request_token '/request_token', controller: 'sessions', action: 'request_token', method: [:get,:post]

  map.request_client_token '/client_token/:token', controller: 'sessions', action: 'twilio_token', method: [:get,:post]

  map.available_products '/inapp/:source/available.:format', controller: 'in_app_purchase', action: 'available_products', method: [:get,:post]


  map.create_order '/inapp/order', controller: :in_app_purchase, action: 'create_order', conditions: {method: :post}
  map.finalize_order '/inapp/order', controller: :in_app_purchase, action: 'finalize_order', conditions:{method: :put}

  map.verify_purchase '/verify_purchase.:format', controller: 'in_app_purchase', action: 'verify_apple_purchase', method: [:get,:post]

  map.connect '/request_number.:format', controller: 'request_number', action: 'new', method: [:get]
  map.request_number '/request_number.:format', controller: 'request_number', action: 'new', method: [:get]

  map.resources :request_number, {:member=>{:success=>:get}, :collection=>{:mail_existing=>:get}}
  map.resources :orders, {:collection=>{:finialize=>:post}, member: {finialize: :post}, }

  map.resources :dids

  map.success '/success/:id', :controller=> :orders, :action=>:show, :conditions => {:method => :get}


  # map.login '/login', :controller => :session, :action => :new, :conditions => {:method => :get}
  # map.logout '/logout', :controller => :session, :action => :destroy, :conditions => {:method => :get}

  map.entry '/entry', :controller => :sessions, :action => :new, :conditions => {:method => :get}

  map.existing_options '/existing_options/:id.:format', controller: :request_number, action: :existing_options
  map.connect '/existing_options/:id.:format', controller: :request_number, action: :existing_options

  map.existing '/existing/:id.:format', controller: :request_number, action: :existing
  map.connect '/existing/:id.:format', controller: :request_number, action: :existing

  map.root controller: :sessions, action: :new
  map.connect '/', controller: :sessions, action: :new, method: [:get]


  map.connect '/:did.:format', controller: :request_number, action: :existing, did: /(\d{3}-\d{3}-\d{4}||\d{10})/, method: [:get,:post]
  map.existing_did '/:did.:format', controller: :request_number, action: :existing, did: /(\d{3}-\d{3}\-d{4}||\d{10})/

  map.resources :dial, {:collection=>{:token=>:get}}


  
end
