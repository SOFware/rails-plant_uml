# frozen_string_literal: true

namespace :erd do
  desc "Generate a PlantUML diagram of your models"
  task plant_uml: :environment do
    require "rails/plant_uml"

    options = {
      filename: "erd.puml",
      title: "Entity Relationship Diagram",
      app_name: Rails.application.class.module_parent_name
    }

    diagram = RailsErd::PlantUml.new(RailsERD::Domain.generate, options)
    diagram.save
  end
end
