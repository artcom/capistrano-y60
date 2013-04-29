# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "capistrano-y60"
  s.version = "0.0.17"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Gunnar Marten"]
  s.date = "2013-04-29"
  s.description = "Y60 deployment recipes for Capistrano"
  s.email = "gunnar.marten@artcom.de"
  s.executables = ["update_install_pack_get_y60.sh"]
  s.extra_rdoc_files = [
    "README.md"
  ]
  s.files = [
    "README.md",
    "Rakefile",
    "VERSION",
    "bin/update_install_pack_get_y60.sh",
    "capistrano-y60.gemspec",
    "lib/artcom/app.rb",
    "lib/artcom/capistrano-y60.rb",
    "lib/artcom/common.rb",
    "lib/artcom/linux.rb",
    "lib/artcom/watchdog.rb",
    "lib/artcom/y60.rb"
  ]
  s.homepage = "https://github.com/artcom/capistrano-y60"
  s.require_paths = ["lib"]
  s.rubygems_version = "2.0.3"
  s.summary = "Y60 deployment recipes for Capistrano"

  if s.respond_to? :specification_version then
    s.specification_version = 4

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<capistrano>, [">= 2.12.0"])
      s.add_runtime_dependency(%q<capistrano-ext>, [">= 0"])
      s.add_runtime_dependency(%q<railsless-deploy>, [">= 0"])
    else
      s.add_dependency(%q<capistrano>, [">= 2.12.0"])
      s.add_dependency(%q<capistrano-ext>, [">= 0"])
      s.add_dependency(%q<railsless-deploy>, [">= 0"])
    end
  else
    s.add_dependency(%q<capistrano>, [">= 2.12.0"])
    s.add_dependency(%q<capistrano-ext>, [">= 0"])
    s.add_dependency(%q<railsless-deploy>, [">= 0"])
  end
end

