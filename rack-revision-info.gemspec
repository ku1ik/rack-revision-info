# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{rack-revision-info}
  s.version = "0.3.6"
  s.platform = Gem::Platform::RUBY
  s.date = %q{2009-10-30}
  s.authors = ["Marcin Kulik"]
  s.email = %q{marcin.kulik@gmail.com}
  s.has_rdoc = false
  s.homepage = %q{http://sickill.net}
  s.summary = %q{Rack middleware showing current git (or svn) revision number of application}
  s.files = [ "lib/rack-revision-info.rb", "lib/rack-revision-info/nokogiri_backend.rb", "spec/spec-rack-revision-info.rb" ]
#  s.require_paths = ["lib"]
end
