export rvm_path=`pwd`/.rvm
\curl -sSL https://get.rvm.io | bash -s stable --ruby
source $rvm_path/scripts/rvm
gem install bundler
bundle install
