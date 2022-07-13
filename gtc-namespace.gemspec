# frozen_string_literal: true

require_relative "lib/gtc/namespace/version"

Gem::Specification.new do |spec|
  spec.name                  = "gtc-namespace"
  spec.version               = GTC::Namespace.version
  spec.authors               = ["Gonzo"]
  spec.email                 = ["rubygems@gonzo-hosting.de"]
  spec.summary               = "Unified namespace for ruby applications"
  spec.description           = "GTC :: Namespace - Enhance your development experience"
  spec.homepage              = "https://gitlab.services.gonzo-hosting.de/rubygems/gtc-namespace"
  spec.license               = "MIT"
  spec.required_ruby_version = ">= 2.3.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["homepage_uri"]      = "https://gitlab.services.gonzo-hosting.de/rubygems/gtc-namespace"
  spec.metadata["source_code_uri"]   = "https://gitlab.services.gonzo-hosting.de/rubygems/gtc-namespace"
  spec.metadata["changelog_uri"]     = "https://gitlab.services.gonzo-hosting.de/rubygems/gtc-namespace/docs/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end

  spec.require_paths = ["lib"]

  spec.add_dependency 'activesupport', '>= 6.0'

  spec.add_development_dependency 'rspec',  '~> 3.11'
  spec.add_development_dependency 'simplecov',  '~> 0.21'
  spec.add_development_dependency 'rake', "~> 13.0"
end
