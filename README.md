# ServerBuilder
===

After working on building servers with a verity of techniques. I decided that really many of the various options aren't better than one another but what is really important is scriptability, repeatability, verifications, and recorded process.

This project aims to add a nice command like interface in front of various scripts. To provide a consistent interface even if varying technologies are used. Also, to make the interactions simple and user friendly.

## Installation

Add this line to your application's Gemfile:

    gem 'server_builder'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install server_builder
    
    bin/server_builder verify statsd=true graphite=true logstash=true elasticsearch=true

### Expected environment variables and configuration

notes move all the env out of profile etc and into a .gitignore dotenv file and make recommendations on how to setup for user installed machines.

## Usage

To get help

	server_builder help

To build a blank server run

	server_builder build # =>

To build a server with services and verify the services are functioning run

	server_builder build redis docker_registry elastic_search verify
	
To add services to an existing service run

	server_builder redid docker_registry host=hostname.whatever.com
	
To create verify services on a server run

	server_builder verify host=hostname.whatever.com
	
To connect to a server over ssh run

	server_builder ssh host=hostname.whatever.com

To execute a command on a remote server run

	server_builder ssh host=hostname.whatever.com execute='docker run -d -p 3306:3306 orchardup/mysql'

## Links

* [vagrants as digital ocean provider](https://www.digitalocean.com/community/articles/how-to-use-digitalocean-as-your-provider-in-vagrant-on-an-ubuntu-12-10)
* [assigning ports with Docker](http://stackoverflow.com/questions/18497564/assigning-vhosts-to-docker-ports)
* [how to scale docker in production](http://stackoverflow.com/questions/18285212/how-to-scale-docker-containers-in-production)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
