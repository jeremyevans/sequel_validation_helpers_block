spec = Gem::Specification.new do |s|
  s.name = "sequel_validation_helpers_block"
  s.version = "1.0.0"
  s.author = "Jeremy Evans"
  s.email = "code@jeremyevans.net"
  s.platform = Gem::Platform::RUBY
  s.summary = "Allows easy determination of which validation rules apply to a given column, at the expense of increased verbosity"
  s.files = %w'LICENSE lib/sequel_validation_helpers_block.rb spec/sequel_validation_helpers_block_spec.rb'
  s.require_paths = ["lib"]
  s.has_rdoc = true
  s.rdoc_options = ['--inline-source', '--line-numbers', '--title', 'Sequel validation_helpers_block: Allows easy determination of which validation rules apply to a given column, at the expense of increased verbosity', '--main', 'Sequel::Plugins::ValidationHelpersBlock', 'lib/sequel_validation_helpers_block.rb', 'LICENSE']
end