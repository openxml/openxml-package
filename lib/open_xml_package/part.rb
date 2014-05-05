class OpenXmlPackage
  class Part < Struct.new(:path, :content)
    
    def content
      self[:content] = self[:content].get_input_stream.read if promise?
      super
    end
    
    def promise?
      self[:content].respond_to?(:get_input_stream)
    end
    
  end
end
