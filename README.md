# Rails AWS

Tooling and templates for instantiating production and development environments in AWS.

## Usage

### DNS/Domains
* [GoDaddy Domain?](http://stackoverflow.com/questions/17568892/aws-ec2-godaddy-domain-how-to-point)
* create a Route 53 Hosted Zone
	* with name: yourdomain.com
	* after creation, view recordsets
	* in the NS record are 4 servers in the Value box
* point nameservers in your registrarr
	* go to your registrars website
	* set the 4 nameservers to your domain

### Gem Alone: to Gemfile
* gem 'rails-aws'
* gem 'capistrano', '~> 3.1.0'
* gem 'capistrano-bundler', '~> 1.1.2'
* gem 'capistrano-rails', '~> 1.1.1'
* gem 'capistrano-rvm', github: "capistrano/rvm"k

### Project Setup: from dev/coordination server

This is meant to be run on a dev or production server.

Or from a thumbdrive where you are able to run rails and have a local dashboard.

Get the rails-aws project.

The directory naming is based on the idea of having one instance of this for each application you deploy.

```
	# this is meant to deploy [your-app-name] repo
  ~/ git clone git@github.com:smith11235/rails-aws.git rails-aws-[your-app-name]
```

Build the ruby environment.  May require sudo.

```
  sh build_ruby_env.sh
  source load_ruby_env.sh
  bundle install 
```

Execute the rails-aws generator.

```
  bundle exec rails g rails_a_w_s:setup
	-> will ask for repo_url 
	  - example: git@github.com:smith11235/rails-aws.git
		- clone url for ssh access
```

Default settings can be modified later in **config/rails-aws.yml** but is not advised.

### Protected Keys

AWS Host Keys are kept by default in config/branch/[branch]/private.key files.

And deploy keys for your repository are in config/deploy_key/[application]_id_rsa(.pub) files.

For your git deploy key, you can edit **config/rails-aws.yml** to specify an alternate location.

You also need to manually add the **config/deploy_key/[application]_id_rsa.pub contents to the github repo.

This is explained in [Git Deploy Keys](lib/rails-aws/get_deploy_keys.md)

### Stack Management

```
  rake aws:check_setup
  rake aws:create_stack[branch_name]
  rake aws:delete_stack[branch_name]

  rake aws:status
  rake aws:stack_status[branch_name]

  rake aws:cap_deploy[branch_name]
  rake aws:cap_start[branch_name]

  rake aws:login[branch_name]

  tail log/development.log
```

## Try breifly: production environment
- test on dev server, prod should work
	- for figuring out how at least
- add config/deploy/production.rb
	- prob wont work...
- port 3000
- then port 80

## Deploy whisperedsecrets.us
- test gem in another project: whisperedsecrets.us
- figure out route 53
	- secondary ebs file
	- route53.json
		* domain name - add to rails-aws.yml
		* IP from outputs
		* to port 3000 seamlessly?
			- probably not


## Phase: install nginx, open to 80

- nginx setup: https://gorails.com/deploy/ubuntu/14.04

```
  gpg --keyserver keyserver.ubuntu.com --recv-keys 561F9B9CAC40B2F7
  gpg --armor --export 561F9B9CAC40B2F7 | sudo apt-key add -
  
  sudo apt-get install apt-transport-https
  
  sudo sh -c "echo 'deb https://oss-binaries.phusionpassenger.com/apt/passenger trusty main' >> /etc/apt/sources.list.d/passenger.list"
  sudo chown root: /etc/apt/sources.list.d/passenger.list
  sudo chmod 600 /etc/apt/sources.list.d/passenger.list
  
  sudo apt-get update
  sudo apt-get install nginx-full passenger
  
  sudo service nginx start
```

* visit: http://54.165.219.61/

* edit configs

```
sudo vim /etc/nginx/nginx.conf
##
# Phusion Passenger
##
# Uncomment it if you installed ruby-passenger or ruby-passenger-enterprise
##

passenger_root /usr/lib/ruby/vendor_ruby/phusion_passenger/locations.ini;

	passenger_ruby /home/ubuntu/.rvm/rubies/ruby-2.1.3/bin/ruby;

```

* restart: ```sudo service nginx restart```


* then routing

```
@domain_name = "partyshuffle.com"
@deploy_user = "ubuntu"

sudo vim /etc/nginx/sites-enabled/default
server {   
	listen 80;   
	server_name 54.165.219.61; 
  rails_env    development;  
	passenger_enabled on;   
	root /home/ubuntu/rails-aws/RailsAws/public; 
  # redirect server error pages to the static page /50x.html  
	error_page   500 502 503 504  /50x.html;
  location = /50x.html {
      root   html;
  }
}
```

## Phase
- rake aws:check_setup (rails-aws.yml)
  - and clean up documentation




* then:
	* ```
			mkdir /home/ubuntu/rails-aws/RailsAws/tmp
			touch /home/ubuntu/rails-aws/RailsAws/tmp/restart.txt
		```

* visit: http://54.165.219.61/
* visit: http://54.165.219.61:3000 # rails


* process: https://gorails.com/deploy/ubuntu/14.04
	* install everything as ubuntu
	* manually execute install getting process down
	* rails server -e development -p 3000
* website access

* install with cloud-init

```
  "yum -y install gcc-c++ make","\n",
  "yum -y install mysql-devel sqlite-devel","\n",
  "yum -y install ruby-rdoc rubygems ruby-mysql ruby-devel","\n",
	"bundle install", "\n",
  "rails new myapp","\n",
  "cd myapp","\n",
  "rails server","\n",
```

## Phase: partyshuffle v1
* partyshuffle git codebase installed, development

## Phase: RDS 
* snapshot of target database
  * mysql/postgres as per current db
  * db from a snapshot: parameter
* access from rails

## Phase: Additional AWS Resources
* EC2:
  * resque: 
  	* resque-worker
  	* redis
	* push
  	* private-pub
	* app:
		* both resque + private pub
  * web: 
  	* rails server through passenger 
	* uber: everything on one server


## Dashboard
* what do i have
* details rake task displayed
* bootstrap
* format:
	* each top level section an accordion
		* cloudformation, ec2, ebs, rds
		* tied to a global search?

## Phase: SSL

* nginx config

```
  server {       
    listen         80;
    server_name 54.165.219.61;       
    rewrite        ^ https://$server_name$request_uri? permanent;
  }
```

* enforce_https|ssl

## Phase
- make a security check on startup?
	- for rake, generator, rails, capistrano


## TTL lifetime

To save money, on startup.
Process to delete in background



### Phase: VPC 

### Config Values For Login

File: **/etc/ssh/sshd_config**

```       
  PermitRootLogin no      
  UsePAM no      
  RSAAuthentication yes # default      
  PubkeyAuthentication yes       # default
  ChallengeResponseAuthentication no  # default
  PasswordAuthentication no  # default
``` 