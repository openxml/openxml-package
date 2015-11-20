require "securerandom"

module OpenXml
  module Parts
    class Rels < OpenXml::Part
      include Enumerable

      def self.parse(xml)
        document = Nokogiri(xml)
        self.new.tap do |part|
          document.css("Relationship").each do |rel|
            part.add_relationship rel["Type"], rel["Target"], rel["Id"]
          end
        end
      end

      def initialize(defaults=[])
        @relationships = []
        Array(defaults).each do |default|
          add_relationship(*default.values_at("Type", "Target", "Id"))
        end
      end

      def add_relationship(type, target, id=nil)
        Relationship.new(type, target, id).tap do |relationship|
          relationships.push relationship
        end
      end

      def each(&block)
        relationships.each(&block)
      end

      def to_xml
        build_standalone_xml do |xml|
          xml.Relationships(xmlns: "http://schemas.openxmlformats.org/package/2006/relationships") do
            relationships.each do |rel|
              xml.Relationship("Id" => rel.id, "Type" => rel.type, "Target" => rel.target)
            end
          end
        end
      end



      class Relationship < Struct.new(:type, :target, :id)
        def initialize(type, target, id=nil)
          super type, target, id || "R#{SecureRandom.hex}"
        end
      end

    private
      attr_reader :relationships

    end
  end
end
