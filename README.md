# Rails AWS

Tooling and templates for instantiating production and development environments in AWS.

## Usage

### Gem Alone: to Gemfile
* gem 'rails-aws'
* gem 'capistrano', '~> 3.1.0'
* gem 'capistrano-bundler', '~> 1.1.2'
* gem 'capistrano-rails', '~> 1.1.1'
* gem 'capistrano-rvm', github: "capistrano/rvm"k

### Project Setup
* clone repo
* sh build_ruby_env.sh
* bundle install --deployment
* bundle exec rails g rails_a_w_s:setup

### Config Values
    ```       
      PermitRootLogin no      
      UsePAM no      
      RSAAuthentication yes       
      PubkeyAuthentication yes       
      ChallengeResponseAuthentication no  
      PasswordAuthentication no  
    ``` 

### Stack Management
* rake aws:[create|delete]_stack[branch_name]
* rake aws:status
* tail log/development.log

## Phase: Capistrano


## Phase: install nginx
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

## Phase 3
* rake aws:access_info[branch_name]
	* start and stop commands
* partyshuffle git codebase installed

## SSL

```
server {       
  listen         80;
  server_name 54.165.219.61;       
  rewrite        ^ https://$server_name$request_uri? permanent;
}
```

## Dashboard
* what do i have
* details rake task displayed
* bootstrap
* format:
	* each top level section an accordion
		* cloudformation, ec2, ebs, rds
		* tied to a global search?

## Phase 3
* snapshot of target database
* create RDBS from snapshot

## Phase 4
* Rails setup

## Phase
* also push server port?
* also push redis/resque?

## Shutdown/startup
* ttl/cost savings

## Phase 3
* cloud-init:
	* rails install
	* git branch
	* Gemfile

## Phase 4
* external access at http://[IP] 

## Phase 5
* domain name to ip in route 53

## Phase 6
* subnets
* vpc

## Phase 7
* ssl support

## Phase 6
* app server
	* redis
	* resque?
	* push server

## AWS Resources
* Key
* VPC
* subnet:
	* allow 22 on all hosts
	* key auth only
	* port 80/443 on web
	* internal networking open

* RDS: 
	* mysql as per current
	* db from a snapshot: parameter

* EC2:
	* service: 
		* resque-worker
		* private-pub
	* web: 
		* rails server through passenger 

## Deployment Process
* generate a [Key Pair](http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/cfn-console-create-keypair.html)
* take snapshot of current rds
* run template with correct param values
* test
* migrate route 53

## AWS Example

[example](http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/cloudformation-waitcondition-article.html)