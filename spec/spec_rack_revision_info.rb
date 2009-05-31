require 'spec'
require 'rack/builder'
require 'rack/mock'
require File.join(File.dirname(__FILE__), '..', 'lib', 'rack_revision_info.rb')

class Rack::RevisionInfo
  def get_revision_info(path)
    [REV, DATE]
  end
end

describe "Rack::RevisionInfo" do
  REV = "a4jf64jf4hff"
  DATE = DateTime.now

  it "should append revision info in html comment" do
    app = Rack::Builder.new do
      use Rack::RevisionInfo, :path => "/some/path/to/repo"
      run lambda { |env| [200, { 'Content-Type' => 'text/html' }, ["<html><head></head><body>Hello, World!</body></html>"]] }
    end
    response = Rack::MockRequest.new(app).get('/')
    response.body.should match(/#{Regexp.escape("<!-- Revision #{REV} (#{DATE.strftime("%Y-%m-%d %H:%M:%S %Z")}) -->")}/)
  end

  it "shouldn't append revision info for non-html content-types" do
    app = Rack::Builder.new do
      use Rack::RevisionInfo, :path => "/some/path/to/repo"
      run lambda { |env| [200, { 'Content-Type' => 'text/plain' }, ["Hello, World!"]] }
    end
    response = Rack::MockRequest.new(app).get('/')
    response.body.should_not match(/#{Regexp.escape('<!-- Revision ')}/)
  end

  it "shouldn't append revision info for xhr requests" do
    app = Rack::Builder.new do
      use Rack::RevisionInfo, :path => "/some/path/to/repo"
      run lambda { |env| [200, { 'Content-Type' => 'text/html' }, ["<html><head></head><body>Hello, World!</body></html>"]] }
    end
    response = Rack::MockRequest.new(app).get('/', "HTTP_X_REQUESTED_WITH" => "XMLHttpRequest")
    response.body.should_not match(/#{Regexp.escape('<!-- Revision ')}/)
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

end
