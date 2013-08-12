require 'capistrano/ext/multistage'
require 'bundler/capistrano'


default_run_options[:pty] = true
set :use_sudo, false

set :stages, %w(development staging production capistrano)
set :default_stage, "staging"
set :application, "aware-server"

set :rake, "/usr/bin/rake"

set :ssh_options, {:forward_agent => true}
set :deploy_to, "/var/apps/#{application}"
set :user, "deploy"
set :group, "web"
set :password, "nifPabneac"


set :scm, "git"
set :repository, "ssh://adam@soundemitter.dyndns.org/Volumes/2TB-Raid1/git/aware-server"
set :git_enable_submodules, nil
set :git_shallow_clone, 1

# for bundler
#set :bundle_cmd, "/usr/bin/bundle"
#set :bundle_flags, "--deployment"

#after :deploy, :tag_deployment
after "deploy:symlink", "deploy:symlink_log_dir"

namespace :deploy do

  task :finalize_update do
    puts "Overriding finalize_update since we don't need the functionality it provides."
  end

  task :symlink_log_dir do
    puts "Creating symlink to shared logs."
    run "ln -s /var/apps/#{application}/shared/log /var/apps/#{application}/current/log"
  end

  task :restart, :roles => :app do
    desc "Running deploy:restart"
    hosts = self.roles[:app].to_ary
    hosts.each_slice(3) do |host_slice|
      #run "touch #{File.join(current_path, "tmp/restart.txt")}"
      run "sudo restart aware-server-cluster", :hosts => host_slice
    end
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

end



namespace :setup do
  desc "install bundler gem"
  task :gem_bundler, :roles => :app do
    run "sudo gem install --no-rdoc --no-ri bundler"
  end
end



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