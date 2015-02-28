# Rails Aws

Manage all your projects.
Manage each branch of your project.
Manage them locally for easy key management.
Integrate with Lastpass and 1Password.
Versioned, revision controlled hardware and software.
Local server provides dashboard for management.
Use easy pro stacks for the best modern website possible.
All based on AWS for easy infinite expansion.
Run a development server.
This app is what runs on port 80.

## Priorities

### V1

* multi project settings file
	* configurable stack definition files

* rails-aws gem can be used in 'development' environment to deploy production
	* design point:
		* rake tasks vs generators
			* generators can be more interactive and guided
		  * i think rake tasks should be turned to generators

* rspec tests for critical logic

### V2

* rails-aws UI can be used locally (rails server -p 3000)
	* no user accounts or shared hosted instances

### V3

* with user accounts and real security
* a hosted and shared instance could be made
* allowing a team to share simple control
	
## Config File

```
  ---
	default: # full service micro instance
	 app:            t1.micro
	 database:       local
	 sidekiq_redis:  local
	 faye:           local

	for-fun-project:
	  git-repo: https://github.com/wicked/wicked.git
    development: 
  	 &default
    production: 
  	 &default

	my-cool-project:
	  git-repo: https://github.com/cool/cool.git

  	# micro environments, super cheap
    development: 
  	 &default
  	test:
  	 &default
  
  	demo:            # shared server for secondary services
  	 app:            m3.small
  	 database:       t2.medium
  	 sidekiq_redis:  shared::t2.medium
  	 faye:           shared::t2.medium
  
  	production:      # all dedicated hardware
  	 instance:       c3.medium
  	 database:       m3.medium
  	 sidekiq_redis:  m3.small
  	 faye:           m3.small
```

## Define your own stack

At any layer of the config set cloudformation_template to another file path.

## Target Initial Stacks

* Rails + RDS
  * + sidekiq, redis, faye.

* Nodejs/Ghost-blog

## Models

* deployment
	* app
	* branch 
	* last_template

## View
* new stack
* current stacks
* create stack
	* real time communication
