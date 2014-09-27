# config valid only for Capistrano 3.1
lock '3.2.1'

%w( application repo_url branch ).each do |setting|
	setting_value = ENV[setting]
	raise "Missing setting: #{setting}" if setting_value.nil?
	puts "Setting: #{setting}, Value: #{setting_value}"
	set setting.to_sym, setting_value
end

# Default deploy_to directory is /var/www/my_app
deploy_to = "/home/deploy/#{application}"
set :deploy_to, deploy_to
puts "Deploy To: #{deploy_to}"

	
set :default_shell, '/bin/bash'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, %w{config/database.yml}

# Default value for linked_dirs is []
# set :linked_dirs, %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
# set :keep_releases, 5

namespace :deploy do

	desc 'Publish Deploy Uey For Git To Host'
	task :publish_deploy_key do
    on roles(:app), in: :sequence, wait: 5 do
      upload! "~/.ssh/deploy_id_rsa", "/home/deploy/.ssh/deploy_id_rsa"
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
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

end
