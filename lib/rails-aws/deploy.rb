# config valid only for Capistrano 3.1
lock '3.2.1'

%w( application repo_url branch branch_secret deploy_key rails_env dbtype dbhost dbpassword ).each do |setting|
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
	desc 'Publish DB Settings to App Hosts'
	task :publish_db_settings do
    on roles(:app), in: :sequence, wait: 5 do
			if fetch( :dbtype ) != 'sqlite'
				db_file = File.join( release_path, "config/database.yml" )
  			execute "sed -i 's/dbhost/#{fetch( :dbhost )}/' #{db_file}"
  			execute "sed -i 's/dbpassword/#{fetch( :dbpassword )}/' #{db_file}"
			end
		end
	end

	before 'deploy:migrate', 'deploy:publish_db_settings'

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

	desc 'Publish Rails Secret, branch specific'
	task :publish_secret do
    on roles(:app), in: :sequence, wait: 5 do
			execute( "cd #{current_path} && mkdir tmp" ) rescue nil
      upload! fetch( :branch_secret ), File.join( current_path, 'tmp/secret' ) 
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
