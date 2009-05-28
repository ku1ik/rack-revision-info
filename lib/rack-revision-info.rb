module Rack
  class RevisionInfo
    
    def initialize(app, opts={})
      @app = app
      path = opts[:path] or raise ArgumentError, "You must specify directory!"
      type = opts[:type] || detect_type
      case type.to_sym
      when :git
        info = `cd #{path}; git log -1 --pretty=medium`
        @revision, @date = info[/commit\s([a-z0-9]+)/, 1], DateTime.parse(info[/Date:\s+(.+)$/, 1])
      when :svn
        @revision, @date = "", ""
      else
        raise ArgumentError, "Unknown repository type '#{type}'"
      end
    end

    def call(env)
      status, headers, body = @app.call(env)
      if headers['Content-Type'] == 'text/html'
        body << "\n" << %(<!-- Revision #{@revision} (#{@date}) -->)
      end
      [status, headers, body]
    end

    protected

    def detect_type
      :git
    end

  end
end