# frozen_string_literal: true

require "domino/version"
require "domino/scaffolder"
require "domino/railtie"

# for DI
require "dry/auto_inject"
require "dry/container"

# for data contracts
require "blueprinter"

# expose abstracts
require "domino/base_service"
require "domino/base_repository"

module Domino # rubocop:disable Style/Documentation
  Container = Dry::Container.new

  Import = Dry::AutoInject(Container)

  def self.scaffold(**kwargs)
    Scaffolder.scaffold(**kwargs)
  end
end
