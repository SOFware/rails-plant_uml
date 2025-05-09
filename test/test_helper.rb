# frozen_string_literal: true

require "simplecov" if ENV["CI"]

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "rails"
require "active_support"
require "active_support/testing/time_helpers"
require "rails/plant_uml"

require "minitest/spec"
require "minitest/autorun"

class Minitest::Spec
  include ActiveSupport::Testing::TimeHelpers
end
