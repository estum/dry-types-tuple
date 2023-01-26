# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = "dry-types-tuple"
  spec.version = '0.0.1'
  spec.authors = ["Anton"]
  spec.email = ["anton.estum@gmail.com"]

  spec.summary = "Dry::Types::Tuple"
  spec.description = "The Tuple type implementation for Dry::Types."
  spec.homepage = "https://github.com/estum/dry-types-tuple"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["homepage_uri"]      = spec.homepage
  spec.metadata["source_code_uri"]   = "https://github.com/estum/dry-types-tuple"
  spec.metadata["changelog_uri"]     = "https://github.com/estum/dry-types-tuple/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "dry-types"

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
end
