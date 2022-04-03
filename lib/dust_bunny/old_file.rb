# frozen_string_literal: true

require_relative 'logger'
require 'git'
require 'fileutils'

module DustBunny
  class File
    class << self
      attr_accessor :_files
    end

    @_files = DustBunny::Files

    attr_reader :path

    delegate :where,
             :touched,
             :changed,
             :untracked,
             :deleted,
             :added,
             to: :@_file

    def initialize(git_file: nil, **metadata)
      @_git_file = git_file
      @_metadata = metadata
    end

    def type
      @type ||= begin
        return 'U' if git_file.untracked
        return git_file.type unless git_file.nil?

        metadata[:type]
      end
    end

    def path
      @path ||= begin
        git_file.path
        return git_file.path unless git_file.nil?
      end
    end

    def extension
      @extension ||= File.extname(path)
    end

    def <=>(other)
      path <=> other.path
    end

    def to_s
      "#{path} [#{type}]"
    end

    private def git_file
      @_git_file
    end

    private def metadata
      @_metadata
    end
  end
end
