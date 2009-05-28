require 'sinatra'
require 'rack-revision-info'

use Rack::RevisionInfo, :path => "/home/kill/workspace/off-plugin"

get '/' do
  "This is yola!"
end
