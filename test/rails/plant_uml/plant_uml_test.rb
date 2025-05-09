# frozen_string_literal: true

require "test_helper"
require "tempfile"

class MockEntity
  attr_reader :name, :attributes

  def initialize(name, attributes = [])
    @name = name
    @attributes = attributes
  end
end

class MockAttribute
  attr_reader :name, :type

  def initialize(name, type, foreign_key = false)
    @name = name
    @type = type
    @foreign_key = foreign_key
  end

  def foreign_key?
    @foreign_key
  end
end

class MockRelationship
  attr_reader :source, :destination, :cardinality

  def initialize(source, destination, cardinality = :many, source_optional = false)
    @source = source
    @destination = destination
    @cardinality = cardinality
    @source_optional = source_optional
  end

  def source_optional?
    @source_optional
  end
end

class MockDomain
  attr_reader :entities, :relationships

  def initialize(entities = [], relationships = [])
    @entities = entities
    @relationships = relationships
  end
end

describe RailsErd::PlantUml do
  before do
    @tempfile = Tempfile.new(["test", ".puml"])
    @filename = @tempfile.path
    @domain = MockDomain.new
  end

  after do
    @tempfile.close
    @tempfile.unlink
  end

  describe "#initialize" do
    it "initializes with default options" do
      diagram = RailsErd::PlantUml.new(@domain)
      _(diagram.instance_variable_get(:@app_name)).must_equal "SOFware"
      _(diagram.instance_variable_get(:@title)).must_equal "Entity Relationship Diagram"
      _(diagram.instance_variable_get(:@only)).must_be_nil
      _(diagram.instance_variable_get(:@filename)).must_equal "erd.puml"
    end

    it "initializes with custom options" do
      diagram = RailsErd::PlantUml.new(@domain, title: "Test Diagram", app_name: "TestApp", only: ["User"])
      _(diagram.instance_variable_get(:@app_name)).must_equal "TestApp"
      _(diagram.instance_variable_get(:@title)).must_equal "Test Diagram"
      _(diagram.instance_variable_get(:@only)).must_equal ["User"]
    end

    it "appends puml extension" do
      diagram = RailsErd::PlantUml.new(@domain, filename: "test")
      _(diagram.instance_variable_get(:@filename)).must_equal "test.puml"
    end

    it "keeps existing puml extension" do
      diagram = RailsErd::PlantUml.new(@domain, filename: "test.puml")
      _(diagram.instance_variable_get(:@filename)).must_equal "test.puml"
    end
  end

  describe "#add_entity" do
    it "adds entity with foreign keys" do
      entity = MockEntity.new("User", [
        MockAttribute.new("id", "integer"),
        MockAttribute.new("name", "string"),
        MockAttribute.new("group_id", "integer", true)
      ])

      diagram = RailsErd::PlantUml.new(@domain)
      diagram.send(:add_entity, entity)

      markup = diagram.instance_variable_get(:@markup)
      _(markup.join("\n")).must_include "class User {"
      _(markup.join("\n")).must_include ".. Foreign Keys .."
      _(markup.join("\n")).must_include "+ group_id : integer"
    end

    it "adds entity without foreign keys" do
      entity = MockEntity.new("User", [
        MockAttribute.new("id", "integer"),
        MockAttribute.new("name", "string")
      ])

      diagram = RailsErd::PlantUml.new(@domain)
      diagram.send(:add_entity, entity)

      markup = diagram.instance_variable_get(:@markup)
      _(markup.join("\n")).must_include "class User {"
      _(markup.join("\n")).wont_include ".. Foreign Keys .."
    end
  end

  describe "#add_relationship" do
    it "adds one-to-many relationship" do
      relationship = MockRelationship.new(
        MockEntity.new("User"),
        MockEntity.new("Post"),
        :many
      )

      diagram = RailsErd::PlantUml.new(@domain)
      diagram.send(:add_relationship, relationship)

      markup = diagram.instance_variable_get(:@markup)
      _(markup.join("\n")).must_include 'User "1" -- "*" Post'
    end

    it "adds one-to-many relationship with optional source" do
      relationship = MockRelationship.new(
        MockEntity.new("User"),
        MockEntity.new("Post"),
        :many,
        true
      )

      diagram = RailsErd::PlantUml.new(@domain)
      diagram.send(:add_relationship, relationship)

      markup = diagram.instance_variable_get(:@markup)
      _(markup.join("\n")).must_include 'User "0..1" -- "*" Post'
    end

    it "adds many-to-many relationship" do
      relationship = MockRelationship.new(
        MockEntity.new("User"),
        MockEntity.new("Role"),
        :many_to_many
      )

      diagram = RailsErd::PlantUml.new(@domain)
      diagram.send(:add_relationship, relationship)

      markup = diagram.instance_variable_get(:@markup)
      _(markup.join("\n")).must_include 'User "*" -- "*" Role'
    end

    it "adds one-to-one relationship" do
      relationship = MockRelationship.new(
        MockEntity.new("User"),
        MockEntity.new("Profile"),
        :one
      )

      diagram = RailsErd::PlantUml.new(@domain)
      diagram.send(:add_relationship, relationship)

      markup = diagram.instance_variable_get(:@markup)
      _(markup.join("\n")).must_include 'User "1" -- "1" Profile'
    end
  end

  describe "#save" do
    it "generates valid plantuml file" do
      entities = [
        MockEntity.new("User", [
          MockAttribute.new("id", "integer"),
          MockAttribute.new("name", "string")
        ]),
        MockEntity.new("Post", [
          MockAttribute.new("id", "integer"),
          MockAttribute.new("user_id", "integer", true)
        ])
      ]

      relationships = [
        MockRelationship.new(entities[0], entities[1], :many)
      ]

      domain = MockDomain.new(entities, relationships)
      diagram = RailsErd::PlantUml.new(domain, title: "Test Diagram", filename: @filename)

      saved_file = diagram.save
      content = File.read(saved_file)

      _(content).must_include "@startuml Test_Diagram"
      _(content).must_include "title Test Diagram"
      _(content).must_include "class User {"
      _(content).must_include "class Post {"
      _(content).must_include 'User "1" -- "*" Post'
      _(content).must_include "@enduml"
    end

    it "saves with only option" do
      entities = [
        MockEntity.new("User"),
        MockEntity.new("Post"),
        MockEntity.new("Comment")
      ]

      relationships = [
        MockRelationship.new(entities[0], entities[1], :many),
        MockRelationship.new(entities[1], entities[2], :many)
      ]

      domain = MockDomain.new(entities, relationships)
      diagram = RailsErd::PlantUml.new(domain, only: ["User", "Post"], filename: @filename)

      saved_file = diagram.save
      content = File.read(saved_file)

      _(content).must_include "class User"
      _(content).must_include "class Post"
      _(content).wont_include "class Comment"
      _(content).must_include 'User "1" -- "*" Post'
      _(content).wont_include 'Post "1" -- "*" Comment'
    end

    it "includes generation note" do
      diagram = RailsErd::PlantUml.new(@domain, filename: @filename)
      saved_file = diagram.save
      content = File.read(saved_file)

      _(content).must_match(/note "Generated by SOFware on \d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}.*" as GenerationNote/)
    end
  end
end
