# functions and variables
#unset $(set | awk -F"[= ]" '/^\w*(RUBY|GEM|IRB|rvm|gem|rubies)\w*(=| \(\))/ {print $1}')
 
# aliases
#unalias $(alias | awk -F"[= ]" '/rvm/ {print $2}')
 
# others
#unset cd file_exists_at_url popd pushd
 
# PATH
# export PATH=$(echo $PATH | tr ':' '\n' | grep -v rvm | tr '\n' ':' | sed 's/:$//')

rm -rf .rvm
export rvm_path=`pwd`/.rvm
\curl -sSL https://get.rvm.io | bash -s stable --ruby --gems=bundler --ignore-dotfiles

source $rvm_path/scripts/rvm
rvm install 2.1.3
rvm use 2.1.3 --default
gem install bundler
bundle install
