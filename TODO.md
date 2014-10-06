# Development Plan

## Phase: Domain Replacement
* problem:
	* browsers seem to block the change for a while
		* or caching of ip route is happening sompewhere

* document new release branch: release-1.0.1
	* previously deployed branch 'release-1.0.0'
	* git checkout master
	* git checkout -b release-1.0.1
	* git push origin release-1.0.1
	* r aws:create_stack[release-1.0.1] aws:cap_deploy[release-1.0.1] 
	* test site: wget IPADDRESS/route.json
	* set config/rails-aws.yml::domain_branch to release-1.0.1
	* r aws:domain_update
	* wget rails.com/branches.json
	* test website
	* r aws:delete_stack[release-1.0.0]
	* wget rails.com/branches.json
	* test website
	* r aws:delete_stack[release-1.0.1]


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
