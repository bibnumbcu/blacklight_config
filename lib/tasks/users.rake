namespace :users do
  # task to clean out junk users account
  # rake blacklight:delete_guest_users
  # 0 2 * * * cd /path/to/your/app && /path/to/rake blacklight:delete_guest_users RAILS_ENV=your_env
  desc "Removes guest users from Users table"
  task :delete_guest_users => :environment do |t, args|
    User.delete_guest_users
  end
end
