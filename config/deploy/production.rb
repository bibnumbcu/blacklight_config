
# Simple Role Syntax
# ==================
# Supports bulk-adding hosts to roles, the primary server in each group
# is considered to be the first unless any hosts have the primary
# property set.  Don't declare `role :all`, it's a meta role.

role :web, "192.168.120.229"                          # Your HTTP server, Apache/etc
role :app, "192.168.120.229"                          # This may be the same as your `Web` server
role :db,  "192.168.120.229", :primary => true # This is where Rails migrations will run

# Extended Server Syntax
# ======================
# This can be used to drop a more detailed server definition into the
# server list. The second argument is a, or duck-types, Hash and is
# used to set extended properties on the server.
set :stage, :production
set :branch, "master"

server '192.168.120.229', user: 'app', roles: %w{web app}, my_property: :my_value
set :rails_env, :production

# Custom SSH Options
# ==================
# You may pass any option but keep in mind that net/ssh understands a
# limited set of options, consult[net/ssh documentation](http://net-ssh.github.io/net-ssh/classes/Net/SSH.html#method-c-start).
#
# Global options
# --------------
#  set :ssh_options, {
#    forward_agent: true,
#    auth_methods: %w(password)
#  }
##
# And/or per server (overrides global)
# ------------------------------------
# server '192.168.120.231',
#   user: 'app   ',
#   ssh_options: {
#     user: 'app', # overrides user setting above
#   }
