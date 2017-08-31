module OpenXml
  module Properties
    class OnOffProperty < ValueProperty

      def ok_values
        [true, false, :on, :off] # :on and :off are from the Transitional Spec
      end

      def to_xml(xml)
        if value == true
          apply_namespace(xml).public_send(tag) do
            yield xml if block_given?
          end
        else
          super
        end
      end

    end
  end
end
