# functions and variables
#unset $(set | awk -F"[= ]" '/^\w*(RUBY|GEM|IRB|rvm|gem|rubies)\w*(=| \(\))/ {print $1}')
 
# aliases
#unalias $(alias | awk -F"[= ]" '/rvm/ {print $2}')
 
# others
#unset cd file_exists_at_url popd pushd
 
# PATH
# export PATH=$(echo $PATH | tr ':' '\n' | grep -v rvm | tr '\n' ':' | sed 's/:$//')

export rvm_path=`pwd`/.rvm
rm -rf $rvm_path

gpg --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3
\curl -sSL https://get.rvm.io | bash -s stable --ruby --gems=bundler --ignore-dotfiles

source $rvm_path/scripts/rvm
rvm install 2.1.4
rvm use 2.1.4 --default
gem install bundler
bundle install
