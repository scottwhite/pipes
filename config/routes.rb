ActionController::Routing::Routes.draw do |map|
  map.activate '/activate/:activation_code', :controller => 'users', :action => 'activate', :activation_code => ''
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.login '/login', :controller => 'sessions', :action => 'new'
  map.register '/register', :controller => 'users', :action => 'create'
  map.signup '/signup', :controller => 'users', :action => 'new'
  map.resources :users, {:member=>{:suspend=>:put, :unsuspend=>:put, :purge=>:delete}}

  map.resource :session
  map.resource :request_number
  
  map.login '/login', :controller => :session, :action => :new, :conditions => {:method => :get}
  map.logout '/logout', :controller => :session, :action => :destroy, :conditions => {:method => :get}


  map.root controller: :request_number, action: :index
  
end
