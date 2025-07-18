# frozen_string_literal: true

require_relative "../test_helper"

# Stub ActiveRecord at top level so we can patch Base.connection
module ActiveRecord
  class Base
    def self.connection
      raise "This should be stubbed in tests"
    end
  end
end

module Domino
  class FullScaffoldTest < Minitest::Test
    def setup # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/MethodLength
      puts "Setting up test environment for Domino full scaffold..."

      @tmp_templates = "temp"
      # @tmp_templates = Dir.mktmpdir
      {
        "service.rb.tt" => "<%= @model_name %>Service",
        "repository.rb.tt" => "<%= @model_name %>Repository",
        "blueprint.rb.tt" => "<%= @model_name %>Blueprint",
        "controller.rb.tt" => "<%= @model_name.pluralize %>Controller"
      }.each do |file, content|
        File.write(File.join(@tmp_templates, file), content)
      end

      %w[services repositories mappers controllers].each do |folder|
        FileUtils.rm_rf("app/#{folder}")
        FileUtils.mkdir_p("app/#{folder}")
      end

      # Patch generate_file with test-local override
      Domino::ScaffoldRunner.class_eval do
        define_method(:generate_file_for_test) do |type, template_root| # rubocop:disable Metrics/MethodLength
          template_path = File.join(template_root, "#{type}.rb.tt")
          raise "Missing template: #{template_path}" unless File.exist?(template_path)

          content = ERB.new(File.read(template_path)).result(binding)

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

    def teardown
      # FileUtils.rm_rf(@tmp_templates) if @tmp_templates
    end

    def test_scaffold_generates_all_components # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
      column = OpenStruct.new(name: "name", sql_type: "string")

      mock_connection = Minitest::Mock.new
      mock_connection.expect :tables, ["users"]
      mock_connection.expect :columns, [column], ["users"]

      ActiveRecord::Base.stub :connection, mock_connection do
        tmp_templates = @tmp_templates
        Domino::ScaffoldRunner.class_eval do
          alias_method :generate_file_original, :generate_file
          define_method(:generate_file) { |type| generate_file_for_test(type, tmp_templates) }
        end

        Domino.scaffold(tables: ["users"], generate_model: false)

        Domino::ScaffoldRunner.class_eval do
          alias_method :generate_file, :generate_file_original
        end
      end

      expected_files = {
        "app/services/user_service.rb" => "UserService",
        "app/repositories/user_repository.rb" => "UserRepository",
        "app/mappers/user_blueprint.rb" => "UserBlueprint",
        "app/controllers/users_controller.rb" => "UsersController"
      }

      expected_files.each do |file, content|
        assert File.exist?(file), "Expected file not found: #{file}"
        assert_match content, File.read(file)
      end
    end
  end
end
