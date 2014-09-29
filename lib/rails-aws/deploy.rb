# config valid only for Capistrano 3.1
lock '3.2.1'

%w( application repo_url branch deploy_key rails_env ).each do |setting|
	setting_value = ENV[setting]
	raise "Missing setting: #{setting}" if setting_value.nil?
	puts "Setting: #{setting}, Value: #{setting_value}"
	set setting.to_sym, setting_value
end

# Default deploy_to directory is /var/www/my_app
deploy_to = "/home/deploy/#{fetch(:application)}"
set :deploy_to, deploy_to
puts "Deploy To: #{deploy_to}"

	
set :default_shell, '/bin/bash -l'

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

	desc 'Publish Deploy Uey For Git'
	task :publish_deploy_key do
    on roles(:app), in: :sequence, wait: 5 do
			puts "Setting Up Git Deploy Key"
			remote_key = "/home/deploy/.ssh/deploy_id_rsa"
			ssh_config = "/home/deploy/.ssh/config"

      upload! fetch( :deploy_key ), remote_key

			execute :touch, ssh_config
			execute "echo '# Github' >> #{ssh_config}"
			execute "echo 'Host github.com' >> #{ssh_config}"
			execute "echo 'User git' >> #{ssh_config}"
			execute "echo 'IdentityFile #{remote_key}' >> #{ssh_config}"
			puts "Git Deploy Key Setup"
    end
	end

	desc 'Generate Rails Secret'
	task :generate_secret do
    on roles(:app), in: :sequence, wait: 5 do
			begin
				execute "cd #{current_path} && mkdir tmp"
			resque
				puts "failed making tmp dir"
			end
			execute "source ~/.rvm/scripts/rvm && rvm use 2.1.3 && cd #{current_path} && bundle exec rake secret > tmp/secret"
    end
	end

	desc 'Start Rails Server'
	task :start_rails_server do
    on roles(:app), in: :sequence, wait: 5 do
			execute "source ~/.rvm/scripts/rvm && rvm use 2.1.3 && cd #{current_path} && ( nohup bundle exec rails server -e #{fetch(:rails_env)} -p 3000 > log/rails_server.log &) && sleep 3 && echo 'Rails Server Started' && ps x", :pty => true
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
