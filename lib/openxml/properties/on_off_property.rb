module OpenXml
  module Properties
    class OnOffProperty < ValueProperty

      def ok_values
        [true, false, :on, :off] # :on and :off are from the Transitional Spec
      end

      def to_xml(xml)
        return apply_namespace(xml).public_send(tag) if value == true
        super
      end

    end
  end
end
