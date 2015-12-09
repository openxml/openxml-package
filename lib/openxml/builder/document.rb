module OpenXml
  class Builder
    class Document < SimpleDelegator

      def initialize(*args)
        super Ox::Document.new(*args)
      end

      def ancestors
        [self]
      end

    end
  end
end
