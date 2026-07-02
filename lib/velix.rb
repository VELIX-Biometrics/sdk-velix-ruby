# frozen_string_literal: true

require_relative "velix/client"

module Velix
  def self.new(**kwargs)
    Client.new(**kwargs)
  end
end
