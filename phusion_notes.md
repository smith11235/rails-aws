# Phusion Passenger Install Summary

[Source Documentation](https://www.phusionpassenger.com/documentation_and_support)

## Add to cloud-init setup

```
  # add repo
  apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 561F9B9CAC40B2F7
  # install prereq support packages
  apt-get install apt-transport-https ca-certificates
  
  # create sources file
  touch /etc/apt/sources.list.d/passenger.list
  echo 'deb https://oss-binaries.phusionpassenger.com/apt/passenger trusty main' >> /etc/apt/sources.list.d/passenger.list
  chown root: /etc/apt/sources.list.d/passenger.list
  chmod 600 /etc/apt/sources.list.d/passenger.list
    
  apt-get update

	apt-get install nginx-extras passenger

	# /etc/nginx/nginx.conf uncomment passenger_root and passenger_ruby

# sed commands...
somewhere... passenger_ruby /home/deploy/.rvm/rubies/ruby-2.1.3/bin/ruby;
http {
	echo "passenger_root `/user/bin/passenger-config --root`;" >> /etc/nginx/nginx.conf
	....
}

	service nginx restart

	gem install passenger

	apt-get remove nginx nginx-full nginx-light nginx-naxsi nginx-common

	passenger-install-nginx-module

```
