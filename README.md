# Rails AWS

Tooling and templates for instantiating production and development environments in AWS.

## Usage

### Project Setup
* clone repo
* sh build_ruby_env.sh
* cd RailsAws
* bundle install --deployment
* zues start
* zues rails g rails_a_w_s:setup

### Stack Management
* zeus rake aws:[create|delete]_stack[branch_name]
* zeus rake aws:status
* tail log/development.log

## Phase 2
* root login with key after creation
	* ```ssh -i config/keys/[branch_name].private_key root@ip.add.re.ss```
	* ssh -i config/keys/test.private_key root@54.165.219.61

	```
# base update
sudo apt-get update
sudo apt-get install git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties

# rvm
sudo apt-get install libgdbm-dev libncurses5-dev automake libtool bison libffi-dev
curl -L https://get.rvm.io | bash -s stable
source ~/.rvm/scripts/rvm
echo "source ~/.rvm/scripts/rvm" >> ~/.bashrc
rvm install 2.1.3

rvm use 2.1.3 --default
which ruby && ruby -v
echo "gem: --no-ri --no-rdoc" > ~/.gemrc

# install nginx
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

* get codebase: (capistrano later?)
	* git clone


* process: https://gorails.com/deploy/ubuntu/14.04
	* install everything as root, no sudo
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