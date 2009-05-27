module Rack
  class RevisionInfo
    
    def initialize(app)
      @app = app
    end

    def call(env)
      [200, {}, [""]]
    end

  end
end