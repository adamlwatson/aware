require 'capistrano/ext/multistage'
require 'bundler/capistrano'
#require 'net/smtp'

set :stages, %w(development staging production capistrano)
set :default_stage, "staging"
set :application, "aware_server"

set :rake, "/usr/bin/rake"

set :ssh_options, {:forward_agent => true}
set :repository, "ssh://adam@soundemitter.dyndns.org/Volumes/2TB-Raid1/git/aware"
set :git_enable_submodules, nil
set :git_shallow_clone, 1
set :scm, "git"

set :bundle_cmd, "/usr/bin/bundle"
#set :bundle_flags, "--deployment"

role :app
set :use_sudo, true

set :deploy_to, "/var/apps/#{application}"
set :user, "deploy"

before :deploy, :copy_to_level_up

#after :deploy, :tag_deployment

namespace :deploy do

  desc "Restart Application"
  task :restart, :roles => :app do
    hosts = self.roles[:app].to_ary
    if false
      hosts.each_slice(7) do |host_slice|
        run "touch #{current_release}/tmp/restart.txt", :hosts => host_slice
        sleep 1
      end
    else
      hosts.each_slice(3) do |host_slice|
        run "sudo /etc/init.d/nginx stop", :hosts => host_slice
        sleep 1
        run "sudo /etc/init.d/nginx start", :hosts => host_slice
        sleep 1
      end      
    end
  end

end



desc "Copy code application to level up"
task :copy_to_level_up do
  desc "level up release_path: #{release_path}"
  #run "mv -R #{release_path}/ ....." #rewrite it with your conditions
end


desc "Tag deployments"
task :tag_deployment do
  tag_name = "deploy_#{stage}_#{Time.now.strftime('%Y_%m_%d_%H_%M_%S')}"
  `git fetch origin`
  b = branch || master
  commit_id = `git log -n1 --pretty="format:%H" origin/#{b}`.chomp
  `git tag #{tag_name} #{commit_id}`
  `git push origin #{tag_name}`
end

namespace :setup do
  desc "install bundler gem"
  task :gem_bundler, :roles => :app do
    run "sudo gem install --no-rdoc --no-ri bundler"
  end
end




=begin
namespace :nginx do
  desc "Restart nginx"
  task :restart, :roles => :app do
    run "sudo /etc/init.d/nginx restart"
  end
end

desc "Symlinks the config and system dirs into the current release"
task :after_update_code, :roles => [:web, :app, :resque], :except=>{:no_release=>true} do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    run "ln -nfs #{shared_path}/config/google_market.yml #{release_path}/config/google_market.yml"
    run "rm #{release_path}/config/cassandra.yml"
    run "ln -nfs #{shared_path}/config/cassandra.yml #{release_path}/config/cassandra.yml"
    run "ln -nfs /data/gserver/#{stage}/system #{release_path}/public/system"
    run "rm -rf #{release_path}/certificates"
    run "ln -nfs /data/gserver/#{stage}/certificates #{release_path}/certificates"
    run "chmod g+w /data/gserver/#{stage}/*"
    run "chmod g+w #{release_path}/tmp"
end
=end

=begin
desc "Email about deploys"
task :email_deployment do
  tags = `git tag -l deploy_#{stage}_20*`.split("\n").sort.reverse[0,2]
  changes = `git log --oneline #{tags[1]}..#{tags[0]}`
  msgstr = <<END_OF_MESSAGE
From: Deploy Notifier <donotreply@alwlabs.com>
To: Deployment Notifications <deployments@alwlabs.com>
Subject: Plus #{stage} deployment

We have just deployed the following commits to the #{stage} environment:

#{changes}

This deploy has been tagged as #{tags[0]}

END_OF_MESSAGE

  begin
    smtp = Net::SMTP.new('smtp.gmail.com', 587)
    smtp.enable_starttls
    smtp.start('localhost', 'donotreply@alwlabs.com', 'XLyEB2SMgg4MGz', :login) do |smtp|
      smtp.send_message msgstr, 'donotreply@alwlabs.com', 'deployments@alwlabs.com'
    end
  rescue
    puts "Couldn't send email"
  end
end
=end