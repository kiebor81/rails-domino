# frozen_string_literal: true

require "rails/generators"

class DominoGenerator < Rails::Generators::NamedBase # rubocop:disable Style/Documentation
  source_root File.expand_path("templates", __dir__)

  # Accept attributes for model
  argument :attributes, type: :array, default: [], banner: "field[:type] field[:type]"

  class_option :with_model, type: :boolean, default: false, desc: "Generate ActiveRecord model"

  def initialize(*args)
    super
    @model_name = class_name
    @file_name = file_name
    @plural_file_name = file_name.pluralize
    @fields = attributes.map(&:name).reject { |f| f == "id" }
  end

  def create_model
    return unless options[:with_model]

    generate "model", "#{@model_name} #{attributes.join(" ")}"
  end

  def create_service
    template "service.rb.tt", File.join("app/services", "#{@file_name}_service.rb")
    register_dependency("#{@file_name}_service", "#{@model_name}Service")
  end

  def create_repository
    template "repository.rb.tt", File.join("app/repositories", "#{@file_name}_repository.rb")
    register_dependency("#{@file_name}_repository", "#{@model_name}Repository")
  end

  def create_blueprint
    template "blueprint.rb.tt", File.join("app/mappers", "#{@file_name}_blueprint.rb")
  end

  def create_controller
    template "controller.rb.tt", File.join("app/controllers", "#{@plural_file_name}_controller.rb")
  end

  private

  def register_dependency(key, class_name)
    init_file = Rails.root.join("config/initializers/domino_container.rb")
    line = "Domino::Container.register(\"#{key}\", -> { #{class_name}.new })"

    FileUtils.mkdir_p(File.dirname(init_file))
    return if File.exist?(init_file) && File.read(init_file).include?(line)

    File.write(init_file, "#{line}\n", mode: "a")
  end
end
