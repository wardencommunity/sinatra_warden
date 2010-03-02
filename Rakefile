require 'rake'
require 'bundler'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "sinatra_warden"
    gem.summary = %Q{authentication system for using warden with sinatra}
    gem.description = %Q{basic helpers and authentication methods for using warden with sinatra also providing some hooks into Rack::Flash}
    gem.email = "justin.smestad@gmail.com"
    gem.homepage = "http://github.com/jsmestad/sinatra_warden"
    gem.authors = ["Justin Smestad", "Daniel Neighman"]

    bundle = Bundler::Definition.from_gemfile('Gemfile')
    bundle.dependencies.each do |dep|
      next unless dep.groups.include?(:runtime)
      gem.add_dependency(dep.name, dep.version_requirements.to_s)
    end
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
end

Spec::Rake::SpecTask.new(:rcov) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rcov = true
end

task :default => :spec

begin
  require 'yard'
  YARD::Rake::YardocTask.new
rescue LoadError
  task :yardoc do
    abort "YARD is not available. In order to run yardoc, you must: sudo gem install yard"
  end
end
