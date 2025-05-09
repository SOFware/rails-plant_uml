# Rails::PlantUml

Tie into RailsERD to generate PlantUML diagrams.

## Installation

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add rails-plant_uml
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install rails-plant_uml
```

## Usage

See the the rake tasks with `rails -T erd`.

Build your own task using the `Rails::PlantUml` class.

```ruby
desc "Generate a PlantUML diagram of your special models"
task special_diagram: :environment do
  require "rails/plant_uml"

  options = {
    models: %w[Something Special OtherModel],
    title: "My Special Diagram",
    filename: "docs/special_diagram"
    app_name: Rails.application.class.module_parent_name
  }

  diagram = RailsErd::PlantUml.new(RailsERD::Domain.generate, options)
  diagram.save
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

This project is managed with [Reissue](https://github.com/SOFware/reissue).

To release a new version, make your changes and be sure to update the CHANGELOG.md.

To release a new version:

1. `bundle exec rake build:checksum`
2. `bundle exec rake release`

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/SOFware/rails-plant_uml.
