# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{rack_revision_info}
  s.version = "0.3.1"
  s.platform = Gem::Platform::RUBY
  s.date = %q{2009-05-04}
  s.authors = ["Marcin Kulik"]
  s.email = %q{marcin.kulik@gmail.com}
  s.has_rdoc = false
  s.homepage = %q{http://sickill.net}
  s.summary = %q{Rack middleware showing current git (or svn) revision number of application}
  s.files = [ "lib/rack_revision_info.rb", "spec/spec_rack_revision_info.rb" ]
#  s.require_paths = ["lib"]
end
