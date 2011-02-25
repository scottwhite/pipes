ActionController::Routing::Routes.draw do |map|
  map.logout '/leave', :controller => 'sessions', :action => 'destroy'
  map.login '/order', :controller => 'sessions', :action => 'new'
  map.resources :users, {:member=>{:suspend=>:put, :unsuspend=>:put, :purge=>:delete},:collection=>{:settings=>[:get,:put,:delete,:post]}}

  map.resource :sessions , {:collection=>{:request_token=>[:post,:get]}}
  
  map.request_token '/request_token', controller: 'sessions', action: 'request_token', method: [:get,:post]
  
  map.resources :request_number, {:member=>{:success=>:get}, :collection=>{:mail_existing=>:get, :existing_options=>[:get,:post]}}
  map.resources :orders, {:collection=>{:finialize=>:post}}
  
  map.resources :dids
  
  map.success '/success/:id', :controller=> :orders, :action=>:show, :conditions => {:method => :get}
  
  
  # map.login '/login', :controller => :session, :action => :new, :conditions => {:method => :get}
  # map.logout '/logout', :controller => :session, :action => :destroy, :conditions => {:method => :get}
  
  map.entry '/entry', :controller => :sessions, :action => :new, :conditions => {:method => :get}


  map.existing '/existing/:id.:format', controller: :request_number, action: :existing
  map.connect '/existing/:id.:format', controller: :request_number, action: :existing

  map.root controller: :sessions, action: :new
  map.connect '/', controller: :sessions, action: :new, method: [:get]


  map.connect '/:did.:format', controller: :request_number, action: :existing, did: /(\d{3}-\d{3}-\d{4}||\d{10})/, method: [:get,:post]
  map.existing_did '/:did.:format', controller: :request_number, action: :existing, did: /(\d{3}-\d{3}\-d{4}||\d{10})/



  
end
