# frozen_string_literal: true

require "rails"

module Rails
  module PlantUml
    class Railtie < Rails::Railtie
      rake_tasks do
        # add tasks from rails/plant_uml/tasks
        load File.expand_path("../tasks/rails_erd.rake", __FILE__)
      end
    end
  end
end
