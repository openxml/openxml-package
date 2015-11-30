module OpenXml
  class Builder
    class Namespace
      attr_accessor :prefix, :uri

      def initialize(prefix, uri)
        @prefix = prefix.to_s
        @uri = uri
      end

    end
  end
end
