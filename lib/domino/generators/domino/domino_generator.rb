# frozen_string_literal: true

require "rails/generators"

class DominoGenerator < Rails::Generators::NamedBase # rubocop:disable Style/Documentation
  source_root File.expand_path("templates", __dir__)

  # Accept attributes for model
  argument :attributes, type: :array, default: [], banner: "field[:type] field[:type]"

  class_option :with_model, type: :boolean, default: false, desc: "Generate ActiveRecord model"

  def create_model
    return unless options[:with_model]

    generate "model", "#{class_name} #{attributes.join(" ")}"
  end

  def create_service
    template "service.rb.tt", File.join("app/services", "#{file_name}_service.rb")
  end

  def create_repository
    template "repository.rb.tt", File.join("app/repositories", "#{file_name}_repository.rb")
  end

  def create_blueprint
    template "blueprint.rb.tt", File.join("app/mappers", "#{file_name}_blueprint.rb")
  end

  def create_controller
    template "controller.rb.tt", File.join("app/controllers", "#{file_name.pluralize}_controller.rb")
  end
end
