require 'sinatra'
require File.dirname(__FILE__) + '/rack_revision_info'

use Rack::RevisionInfo, :path => "/home/kill/workspace/off-plugin", :inner_html => "#footer"

get '/' do
  <<EOF
<html>
<head></head>
<body>
  <h1>Yo yo!</h1>
  <h2>Ha dwa</h2>
  <div id="footer">Copyright 2066</div>
</body>
</html>
EOF
end
