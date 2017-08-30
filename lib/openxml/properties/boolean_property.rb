module OpenXml
  module Properties
    class BooleanProperty < ValueProperty

      def ok_values
        [nil, true, false]
      end

      def to_xml(xml)
        super if value
      end

    end
  end
end
