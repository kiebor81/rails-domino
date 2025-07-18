# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.required_ruby_version = ">= 3.0"
  spec.name          = "rails-domino"
  spec.version       = "0.1.0"
  spec.authors       = ["kiebor81"]
  spec.summary       = "Domain-first service and repository scaffold for Rails. Enforces DDD architecture with Blueprinter and Dry-rb libraries" # rubocop:disable Layout/LineLength
  spec.files         = Dir["lib/**/*"]
  spec.require_paths = ["lib"]
  spec.add_dependency "blueprinter"
  spec.add_dependency "dry-auto_inject"
  spec.add_dependency "dry-container"
  spec.add_dependency "rails", ">= 6.0"
  # spec.add_dependency "oas_rails"

  spec.add_development_dependency "minitest", "~> 5.0"
end
