# frozen_string_literal: true

module Domino
  # Scaffolder: handles the generation of model, repository, service, blueprint, and controller files
  class Scaffolder
    # Entrypoint: called from Domino.scaffold
    #
    # @param tables [Array<String>] optional list of tables to scaffold
    # @param namespace [String, nil] reserved for future support
    # @param generate_model [Boolean] whether to run model generation
    def self.scaffold(tables: nil, namespace: nil, generate_model: true)
      connection = ActiveRecord::Base.connection
      tables ||= connection.tables.reject { |t| t == "schema_migrations" }

      tables.each do |table|
        klass = table.singularize.camelize
        columns = connection.columns(table)
        ScaffoldRunner.new(klass, columns, namespace, generate_model).run
      end
    end
  end

  # ScaffoldRunner: handles the actual file generation
  class ScaffoldRunner
    def initialize(model_name, columns, namespace, generate_model)
      @model_name = model_name
      @columns = columns
      @namespace = namespace
      @generate_model = generate_model
    end

    def run
      generate_model_file if @generate_model
      generate_file("repository")
      generate_file("service")
      generate_file("blueprint")
      generate_file("controller")
    end

    def generate_model_file
      system("rails generate model #{@model_name} #{column_args.join(" ")}")
    end

    def column_args
      @columns.map { |col| "#{col.name}:#{col.sql_type}" unless col.name == "id" }.compact
    end

    def generate_file(type) # rubocop:disable Metrics/MethodLength
      require "erb"

      template_path = File.expand_path("../generators/domino/templates/#{type}.rb.tt", __FILE__)
      raise "Missing template: #{template_path}" unless File.exist?(template_path)

      content = ERB.new(File.read(template_path)).result(binding)

      puts "Generating #{type} for #{@model_name}"

      folder = case type
               when "blueprint" then "app/mappers"
               when "controller" then "app/controllers"
               when "repository" then "app/repositories"
               when "service" then "app/services"
               else "app/#{type}s"
               end

      filename = case type
                 when "controller"
                   "#{@model_name.underscore.pluralize}_controller.rb"
                 else
                   "#{@model_name.underscore}_#{type}.rb"
                 end

      FileUtils.mkdir_p(folder)
      File.write(File.join(folder, filename), content)
    end
  end
end
