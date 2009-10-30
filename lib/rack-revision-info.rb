module Rack
  class RevisionInfo
    INJECT_ACTIONS = [:after, :before, :append, :prepend, :swap, :inner_html]

    def initialize(app, opts={})
      @app = app
      path = opts[:path] or raise ArgumentError, "You must specify directory of your local repository!"
      revision, date = get_revision_info(path, opts)
      @revision_info = "#{get_revision_label(opts)} #{revision || 'unknown'}"
      @revision_info << " (#{date.strftime(get_date_format(opts))})" if date
      @action = (opts.keys & INJECT_ACTIONS).first
      if @action
        require ::File.join(::File.dirname(__FILE__), 'rack-revision-info', 'nokogiri_backend')
        @selector = opts[@action]
        @action = :inner_html= if @action == :inner_html
      end
    end

    def call(env)
      status, headers, body = @app.call(env)
      if headers['Content-Type'].to_s.include?('text/html') && !Rack::Request.new(env).xhr?
        body = body.inject("") { |acc, line| acc + line }
        begin
          if @action
            doc = Nokogiri.parse(body)
            elements = doc.css(@selector)
            if elements.size > 0
              elements.each { |e| e.send(@action, "<span class=\"rack-revision-info\">#{@revision_info}</span>") }
              body = doc.to_s
            end
          end
        rescue => e
          puts e
          puts e.backtrace
        end
        body << %(\n<!-- #{@revision_info} -->\n)
        headers["Content-Length"] = body.size.to_s
        body = [body]
      end
      [status, headers, body]
    end

    protected

    def get_revision_label(opts={})
      opts[:revision_label] || 'Revision'
    end

    def get_date_format(opts={})
      opts[:date_format] || "%Y-%m-%d %H:%M:%S %Z"
    end

    def get_revision_info(path, opts={})
      case detect_type(path)
      when :git
        revision_regex_extra = opts[:short_git_revisions] ? '{8}' : '+'
        info = `cd #{path}; LC_ALL=C git log -1 --pretty=medium`
        revision = info[/commit\s([a-z0-9]#{revision_regex_extra})/, 1]
        date = (d = info[/Date:\s+(.+)$/, 1]) && (DateTime.parse(d) rescue nil)
      when :svn
        info = `cd #{path}; LC_ALL=C svn info`
        revision = info[/Revision:\s(\d+)$/, 1]
        date = (d = info[/Last Changed Date:\s([^\(]+)/, 1]) && (DateTime.parse(d.strip) rescue nil)
      else
        revision, date = nil, nil
      end
      [revision, date]
    end

    def detect_type(path)
      return :git if ::File.directory?(::File.join(path, ".git"))
      return :svn if ::File.directory?(::File.join(path, ".svn"))
      :unknown
    end

  end
end
