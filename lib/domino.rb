# frozen_string_literal: true

require "domino/version"
require "domino/scaffolder"

module Domino # rubocop:disable Style/Documentation
  def self.scaffold(**kwargs)
    Scaffolder.scaffold(**kwargs)
  end
end
