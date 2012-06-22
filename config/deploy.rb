require 'capistrano/ext/multistage'

set :application, "pipes"
set :repository, "git@github.com:scottwhite/pipes.git"
set :scm, "git"
set :branch, "master"
# set :deploy_via, :remote_cache

set :deploy_via, :copy
set :copy_strategy, :export
set :copy_exclude, ["config/deploy.rb","lib/tasks/rspec.rake", "doc", "spec"]

default_run_options[:pty] = true
ssh_options[:forward_agent] = true

set :deploy_to,"/var/www/#{application}"
set :user, 'pipes'
set :use_sudo, false

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end

desc "Create the symbolic links from the public www dir to the server install of Ext JS and the pdfs dir"
task :symbolic_links do
  run "ln -s /var/www/pipes/current_provider_login #{current_release}/config/"
end

after "deploy:symlink", :symbolic_links