# Phusion Passenger Install Summary

[Source Documentation](https://www.phusionpassenger.com/documentation_and_support)

```
# add repo
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 561F9B9CAC40B2F7
# install prereq support packages
apt-get install apt-transport-https ca-certificates

# create sources file
touch /etc/apt/sources.list.d/passenger.list
echo 'deb https://oss-binaries.phusionpassenger.com/apt/passenger trusty main' >> /etc/apt/sources.list.d/passenger.list
