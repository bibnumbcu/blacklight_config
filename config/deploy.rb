# config valid only for Capistrano 3.1
lock '3.4.0'

set :application, "192.168.120.231"
set :repo_url, 'file://.'

# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }.call

# Default deploy_to directory is /var/www/my_app
set :deploy_to, "/var/www/blacklight"

# Default value for :scm is :git
set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
set :log_level, :debug

# Default value for :pty is false
set :pty, true

# Default value for :linked_files is []
# set :linked_files, %w{config/database.yml}

# Default value for linked_dirs is []
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
set :keep_releases, 5
set :repository,  "file://."
set :branch, "master"
set :deploy_via, :copy
set :checkout, 'export'
set :keep_releases, 5


namespace :deploy do
   before :deploy, :deploy_from_local_repo

   task :deploy_from_local_repo do
    set :repo_url,  "file:///tmp/.git"
    run_locally do
      execute "tar -zcvf /tmp/repo.tgz .git"
    end
    on roles(:all) do
      upload! '/tmp/repo.tgz', '/tmp/repo.tgz'
      execute 'tar -zxvf /tmp/repo.tgz -C /tmp'
    end
  end
  
  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      # Your restart mechanism here, for example:
      execute :touch, release_path.join('tmp/restart.txt')
    end
  end

  
 
  after :publishing, :restart
  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
       within release_path do
         execute :rake, 'cache:clear'
      end
    end
  end


   
end
