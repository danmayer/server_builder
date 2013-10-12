require 'rubygems'
require "server_builder/version"

module ServerBuilder
  class Builder
    
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
      if opts['cmd'].match(/verify/i)
        puts "verifying server"
        verify_server(opts)
      else
        puts "build a server"
      end
      puts "done"
    end

    def self.verify_server(opts = {})
      host = opts.fetch(:host){ "utils.picoappz.com" }
      verify_graphite(host) if opts['graphite']
      verify_statsd(host) if opts['statsd']
      verify_logstash(host) if opts['logstash']
      verify_elasticsearch(host) if opts['elasticsearch']
      verify_redis(host) if opts['redis']
    end

    private

    def self.verify_graphite(host, port = 2003)
      puts "verifying graphite"
      require 'simple-graphite'
      g = Graphite.new({:host => host, :port => port})
      
      g.push_to_graphite do |graphite|
        graphite.puts "server_builder.test.graphite 3.1415926 #{g.time_now}"
      end
    end

    def self.verify_statsd(host, port = 8125)
      puts "verifying statsd"
      require 'statsd-ruby'

      statsd = Statsd.new(host, port).tap{|sd| sd.namespace = 'server_builder'}
      100.times {
        statsd.increment 'test.statsd'
      }
    end

    def self.verify_logstash(host, port = 49175)
      puts "verifying logstash"
      require 'logstash-logger'
      
      # Defaults to UDP
      logger = LogStashLogger.new(host, port, :tcp)
      logger.info 'server_builder test logstash logging'
    end

    def self.verify_redis(host, port = 6380)
      puts "verifying redis"
      require "redis"
    
      redis = Redis.new(:host => host, :port => port)  
      redis.set("server_builder_test", "setting redis")
    end

    def self.verify_elasticsearch(host, port = 9200)
      puts "verifying elasticsearch"
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
