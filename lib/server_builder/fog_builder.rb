module ServerBuilder
  class FogBuilder

    attr_accessor :logger

    def initialize(opts, logger)
      @logger = logger
    end
    
    def build
      logger.info "building with fog"
    end

  end
end
