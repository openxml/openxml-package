module OpenXml
  module HasChildren
    attr_reader :children

    def initialize
      @children = []
    end

    def <<(child)
      children << child
    end

    def push(child)
      children.push(child)
    end

    def to_xml(xml)
      super(xml) do
        yield xml if block_given?
        children.each do |child|
          child.to_xml(xml)
        end
      end
    end

    def render?
      super || children.any?
    end

  end
end
