require "bundler/gem_tasks"

begin
  # require 'rspec/core/rake_task'
  require 'spec/rake/spectask'

  Spec::Rake::SpecTask.new('coverage') do |spec|
    spec.libs << 'lib' << 'spec'
    spec.pattern = 'spec/**/*_spec.rb'
    ENV['COVERAGE'] = "true"
  end

  Spec::Rake::SpecTask.new(:spec) do |spec|
    spec.libs << 'lib' << 'spec'
    spec.spec_files = FileList['spec/**/*_spec.rb']
  end

  task default: :spec
rescue LoadError
  # no rspec available
end
begin
  require 'yard'
  YARD::Rake::YardocTask.new
rescue LoadError
  task :yardoc do
    abort "YARD is not available. In order to run yardoc, you must: sudo gem install yard"
  end
end
