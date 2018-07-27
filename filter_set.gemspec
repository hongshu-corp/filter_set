$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "filter_set/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "filter_set"
  s.version     = FilterSet::VERSION
  s.authors     = ["Liangchen"]
  s.email       = ["leeonky@gmail.com"]
  s.homepage    = ""
  s.summary     = "Simple filter in rails form app"
  s.description = ""
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.add_dependency 'rails', '~> 4.2.10'
  s.add_dependency 'slim-rails'
  s.add_dependency 'sass-rails'
  s.add_dependency 'nokogiri'
  s.add_dependency 'rubyXL'
  s.add_dependency 'font-awesome-rails'
end
