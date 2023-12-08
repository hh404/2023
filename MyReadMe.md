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
