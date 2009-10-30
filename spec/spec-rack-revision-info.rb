require 'rubygems'
require 'spec'
require 'rack/builder'
require 'rack/mock'
require File.join(File.dirname(__FILE__), '..', 'lib', 'rack-revision-info.rb')

class Rack::RevisionInfo
  DATETIME_FORMAT = "%Y-%m-%d %H:%M:%S %Z"
  def get_revision_info(path, opts={})
    [(opts[:short_git_revisions] ? SHORT_GIT_REV : REV), DATE]
  end
  def get_revision_label(opts={})
    opts[:revision_label] or REV_LABEL
  end
  def get_date_format(opts={})
    opts[:date_format] or DATETIME_FORMAT
  end
end

describe "Rack::RevisionInfo" do
  REV = "a4jf64jf4hff"
  SHORT_GIT_REV = "a4jf64jf"
  REV_LABEL = "Revision"
  DATE = DateTime.now

  it "should append revision info in html comment" do
    app = Rack::Builder.new do
      use Rack::RevisionInfo, :path => "/some/path/to/repo"
      run lambda { |env| [200, { 'Content-Type' => 'text/html' }, ["<html><head></head><body>Hello, World!</body></html>"]] }
    end
    response = Rack::MockRequest.new(app).get('/')
    response.body.should match(/#{Regexp.escape("<!-- Revision #{REV} (#{DATE.strftime(Rack::RevisionInfo::DATETIME_FORMAT)}) -->")}/m)
  end

  it "should append customised revision info in html comment" do
    custom_date_format = "%d-%m-%Y %H:%M:%S"
    app = Rack::Builder.new do
      use Rack::RevisionInfo, :path => "/some/path/to/repo", :revision_label => "Rev", :date_format => custom_date_format
      run lambda { |env| [200, { 'Content-Type' => 'text/html' }, ["<html><head></head><body>Hello, World!</body></html>"]] }
    end
    response = Rack::MockRequest.new(app).get('/')
    response.body.should match(/#{Regexp.escape("<!-- Rev #{REV} (#{DATE.strftime(custom_date_format)}) -->")}/)
  end

  it "should append customised git specific revision info in html comment" do
    custom_date_format = "%d-%m-%Y %H:%M:%S"
    app = Rack::Builder.new do
      use Rack::RevisionInfo, :path => "/some/path/to/repo", :revision_label => "Rev", :date_format => custom_date_format, :short_git_revisions => true
      run lambda { |env| [200, { 'Content-Type' => 'text/html' }, ["<html><head></head><body>Hello, World!</body></html>"]] }
    end
    response = Rack::MockRequest.new(app).get('/')
    response.body.should match(/#{Regexp.escape("<!-- Rev #{SHORT_GIT_REV} (#{DATE.strftime(custom_date_format)}) -->")}/)
  end

  it "shouldn't append revision info for non-html content-types" do
    app = Rack::Builder.new do
      use Rack::RevisionInfo, :path => "/some/path/to/repo"
      run lambda { |env| [200, { 'Content-Type' => 'text/plain' }, ["Hello, World!"]] }
    end
    response = Rack::MockRequest.new(app).get('/')
    response.body.should_not match(/#{Regexp.escape('<!-- Revision ')}/m)
  end

  it "shouldn't append revision info for xhr requests" do
    app = Rack::Builder.new do
      use Rack::RevisionInfo, :path => "/some/path/to/repo"
      run lambda { |env| [200, { 'Content-Type' => 'text/html' }, ["<html><head></head><body>Hello, World!</body></html>"]] }
    end
    response = Rack::MockRequest.new(app).get('/', "HTTP_X_REQUESTED_WITH" => "XMLHttpRequest")
    response.body.should_not match(/#{Regexp.escape('<!-- Revision ')}/m)
  end

  it "should raise exeption when no path given" do
    app = Rack::Builder.new do
      use Rack::RevisionInfo
      run lambda { |env| [200, {'Content-Type' => 'text/plain'}, ["Hello, World!"]] }
    end
    lambda do
      response = Rack::MockRequest.new(app).get('/')
    end.should raise_error(ArgumentError)
  end
  
  it "should inject revision info into DOM" do
    Rack::RevisionInfo::INJECT_ACTIONS.each do |action|
      app = Rack::Builder.new do
        use Rack::RevisionInfo, :path => "/some/path/to/repo", action => "#footer"
        run lambda { |env| [200, { 'Content-Type' => 'text/html' }, [%q{<html><head></head><body>Hello, World!<div id="footer">Foota</div></body></html>}]] }
      end
      response = Rack::MockRequest.new(app).get('/')
      response.body.should match(/#{Regexp.escape("<span class=\"rack-revision-info\">Revision #{REV} (#{DATE.strftime(Rack::RevisionInfo::DATETIME_FORMAT)})</span>")}.*#{Regexp.escape("</body>")}/m)
    end
  end

  it "shouldn't inject revision info into DOM if unknown action" do
    app = Rack::Builder.new do
      use Rack::RevisionInfo, :path => "/some/path/to/repo", :what_what => "#footer"
      run lambda { |env| [200, { 'Content-Type' => 'text/html' }, [%q{<html><head></head><body>Hello, World!<div id="footer">Foota</div></body></html>}]] }
    end
    response = Rack::MockRequest.new(app).get('/')
    response.body.should_not match(/#{Regexp.escape("Revision #{REV} (#{DATE.strftime(Rack::RevisionInfo::DATETIME_FORMAT)})")}.*#{Regexp.escape("</body>")}/m)
  end

  it "shouldn't escape backslashes" do # hpricot was doing this :|
    app = Rack::Builder.new do
      use Rack::RevisionInfo, :path => "/some/path/to/repo", :inner_html => "#footer"
      run lambda { |env| [200, { 'Content-Type' => 'text/html' }, [%q{<html><head></head><body><input type="text" name="foo" value="\" /><div id="footer">Foota</div></body></html>}]] }
    end
    response = Rack::MockRequest.new(app).get('/')
    response.body.should_not match(/value="\\\\"/m)
  end
end
