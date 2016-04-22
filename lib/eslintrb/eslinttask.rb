# Define a task library for running ESLint contexts.

require 'rake'
require 'rake/tasklib'

require 'eslintrb'

module Eslintrb

  class EslintTask < ::Rake::TaskLib
    # Name of ESLint task. (default is :eslint)
    attr_accessor :name

    # Glob pattern to match JavaScript files. (default is './**/*.js')
    attr_accessor :pattern

    # options
    attr_accessor :options

    attr_accessor :globals

    # Whether or not to fail Rake when an error occurs (typically when ESLint check fail).
    # Defaults to true.
    attr_accessor :fail_on_error

    # Explicitly define the list of JavaScript files to be linted.
    # +js_files+ is expected to be an array of file names (a
    # FileList is acceptable).  If both +pattern+ and +js_files+ are
    # used, then the list of JavaScritp files is the union of the two.
    attr_accessor :js_files

    attr_accessor :exclude_pattern

    attr_accessor :exclude_js_files

    # Defines a new task, using the name +name+.
    def initialize(name=:eslint)
      @name = name
      @pattern = nil
      @js_files = nil
      @exclude_pattern = nil
      @exclude_js_files = nil
      @options = nil
      @globals = nil
      @fail_on_error = true

      yield self if block_given?
      @pattern = './**/*.js' if pattern.nil? && js_files.nil?
      define
    end

    def define # :nodoc:

      actual_name = Hash === name ? name.keys.first : name
      unless ::Rake.application.last_description
        desc "Run ESLint"
      end
      task name do
        unless js_file_list.empty?
          result = Eslintrb::report(js_file_list, @options, @globals, STDERR)
          if result.size > 0
            abort("ESLint check failed") if fail_on_error
          end
        end
      end

      self
    end

    def evaluate(o) # :nodoc:
      case o
        when Proc then o.call
        else o
      end
    end

    def js_file_list # :nodoc:
        result = []
        result += js_files.to_a if js_files
        result += FileList[ pattern ].to_a if pattern
        result -= exclude_js_files.to_a if exclude_js_files
        result -= FileList[ exclude_pattern ].to_a if exclude_pattern
        FileList[result]
    end
  end

end
