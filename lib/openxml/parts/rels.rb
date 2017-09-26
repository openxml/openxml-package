require "securerandom"
require "openxml/relationship"
require "nokogiri"

module OpenXml
  module Parts
    class Rels < OpenXml::Part
      include Enumerable

      def self.parse(xml)
        document = Nokogiri::XML(xml)
        self.new.tap do |part|
          document.css("Relationship").each do |rel|
            part.add_relationship rel["Type"], rel["Target"], rel["Id"], rel["TargetMode"]
          end
        end
      end

      def initialize(defaults=[])
        @relationships = []
        Array(defaults).each do |default|
          add_relationship(*default.values_at("Type", "Target", "Id", "TargetMode"))
        end
      end

      def add_relationship(type, target, id=next_id, target_mode=nil)
        OpenXml::Elements::Relationship.new(type, target, id, target_mode).tap do |relationship|
          relationships.push relationship
        end
      end

      def push(relationship)
        relationships.push relationship
      end

      def each(&block)
        relationships.each(&block)
      end

      def empty?
        relationships.empty?
      end

      def to_xml
        build_standalone_xml do |xml|
          xml.Relationships(xmlns: "http://schemas.openxmlformats.org/package/2006/relationships") do
            relationships.each do |rel|
              attributes = { "Id" => rel.id, "Type" => rel.type, "Target" => rel.target }
              attributes["TargetMode"] = rel.target_mode if rel.target_mode
              xml.Relationship(attributes)
            end
          end
        end
      end

    private
      attr_reader :relationships

      def next_id
        @current_id = (@current_id || 0) + 1
        "rId#{@current_id}"
      end

    end
  end
end
