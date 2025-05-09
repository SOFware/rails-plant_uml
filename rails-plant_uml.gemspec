# frozen_string_literal: true

require_relative "lib/rails/plant_uml/version"

Gem::Specification.new do |spec|
  spec.name = "rails-plant_uml"
  spec.version = Rails::PlantUml::VERSION
  spec.authors = ["Jim Gay"]
  spec.email = ["jim@saturnflyer.com"]

  spec.summary = "Tie into RailsERD to generate PlantUML diagrams."
  spec.description = "Adds a PlantUML output format to RailsERD."
  spec.homepage = "https://github.com/SOFware/rails-plant_uml"
  spec.required_ruby_version = ">= 3.1.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/SOFware/rails-plant_uml"
  spec.metadata["changelog_uri"] = "https://github.com/SOFware/rails-plant_uml/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir.glob(File.join("{lib,exe}", "**", "*"), File::FNM_DOTMATCH).reject do |f|
      File.directory?(f) || f.end_with?(".gitkeep")
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "rails", ">= 7.0"
  spec.add_dependency "rails-erd", ">= 1.7.0"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
