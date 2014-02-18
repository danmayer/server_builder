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
      when 'build'
        builder = Builder.new(opts)
        builder.build_server(opts)
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

    def docker_registry_server(opts = {})
      ssh(:execute => 'docker run -d -p 5000:5000 samalba/docker-registry')
    end

    def ssh(opts = {})
      # use vagrant ssh to recent vagrant built server
      if opts[:execute]
        logger.info "connecting to server to run: #{opts[:execute]}"
        Kernel.exec("cd config/docker_vagrant && vagrant ssh --command '#{opts[:execute]}'")
      else
        logger.info "connecting to server..."
        Kernel.exec("cd config/docker_vagrant && vagrant ssh")
      end
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
