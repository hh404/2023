This is my readMe.
New
dd
rr
mkdir -p .tuist/templates/Configuration
cd .tuist/templates/Configuration

echo "name: Configuration" > template.yml
echo "description: A template for a configuration file" >> template.yml

cd ../../..

tuist template generate Configuration --name MyConfiguration

echo "ruby_url=https://cache.ruby-china.com/pub/ruby" > ~/.rvm/user/db

sudo update-alternatives --install /usr/bin/ruby ruby /usr/local/bin/ruby 1
sudo update-alternatives --set ruby /usr/local/bin/ruby


sudo cp /usr/bin/ruby /usr/bin/ruby_backup

sudo cp /usr/local/bin/ruby /usr/bin/ruby


HOMEBREW_BOTTLE_DOMAIN=https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles brew install openssl@3.2.0

HOMEBREW_BOTTLE_DOMAIN=https://mirrors.ustc.edu.cn/homebrew-bottles brew install openssl@3.2.0

brew install openssl@3.2.0 -v

