# Development Plan

## Phase: Domain Replacement
* rake aws:domain_repoint[branch,maintenance_branch]
	* change: domain management separate from branch
		* remove branch parameter
			* get target IP by using domain_branch
		* domain json should be saved in:
			* config/[application]_domain.json
			* mv config/branch/master/domain.json to config/rails-aws_domain.json
		* rake aws:domain_create 
			* domain stack name should not have branch
			* uses settings to determine which isntance to apply it to
		* rake aws:domain_update # updates the existing record

	* new release branch: release-x.y.z
		* create hardware stack, cap-deploy
		* aws:domain_update
		* delete prior branch stack
	* cleaner workflow
		* if db writes are frozen, a maintanance stack
		* and a status message in the banner
		* this is the best possible without a vpc
			* independent vpc with security groups and subnets
				* so db can be managed in different ways

## Phase: partyshuffle v1
* export RAILS_ENV=production
* r aws:stack_delete[rds,no_error] aws:stack_create[rds] aws:cap_deploy[rds]
* partyshuffle git codebase installed
* with db history
	* turn dbpassword into dbinfo
		* default user/schema/password
		* setable by user for pulling in prior db
	* migration process:
		* can i login to server to run rake?
		* http://stackoverflow.com/questions/11656080/rake-task-to-backup-and-restore-database*
		* rake db:backup
		* mv file to encrypted zip
		* mv zip to public/

## VPC: Minimal Downtime
* if we have vpc
* if we update it with a new substack
* corun two stacks internally
* domain points to gateway
* gateway points to determined current production host
* repointed when ready
* db hosts are easily reused or rebuilt

## Push server on app server
* rails-aws.yml setting
* cap logic starts it up
* security group port for push needed.....

## Phase: Setup Generator Update

* for rails-aws.yml, aws-keys.yml, db-type
	* load existing values, <enter> uses default
* ask for domain and domain_branch

## Phase: Additional AWS Resources
* EC2:
	* push
  	* private-pub
  * resque: 
  	* resque-worker
  	* redis

## Phase: dbpassword_file in gitignore
* add to generator
* temporarily its behind ssh access and security group

## Phase: Update Stack
- task: 
	- cap_generate_secret: if file doesnt exist
	- cap_start_rails_server: touch tmp/restart.txt
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



## Phase: VPC 

# Application Setup (Not as recommended)

The directory name for the clone is based on a **1 rails-aws <=> 1 application to deploy** relationship.

Later this will be 1 to many for easy cloud management from your local machine or rails-aws.com.

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

## Config Values For Login

File: **/etc/ssh/sshd_config**

```       
  PermitRootLogin no      
  UsePAM no      
  RSAAuthentication yes # default      
  PubkeyAuthentication yes       # default
  ChallengeResponseAuthentication no  # default
  PasswordAuthentication no  # default
``` 
