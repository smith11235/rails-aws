# Development Plan

## Phase: Db Data
* add a scaffold:
	* be rails g scaffold branch name 
	* /branch
		* add button/route to create 100 branches
		* route: collection test_batch

## Phase: Setup Generator Update
* for rails-aws.yml, aws-keys.yml
	* load existing values, ask if update
* ask for domain and domain_branch

## Phase: RDS - From Snapshot

* rake aws:create_dbsnapshot
	* search rds instances...
		* ask for selection? based on Name?
	* create snapshot
	* log config/branch/:branch/db_snapshot_id

* rake aws:stack_create
	* if db_type != :sqlite
		* if branch_dir/db_snapshot_id exists
			* use it to source the db

* db dependency on rails secret?

## Phase: partyshuffle v1

* partyshuffle git codebase installed
* with db history

## Push server on app server
* rails-aws.yml setting

* expect it to be present in Rails build
	* expect default config?

* security group port for push
* cap logic starts it up

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
