require 'logger'

require 'server_builder/version'
require 'server_builder/multi_io'
require 'server_builder/fog_builder'
require 'server_builder/verifier'

module ServerBuilder
  class Builder
    
    attr_accessor :logger

    def self.run(opts)
      puts "server builder run with #{opts.inspect}"
      if opts.is_a?(Array)
        opts_to_convert = opts
        opts = {'cmd' => opts_to_convert[0]}
        opts_to_convert.shift
        opts_to_convert.each do |el|
          puts "el is #{el}"
          key, val = el.split('=')
          opts.merge!({key => val})
        end
      end
      puts "server builder converted opts #{opts.inspect}"
      case opts['cmd']
      when 'verify'
        builder = Builder.new(opts)
        builder.verify_server(opts)
      when 'ssh'
        builder = Builder.new(opts)
        builder.ssh(opts)
      when 'redis'
        builder = Builder.new(opts)
        builder.redis_server(opts)
      when 'docker_registry'
        builder = Builder.new(opts)
        builder.docker_registry_server(opts)
      when 'jenkins'
        builder = Builder.new(opts)
        builder.jenkins_server(opts)
      when 'app'
        builder = Builder.new(opts)
        builder.app_on_server(opts)
      when 'basics'
        builder = Builder.new(opts)
        builder.basics_on_server(opts)
      when 'build'
        builder = Builder.new(opts)
        builder.build_server(opts)
      when 'stop'
        builder = Builder.new(opts)
        builder.stop_server(opts)
      else
        puts "invalid builder command, run like: server_builder build"
      end
    end

    def initialize(opts = {})
      @host = opts.fetch('host'){ "utils.picoappz.com" }
      @logger = opts.fetch('logger'){ 
        log_file = File.open("logs/server_builder.log", "a")
        Logger.new MultiIO.new(STDOUT, log_file)
      }
    end

    def redis_server(opts = {})
      ssh(:execute => 'docker run -d -p 6379:6379 dockerfile/redis')
    end

    def basics_on_server(opts = {})
      logger.info ssh(:execute => "sudo apt-get -y update")
      logger.info ssh(:execute => "sudo apt-get install -y git emacs wget curl ")
    end

    def install_docker_to_registry(opts = {})
      
      logger.info ssh(:execute => "mkdir -p /home/ubuntu/apps")
    end

    # depends on docker registry
    # depends on basics_on_server
    def app_on_server(opts = {})
      repo_url  = opts['repo_url']
      raise "use public accessiable git like https not git@ which asks for auth" if repo_url.match(/git@/)
      repo_name = repo_url.split('/').last.gsub('.git','')
      app_dir   = "/home/ubuntu/apps/#{repo_name}"
      logger.info ssh(:execute => "mkdir -p /home/ubuntu/apps")
      logger.info ssh(:execute => "mkdir -p /home/ubuntu/apps")
      logger.info ssh(:execute => "git clone #{repo_url} #{app_dir}")
      logger.info ssh(:execute => "cd #{app_dir} && docker build -t #{repo_name} .")
      logger.info ssh(:execute => "docker run -d #{repo_name}")
    end

    def jenkins_server(opts = {})
      # could keep this around, but docker jenkins doesn't support dockerized builds
      # ssh(:execute => 'docker run -p 8080:8080 -d bacongobbler/jenkins')
      
      cmds = [
              "wget -q -O - http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key | sudo apt-key add -",
              "sudo sh -c 'echo deb http://pkg.jenkins-ci.org/debian binary/ >   /etc/apt/sources.list.d/jenkins.list'",	
              "sudo apt-get update -y",
"sudo DEBIAN_FRONTEND=noninteractive apt-get -y  install jenkins",
              "sudo mkdir /home/jenkins/",
              "sudo chmod +xr /home/jenkins/",
              "sudo usermod -a -G docker jenkins",
              "sudo wget -q -O - http://mirrors.jenkins-ci.org/war-stable/latest/jenkins.war > /tmp/jenkins.war",
              "sudo cp /tmp/jenkins.war /home/jenkins/",
              "sudo curl https://ci.jenkins-ci.org/jnlpJars/jenkins-cli.jar > /tmp/jenkins-cli.jar",
              "sudo cp /tmp/jenkins-cli.jar /home/jenkins/",
"sudo chown jenkins:docker /home/jenkins/jenkins.war",
              "sudo chown jenkins:docker /home/jenkins/jenkins-cli.jar",
              "curl  -L http://mirror.xmission.com/jenkins/updates/update-center.json | sed '1d;$d' | curl -X POST -H 'Accept: application/json' -d @-  http://127.0.0.1:8080/updateCenter/byId/default/postBack",
              "sudo -Hu jenkins java -jar /home/jenkins/jenkins-cli.jar -s http://127.0.0.1:8080/ safe-restart",
              "sleep 35",
              "sudo -Hu jenkins java -jar /home/jenkins/jenkins-cli.jar -s http://127.0.0.1:8080/ install-plugin Git; true",
              "sudo -Hu jenkins java -jar /home/jenkins/jenkins-cli.jar -s http://127.0.0.1:8080/ safe-restart; true"
             ]
      cmds.each do |cmd|
        logger.info ssh(:execute => cmd)
      end
    end

    def docker_registry_server(opts = {})
      ssh(:execute => 'docker run -d -p 5000:5000 samalba/docker-registry')
    end

    def ssh(opts = {})
      # use vagrant ssh to recent vagrant built server
      if opts[:execute]
        logger.info "connecting to server to run: #{opts[:execute]}"
        `cd config/docker_vagrant && vagrant ssh --command '#{opts[:execute]}'`
      else
        logger.info "connecting to server..."
        Kernel.exec("cd config/docker_vagrant && vagrant ssh")
      end
    end

    def stop_server(opts = {})
      logger.info "building a base docker server..."
      # use vagrant to install docker on EC2 with offical docker vagrant script
      logger.info `cd config/docker_vagrant && vagrant halt`
    end
    
    def build_server(opts = {})
      logger.info "building a base docker server..."
      # use vagrant to install docker on EC2 with offical docker vagrant script
      logger.info `cd config/docker_vagrant && vagrant up --provider=aws`
      
      # use fog and bootstrap
      # fog_builder = FogBuilder.new(opts, logger)
      # fog_builder.build
    end

    def verify_server(opts = {})
      verifier = Verifier.new(opts, logger)
      verifier.verify
    end

  end
end
