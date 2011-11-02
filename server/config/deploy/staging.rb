#set :shell, "/bin/bash"
#default_run_options[:shell]=false
#of6paiGa

role :app, "mobage-staging-scoreapp101.be.sac.ngmoco.com"
set :rails_env, 'staging'
set :branch, 'master'
