require 'bundler/capistrano'
set :application, "192.168.120.231"
set :scm, :git
set :repository,  "file://."
set :branch, "master"
set :deploy_via, :copy
set :checkout, 'export'
set :keep_releases, 5
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

role :web, "192.168.120.231"                          # Your HTTP server, Apache/etc
role :app, "192.168.120.231"                          # This may be the same as your `Web` server
role :db,  "192.168.120.231", :primary => true # This is where Rails migrations will run

default_run_options[:pty] = true
ssh_options[:forward_agent] = true
set :deploy_to, "/var/www/blacklight"
set :user, "mabacaul"
set :use_sudo, false
#set :default_environment, {
#      'PATH' => "/var/lib/gems/1.9.1/bin:$PATH"
#      }
# if you want to clean up old releases on each deploy uncomment this:
after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
 namespace :deploy do
   task :start do ; end
   task :stop do ; end
   task :restart, :roles => :app, :except => { :no_release => true } do
     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
   end
 end
