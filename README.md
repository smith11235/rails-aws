# Rails AWS

Tooling and templates for instantiating many consistent Rails environments in AWS.

Allows rapid, uniform, multi branch testing and production deployment with uniform process and standard tools.

If it is not running on your local machine, its a production environment.

Easily, in minutes.  Focus on the code that matters, that your clients care about.

Manage any number of Rails deployments.

Easily.  On your local development machine. From a thumbdrive even.

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

### Gem or Application

Add the **rails-aws** gem to your Gemfile.

Run the migration.


#### Gem Alone: to Gemfile

Add to your projects Gemfile:

```
  gem 'rails-aws', github: "smith11235/rails-aws"
```

### Run rails-aws Rails Generator

Execute the supplied generator and provide needed information.

```
  bundle exec rails g rails_a_w_s:setup
	-> main thing it will ask for: repo_url 
	  - example: git@github.com:smith11235/rails-aws.git
		- clone url for ssh access
```

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

#### Tweaking the Config 

Default settings can be modified later in **config/rails-aws.yml**.

This is not advised. Other than **domain** settings.

### Protected Keys

These are all added to your .gitignore.  But they are good to be aware of.

AWS Host Keys are kept by default in config/branch/[branch]/private.key files.

Deploy keys for your repository are in config/deploy_key/[application]_id_rsa(.pub) files.

For your deploy key, you can edit **config/rails-aws.yml** to specify an alternate location.

Managing deploy keys can be viewed here: [Deploy Keys](lib/rails-aws/git_deploy_keys.md)

### Stack Management

```
  # create a stack and start server
  rake aws:stack_create[branch_name] aws:cap_deploy[branch_name]
  # if you have a domain
  rake aws:domain_create[branch_name]

  # teardown a server
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
* edit your config/rails-aws.yml file
	* set domain to: example.com
	* set domain_branch to 'master'
		* or whatever you want to pair this domain to
* if you are setting up repeatedly this domain
	* it can take a couple minutes for the routing to be updated

## Development Phases

### Phase: Fix secret handling
	* run build to test
	* r aws:stack_login[secret]
		* cat rails-aws/current/tmp/secret
	* r aws:stack_delete[secret]

### Phase: RDS - Blank
* what is PS running
* new db to start
* access from rails (in whispered secrets, have, relationships)

* whisperedsecrets: ordered setup
	* gem 'haml-rails' and setup
	* gem 'boostrap-sass', '~> 3.1.0' and setup
	* gem 'devise' and setup: http://railscasts.com/episodes/209-introducing-devise
	* remove development phases from public/index
	* mv public/index.html app/views/relationships/index.html.erb
		* has_one :so, :class_name => "User", :foreign_key => " :so2: has_one :so1, :class =
	* root 'relationships#index'
	* rails g scaffold missive missive so 


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