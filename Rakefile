require "rake"
require "rake/clean"
require "rdoc/task"

CLEAN.include ["*.gem", "rdoc"]

RDoc::Task.new do |rdoc|
  rdoc.rdoc_dir = "rdoc"
  rdoc.options = ['--inline-source', '--line-numbers', '--title', 'Sequel validation_helpers_block: Allows easy determination of which validation rules apply to a given column, at the expense of increased verbosity', '--main', 'Sequel::Plugins::ValidationHelpersBlock', '-f', 'hanna']
  rdoc.rdoc_files.add %w"lib/sequel/plugins/validation_helpers_block.rb LICENSE"
end

desc "Run specs"
task :spec do
  sh %{#{FileUtils::RUBY} spec/sequel_validation_helpers_block_spec.rb}
end
task :default => [:spec]

desc "Package sequel_validation_helpers_block"
task :package do
  sh %{gem build sequel_validation_helpers_block.gemspec}
end
