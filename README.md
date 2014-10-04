# Rails AWS

[Source on Github](https://github.com/smith11235/rails-aws)

Rails-Rake tasks for instantiating consistent Rails environments in AWS.

And having as many branches as you need.  For as low cost as possible.

Incorporating db, push-server, and worker server integration.

Allows rapid, uniform, multi branch testing in strict-production environments with uniform process.

Assign domains to your master or your release branches automatically..

Run it from your computer, a server, or a thumbdrive.

## Software

* Ubuntu 14.04
* Nginx + Passenger
* RVM
* Ruby (2.1.3) 
* Rails
* Capistrano

* Eventually (as what good site is not hooked up with all the goods):
	* RDS (mysql/postgres) support
	* [Private-Pub Push Server](http://railscasts.com/episodes/316-private-pub?view=comments)
		* ajax/real-time support, but easier
	* [Reque Job Manager](http://railscasts.com/episodes/271-resque)

## Usage

### Someday

Create an account at **http://rails-aws.com**

### Gem 

**./Gemfile**

```
  gem 'rails-aws', github: "smith11235/rails-aws"
```

### Rails Generator

Execute the supplied generator and provide needed information.

```
  bundle exec rails g rails_a_w_s:setup
  # main thing it will ask for: 
  > repo_url 
    - example: git@github.com:smith11235/rails-aws.git
    - clone url for ssh access
	> db type: mysql? or sqlite default
	> aws_access_key
	> aws_secret_key
```

#### What is the generator doing?

* setup .gitignore
* setup aws access key file: config/aws-keys.yml
	* blocked in .gitignore
* setup your deployment preferences: config/rails-aws.yml
	* revisioned.  can be edited.
* setup your config/database.yml file
* adds capistrano to your project: 
	* Capfile, config/deploy.rb, config/deploy/[production|development].rb
* modifies config/secret.yml to use host/branch specific secrets
	* setup by deploy time logic
* sets up a deploy key for pulling your project from your repository

#### config/rails-aws.yml 

Default settings can be modified later in **config/rails-aws.yml**.

And if you have a domain you want to use:

* **domain**: your base url, for which you have a hosted zone setup for.

* **domain_branch**: the branch that will get the domain url.  
  * other branches are presumed development environments
	* this can be 'master' or a release branch name

### Protected Keys

These are all added to your .gitignore.  But they are good to be aware of.

AWS Host Keys are kept by default in config/branch/[branch]/private.key files.

Deploy keys for your repository are in config/deploy_key/[application]_id_rsa(.pub) files.

For your deploy key, you can edit **config/rails-aws.yml** to specify an alternate location.

Managing deploy keys can be viewed here: [Deploy Keys](lib/rails-aws/git_deploy_keys.md)

### Stack Management

```
  # create a stack and start servers
  rake aws:stack_create[branch_name] 
	rake aws:cap_deploy[branch_name]

  # if you have a domain you want assigned
  rake aws:domain_create[branch_name]

  # teardown an environment - save money on testing, always teardown
  rake aws:stack_delete[branch_name]

  # if you have a domain
  rake aws:domain_delete[branch_name]

  # status of stacks
  rake aws:status
  rake aws:stack_status[branch_name]

  # logging into hosts as deploy user
  rake aws:stack_login[branch_name]

  # getting your execution information
  tail log/development.log # or production as appropriate

  # updating your production stack with capistrano
	rake aws:cap_update[branch_name]
```

#### Production Vs Development

Execute the stack management commands with RAILS_AWS=development or RAILS_AWS=production accordingly to deploy those environments.

**Example master branch/domain deployment:**

``` 
  export RAILS_AWS=production
  rake aws:stack_create[master]
  rake aws:domain_create[master] 
  rake aws:cap_deploy[master]
```

#### Have a Domain Name Ready?
* [GoDaddy Domain?](http://stackoverflow.com/questions/17568892/aws-ec2-godaddy-domain-how-to-point)
* create a Route 53 Hosted Zone
	* with name: yourdomain.com
	* after creation, view recordsets
	* in the NS record are 4 servers in the Value box
* point nameservers in your registrarr
	* go to your registrars website
	* set the 4 nameservers to your domain
* create a HostedZone for your domain
  * go to the aws console for route 53
	* create a hosted zone
	* enter your base domain: example.com
* edit your config/rails-aws.yml file
	* set domain to your hosted zone name: example.com
	* set domain_branch to 'master'
		* or whatever you want to pair this domain to
* when deploying a domain, updates can take minutes to be reflected in the browser 
	* rake aws:cap_update instead of tearing down master

## DB Support

You can use sqlite on your web server.

Or you can use mysql on a separate host (greater cost, better performance).

Ensure you have the gems as needed in your Gemfile.

```
  gem 'mysql2'
  gem 'sqlite3'
```

Your **config/database.yml** will be updated by the rails-aws setup generator.

## Development Plan

### Phase: RDS - Blank
	* cloudformation
		* if mysql
			* rds mini config
				* publicaccessible: false
				* DbSecurityGroup:
					* set to ec2-security-group-name
					* allso need account-id (rails-aws.yml setting?)
						* fetchable from api?
			* output: DBIP (or url)

		* rake aws:cap_deploy
			* if RailsAWS.db_type != :sqlite
			* call RailsAWS.set_dbpassword
				* require 'securerandom'
				* random_string = SecureRandom.hex
				* File.open( RailsAWS.dbpassword_file, 'w' ) {|f| f.puts random_string }
			* RailsAWS.dbpassword_file
				* RailsAWS.branch_dir, 'dbpassword'
			* RailsAWS.dbpassword
				* File.open( RailsAWS.dbpassword_file, 'r' ).read.chomp
			* rake cap_cmd: 
				* if db_type != :sqlite
					* dbip=RailsAWS::Cloudformation.outputs["DBIP"]
					* dbpassword=RailsAWS.dbpassword
  		* cap cap_deploy:publish_db_settings (before deploy)
  			* execute "echo 'export dbhost=' >> ~/.bashrc"
  			* execute "echo \"export dbhost='#{RailsAWS.dbpassword}'\" >> ~/.bashrc"
	* access from rails 

### Phase: RDS - Snapshot
* db dependency on rails secret?
* snapshot of target database
* stand up against snapshot

### Phase: partyshuffle v1
* partyshuffle git codebase installed
* view history

### Push server on app server

* rails-aws.yml:
	* push_server: enabled
* expect it to be present in Rails build
	* expect default config?
* security group port for push
* cap logic starts it up

### Phase: Additional AWS Resources
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

### Phase: dbpassword_file in gitignore
* add to generator
* temporarily its behind ssh access and security group

### Phase: Update Stack
- task: 
	- cap_generate_secret: if file doesnt exist
	- cap_start_rails_server: touch tmp/restart.txt
### Phase
- rake aws:check_setup (rails-aws.yml)
  - and clean up documentation


### Dashboard
* what do i have
* details rake task displayed
* bootstrap
* format:
	* each top level section an accordion
		* cloudformation, ec2, ebs, rds
		* tied to a global search?

### Phase: SSL

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

### Phase
- make a security check on startup?
	- for rake, generator, rails, capistrano


### TTL lifetime

To save money, on startup.
Process to delete in background



### Phase: VPC 

## Application Setup (Not as recommended)

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