# frozen_string_literal: true

require_relative 'logger'
require 'git'
require 'fileutils'

module DustBunny
  # TODO: Missing top-level documentation comment
  class File
    include Enumerable

    class << self
      attr_accessor :_git_base, :_git_status
    end

    @_git_base ||= Git.open(FileUtils.pwd, log: DustBunny::Logger.instance)
    @_git_status ||= Git::Status.new(@_git_base)

    attr_reader :files

    def self.where(files: nil, **options)
      files ||= new

      filtered_files = files.filter do |file|
        options.map do |o, v|
          if v.is_a?(Array)
            v.include?(file.public_send(o))
          else
            file.public_send(o) == v
          end
        end.all?
      end

      new(filtered_files)
    end

    def self.touched(files: nil)
      where(files: files, type: %w[M A U])
    end

    def self.changed(files: nil)
      self.where(files: files, type: 'M')
    end

    def self.added(files: nil)
      where(files: files, type: 'A')
    end

    def self.untracked(files: nil)
      where(files: files, type: 'U')
    end

    def self.deleted(files: nil)
      where(files: files, type: 'D')
    end

    def initialize(files = nil)
      @files = construct_files(files)
    end

    def <<(file)
      dust_bunny_file = convert_file(file)

      @file << dust_bunny_file
    end

    def inspect
      @files.inspect
    end

    def [](file)
      @files[file]
    end

    def each(&block)
      if block
        @files.each(&block)
      else
        @files.to_enum(:each)
      end
    end

    def method_missing(method, *args, **kwargs)
      if self.class.respond_to?(method)
        self.class.public_send(method, *args, files: @files, **kwargs)
      else
        super
      end
    end

    private def construct_files(files)
      files ||= %i[changed added untracked deleted].map do |status|
        class_variables(:git_status).public_send(status).values
      end.flatten

      files.map { |status_file| convert_file(status_file) }.sort
    end

    private def convert_file(file)
      case file
        when StatusFile
          file
        when Git::Status::StatusFile
          StatusFile.new(file)
      end
    end

    private def class_variables(variable)
      self.class.instance_variable_get("@_#{variable}")
    end

    class StatusFile
      attr_reader :path, :type, :extension

      def initialize(git_file)
        @path = git_file.path
        @type = git_file.untracked ? 'U' : git_file.type
        @extension = ::File.extname(@path)
      end

      def <=>(other)
        path <=> other.path
      end

      def to_s
        "#{path} [#{type}]"
      end
    end
  end
end
