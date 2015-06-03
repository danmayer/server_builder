module ServerBuilder
  class EcsBuilder

    attr_accessor :logger, :cluster_name, :service_name, :desired_count,
                  :task_definition

    def initialize(opts)
      @logger = opts.fetch('logger'){ 
        log_file = File.open("logs/server_builder.log", "a")
        Logger.new MultiIO.new(STDOUT, log_file)
      }
      @cluster_name = opts.fetch('name') { 'auto_cluster' }
      @service_name = opts.fetch('service_name') { 'auto_graphite-statsd' }
      @desired_count = opts.fetch('desired_count') { 1 }
      @task_definition = opts.fetch('task_definition') { 'graphite-statsd:3' }
    end
    
    def build(opts)
      logger.info "building with EcsBuilder"
      #build_cluster
      #create_ecs_instance
      #add_service
    end

    private

    def build_cluster
      `aws ecs create-cluster --cluster-name #{cluster_name}`
    end

    def add_service
      `aws ecs create-service --cluster #{cluster_name} --service-name #{service_name} --desired-count #{desired_count} --task-definition #{task_definition}`
    end
    
  end
end
