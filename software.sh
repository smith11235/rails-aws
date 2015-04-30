sudo -i wget --no-check-certificate https://raw.githubusercontent.com/bcwik9/ScriptsNStuff/master/setup_dev_server.sh 
sudo -i sh setup_dev_server.sh

configure /opt/nginx/conf/nginx.conf

  server {
    listen 80; 
    server_name smith.brickworksoftware.com;
    location / { 
      proxy_pass http://localhost:3000;
      proxy_set_header   X-Real-IP $remote_addr;
      proxy_set_header   Host      $http_host;
    }
  }

  server {
    listen 80;
    server_name mail.smith.brickworksoftware.com;
    location / {
      proxy_pass http://localhost:1080;
      proxy_set_header   X-Real-IP $remote_addr;
      proxy_set_header   Host      $http_host;  
    }
  }


sudo /opt/nginx/sbin/nginx

wget http://download.redis.io/redis-stable.tar.gz
tar xvzf redis-stable.tar.gz
cd redis-stable
make
sudo make install
nohup redis-server &> redis-server.log &
cd
sudo apt-get ImageMagick libmagickwand-dev phantomjs -y  # a few missing dependencies


ssh-keygen -t rsa -C "your_github_email@example.com"
# copy contents of ~/.ssh/id_rsa.pub
# add it to your github account ssh keys
git config --global user.name "smith11235"
git config --global user.email smith11235@gmail.com
ssh -T git@github.com
exit

git clone git@github.com:BrickworkSoftware/brickwork_app.git
bundle install --deployment

setup your rds params config/application.yml

RDS_PORT: "5432"
RDS_DB_NAME: railsapp
RDS_USERNAME: railsapp
RDS_PASSWORD: 5aed99058d873716ebec7111b2e679dc 
RDS_HOSTNAME: rd9u5dhkwgiziy.cpk572oso19t.us-east-1.rds.amazonaws.com # changeme
  bundle exec rake db:setup

tmux new -s brickworks
> source build/dev-smith.sh
> bundle exec rails server
> bundle exec sidekiq -C config/sidekiq.yml
> bundle exec mailcatcher
> ctrl-b d
exit






##########
apt-get update
apt-get upgrade -y
export package_list='git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev python-software-properties libgdbm-dev libncurses5-dev automake libtool bison libffi-dev mysql-client libmysqlclient-dev'
apt-get install $package_list -y

# set login perms
sed -i 's/PermitRootLogin\\swithout-password/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/UsePAM\\syes/UsePAM no/' /etc/ssh/sshd_config
service ssh restart

# NGINX
gpg --keyserver keyserver.ubuntu.com --recv-keys 561F9B9CAC40B2F7
gpg --armor --export 561F9B9CAC40B2F7 | sudo apt-key add -

apt-get install apt-transport-https -y
echo 'deb https://oss-binaries.phusionpassenger.com/apt/passenger trusty main' >> /etc/apt/sources.list.d/passenger.list

chown root: /etc/apt/sources.list.d/passenger.list
chmod 600 /etc/apt/sources.list.d/passenger.list

apt-get update -y

apt-get install nginx-full passenger -y

service nginx start 