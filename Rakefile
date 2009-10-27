require "rake"
require "rake/clean"
require "spec/rake/spectask"
begin
  require "hanna/rdoctask"
rescue LoadError
  require "rake/rdoctask"
end

CLEAN.include ["*.gem", "rdoc"]
RDOC_OPTS = ['--inline-source', '--line-numbers', '--title', 'Sequel validation_helpers_block: Allows easy determination of which validation rules apply to a given column, at the expense of increased verbosity', '--main', 'Sequel::Plugins::ValidationHelpersBlock']

Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = "rdoc"
  rdoc.options += RDOC_OPTS
  rdoc.rdoc_files.add %w"lib/sequel_validation_helpers_block.rb LICENSE"
end

desc "Run specs"
Spec::Rake::SpecTask.new("spec") do |t|
  t.spec_files = ["spec/sequel_validation_helpers_block_spec.rb"]
end
task :default=>[:spec]

desc "Package sequel_validation_helpers_block"
task :package do
  sh %{gem build sequel_validation_helpers_block.gemspec}
end
