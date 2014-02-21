module ServerBuilder
  class Verifier

    attr_accessor :logger, :opts, :host

    def initialize(opts, logger)
      @opts   = opts
      @host   = opts.fetch('host'){ "utils.picoappz.com" }
      @logger = logger
    end

    def verify
      logger.info "verifying server with: #{opts.inspect}"
      verify_graphite(opts['graphite']) if opts['graphite']
      verify_statsd(opts['statsd']) if opts['statsd']
      verify_logstash(opts['logstash']) if opts['logstash']
      verify_elasticsearch(opts['elasticsearch']) if opts['elasticsearch']
      verify_redis(opts['redis']) if opts['redis']
    end

    protected
    
    def verify_jenkins(port)
      port = port.to_i
      port = 8080 if port==0
      logger.info "verifying jenkins"
      output = `curl #{host}:#{port}`
      output.match(/jenkins/)
    end

    def verify_graphite(port)
      port = port.to_i
      port = 2003 if port==0
      logger.info "verifying graphite"
      require 'simple-graphite'
      g = Graphite.new({:host => host, :port => port})
      
      g.push_to_graphite do |graphite|
        graphite.puts "server_builder.test.graphite 3.1415926 #{g.time_now}"
      end
    end
    
    def verify_statsd(port)
      port = port.to_i
      port = 8125 if port==0
      logger.info "verifying statsd"
      require 'statsd-ruby'
      
      statsd = Statsd.new(host, port).tap{|sd| sd.namespace = 'server_builder'}
      100.times {
        statsd.increment 'test.statsd'
      }
    end
    
    def verify_logstash(port)
      port = port.to_i
      port = 49175 if port==0
      logger.info "verifying logstash"
      require 'logstash-logger'
      
      # Defaults to UDP
      logger = LogStashLogger.new(host, port, :tcp)
      logger.info 'server_builder test logstash logging'
    end
    
    def verify_redis(port)
      port = port.to_i
      port = 6379 if port==0
      logger.info "verifying redis on host #{host} port #{port}"
      require "redis"
    
      redis = Redis.new(:uri => "#{host}:#{port}")
      test_val = "setting redis"
      redis.set("server_builder_test", test_val)
      if test_val == redis.get("server_builder_test")
        return
      else
        logger.error "redis validation failed didn't receive same data set"
        exit 1
      end
    end

    def verify_elasticsearch(port)
      port = port.to_i
      port = 9200 if port==0
      logger.info "verifying elasticsearch"
      require 'elasticsearch'

      # Connect to cluster at search1:9200, sniff nodes and round-robin between them
      es = Elasticsearch::Client.new hosts: ["#{host}search1:#{port}"], reload_connections: true

      # Index a document:
      es.index index: 'server_builder',
      type:  'test_post',
      id: 1,
      body: {
        title:   "Elasticsearch clients",
        content: "Interesting content...",
        date:    "2013-09-24"
      }
      
      # Get the document:
      doc = es.get index: 'server_builder', type: 'test_post', id: 1
      puts doc
      
      # Search:
      doc = es.search index: 'server_builder',
      body: { query: { match: { title: 'elasticsearch' } } }
      
      puts doc
    end

  end
end
