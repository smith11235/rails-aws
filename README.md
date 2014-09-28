# Rails AWS

Tooling and templates for instantiating production and development environments in AWS.

Allows rapid, uniform, multi branch testing and production deployment with uniform environments.

## Usage

### Have a Domain Name Ready?
* [GoDaddy Domain?](http://stackoverflow.com/questions/17568892/aws-ec2-godaddy-domain-how-to-point)
* create a Route 53 Hosted Zone
	* with name: yourdomain.com
	* after creation, view recordsets
	* in the NS record are 4 servers in the Value box
* point nameservers in your registrarr
	* go to your registrars website
	* set the 4 nameservers to your domain

### Gem or Application

You can either clone the rails-aws project and run the included rails project.

Or use just the gem within your rails project.

Either way deployment is expected to run from a secure location.

Or your local development machine.

Or from a thumdrive will all your keys safely protected.

#### Application Setup

The directory name for the clone is based on a **1 rails-aws <=> 1 application to deploy** relationship.

Later this will be 1 to many for easy cloud management from your local machine.

```
	# where [your-app-name] is your repohost.com/username/your-app-name
	# example
  ~/ $ git clone git@github.com:smith11235/rails-aws.git rails-aws-[your-app-name]
```

Build the rvm/ruby environment.  May require sudo for needed ruby libraries.

```
  sh build_ruby_env.sh
  source load_ruby_env.sh
```

#### Gem Alone: to Gemfile

Add to your projects Gemfile:

```
	gem 'rails-aws', github: "smith11235/rails-aws"
```

### Run rails-aws Rails Generator

Execute the supplied generator and provide needed information.

This will:

* setup .gitignore
* setup aws access key file: config/aws-keys.yml
	* blocked in .gitignore
* setup your deployment preferences: config/rails-aws.yml
	* revisioned.  can be edited.
* adds capistrano to your project: 
	* Capfile, config/deploy.rb, config/deploy/[production|development].rb
* modifies config/secret.yml to use host/branch specific secrets
	* setup by deploy time logic
* sets up a deploy key for pulling your project from your repository

```
  bundle exec rails g rails_a_w_s:setup
	-> main thing it will ask for: repo_url 
	  - example: git@github.com:smith11235/rails-aws.git
		- clone url for ssh access
```

#### Tweaking the Config 

Default settings can be modified later in **config/rails-aws.yml**.

This is not advised.

### Protected Keys

AWS Host Keys are kept by default in config/branch/[branch]/private.key files.

And deploy keys for your repository are in config/deploy_key/[application]_id_rsa(.pub) files.

For your git deploy key, you can edit **config/rails-aws.yml** to specify an alternate location.

You also need to manually add the **config/deploy_key/[application]_id_rsa.pub contents to the github repo.

This is explained in [Git Deploy Keys](lib/rails-aws/get_deploy_keys.md)

### Stack Management

```
	# create a stack and start server
  rake aws:stack_create[branch_name] aws:cap_deploy[branch_name]

	# teardown a server
  rake aws:stack_delete[branch_name]

	# status of stacks
  rake aws:status
  rake aws:stack_status[branch_name]

	# logging into hosts as deploy user
  rake aws:stack_login[branch_name]

	# getting your execution information
  tail log/development.log # or production as appropriate
```

## Phase: Deploy whisperedsecrets.us

- test gem in another project: whisperedsecrets.us

- figure out route 53
	- secondary ebs file
		- http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/quickref-route53.html
	- route53.json
		* hostedzonename - add to rails-aws.yml
			* whisperedsecrets.us
		* IP from outputs
		* to port 3000 seamlessly?
			- probably not

## Phase: prodport 
- first try:  https://gorails.com/deploy/ubuntu/14.04
- then try: https://www.phusionpassenger.com/documentation/Users%20guide%20Nginx.html
	- [PhusionPassenger](phusion_notes.md)

- removing deploy:start_rails_server, passenger should handle this...	
- config/environments/production.rb
  -	reset config.serve_static_assets = false


```
  gpg --keyserver keyserver.ubuntu.com --recv-keys 561F9B9CAC40B2F7
  gpg --armor --export 561F9B9CAC40B2F7 | sudo apt-key add -
  
  apt-get install apt-transport-https

  echo 'deb https://oss-binaries.phusionpassenger.com/apt/passenger trusty main' >> /etc/apt/sources.list.d/passenger.list
  chown root: /etc/apt/sources.list.d/passenger.list
  chmod 600 /etc/apt/sources.list.d/passenger.list
  
  apt-get update
  apt-get install nginx-full passenger
  
  service nginx start # IP-default page is available at this point

	# /etc/nginx/nginx.conf
 	#(maybe) passenger_root /usr/lib/ruby/vendor_ruby/phusion_passenger/locations.ini;
 	passenger_ruby /home/deploy/.rvm/rubies/ruby-2.1.3/bin/ruby;

  service nginx restart 

	create: /etc/nginx/sites-enabled/default
@domain = RailsAws.domain # default to IP

  server {
          listen 80 default_server;
          listen [::]:80 default_server ipv6only=on; # possibly remove default server stuff
  
          server_name <%= RailsAWS.domain %>;
          passenger_enabled on;
          rails_env    <%= RailsAWS.environment %>;
          root         /home/deploy/<%= RailsAWS.application %>/current/public;
  
          # redirect server error pages to the static page /50x.html
          error_page   500 502 503 504  /50x.html;
          location = /50x.html {
              root   html;
          }
  }
```

## Phase: partyshuffle v1
* partyshuffle git codebase installed

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

## Phase
- rake aws:check_setup (rails-aws.yml)
  - and clean up documentation


## Dashboard
* what do i have
* details rake task displayed
* bootstrap
* format:
	* each top level section an accordion
		* cloudformation, ec2, ebs, rds
		* tied to a global search?

## Phase: SSL

* setup ssl requirements
* nginx config

```
  server {       
    listen         80;
    server_name 54.165.219.61;       
    rewrite        ^ https://$server_name$request_uri? permanent;
  }
```

* enforce_https|ssl
	* config/environments/production.rb: has directive
	* or add to application controller

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