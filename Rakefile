require "bundler"
Bundler::GemHelper.install_tasks

require "rspec/core/rake_task"
RSpec::Core::RakeTask.new

require "rdoc/task"
Rake::RDocTask.new do |t|
  t.rdoc_dir = "docs"
  t.main = "README.rdoc"
  t.rdoc_files.include "README.rdoc", *Dir["lib/**/*.rb"]
end
