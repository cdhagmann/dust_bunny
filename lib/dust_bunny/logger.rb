# frozen_string_literal: true

require 'logger'
require 'singleton'

module DustBunny
  class Logger < Logger
    include Singleton

    def initialize
      super('log/dust_bunny.log')
    end
  end
end
