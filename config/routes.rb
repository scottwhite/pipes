ActionController::Routing::Routes.draw do |map|
  map.logout '/leave', :controller => 'sessions', :action => 'destroy'
  map.login '/order', :controller => 'sessions', :action => 'new'
  map.resources :users, {:member=>{:suspend=>:put, :unsuspend=>:put, :purge=>:delete},:collection=>{:settings=>[:get,:put,:delete,:post]}}

  map.resource :sessions
  map.resources :request_number, {:member=>{:success=>:get}, :collection=>{:mail_existing=>:get}}
  map.resources :orders, {:collection=>{:finialize=>:post}}
  
  map.resources :dids
  
  map.success '/success/:id', :controller=> :orders, :action=>:show, :conditions => {:method => :get}
  
  
  # map.login '/login', :controller => :session, :action => :new, :conditions => {:method => :get}
  # map.logout '/logout', :controller => :session, :action => :destroy, :conditions => {:method => :get}
  
  map.entry '/entry', :controller => :sessions, :action => :new, :conditions => {:method => :get}

  map.existing '/existing/:id.:format', controller: :request_number, action: :existing
  map.connect '/existing/:id.:format', controller: :request_number, action: :existing

  map.root controller: :sessions, action: :new
  
end
