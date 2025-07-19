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
      tables ||= connection.tables.reject { |t| %w[schema_migrations ar_internal_metadata].include?(t) }
      # tables ||= connection.tables.reject { |t| t == "schema_migrations" }

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
      @file_name = model_name.underscore
      @plural_file_name = @file_name.pluralize
      @columns = columns
      @namespace = namespace
      @generate_model = generate_model
      @fields = columns.map(&:name).reject { |c| c == "id" }
    end

    def run
      generate_model_file if @generate_model
      generate_file("repository")
      generate_file("service")
      generate_file("blueprint")
      generate_file("controller")
    end

    def generate_model_file
      cmd = ["rails", "generate", "model", @model_name] + column_args
      system(*cmd)
      # system("rails generate model #{@model_name} #{column_args.join(" ")}")
    end

    def column_args
      # @columns.map { |col| "#{col.name}:#{col.sql_type}" unless col.name == "id" }.compact
      @columns.map do |col|
        next if col.name == "id"

        rails_type = map_sql_type(col.sql_type)
        "#{col.name}:#{rails_type}" if rails_type
      end.compact
    end

    def map_sql_type(sql_type) # rubocop:disable Metrics/MethodLength
      case sql_type
      when /nvarchar|varchar|text/ then "string"
      when /int/ then "integer"
      when /timestamp/ then "datetime"
      when /bool/ then "boolean"
      when /decimal|numeric/ then "decimal"
      when /date/ then "date"
      else
        puts "Warning: unknown SQL type #{sql_type}, skipping."
        nil
      end
    end

    def generate_file(type) # rubocop:disable Metrics/MethodLength
      require "erb"

      template_path = File.expand_path("../../generators/domino/templates/#{type}.rb.tt", __FILE__)
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
                   "#{@plural_file_name}_controller.rb"
                 else
                   "#{@file_name}_#{type}.rb"
                 end

      FileUtils.mkdir_p(folder)
      File.write(File.join(folder, filename), content)
    end
  end
end
