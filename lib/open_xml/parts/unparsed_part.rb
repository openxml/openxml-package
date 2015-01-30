module OpenXml
  module Parts
    class UnparsedPart

      def initialize(content)
        @content = content
      end

      def content
        @content = @content.get_input_stream.read if promise?
        @content
      end

      def promise?
        @content.respond_to? :get_input_stream
      end

    end
  end
end
