require "bundler/gem_tasks"

begin
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new('coverage') do |spec|
    spec.rspec_opts = '-I lib -I spec'
    ENV['COVERAGE'] = "true"
  end

  RSpec::Core::RakeTask.new(:spec) do |spec|
    spec.rspec_opts = '-I lib -I spec'
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
