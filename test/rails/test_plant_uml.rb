# frozen_string_literal: true

require "test_helper"

describe Rails::PlantUml do
  it "has a version number" do
    _(Rails::PlantUml::VERSION).wont_be_nil
  end

  it "can generate a diagram" do
    domain = Object.new
    diagram = RailsErd::PlantUml.new(domain)
    _(diagram).must_be_kind_of RailsErd::PlantUml
  end
end
