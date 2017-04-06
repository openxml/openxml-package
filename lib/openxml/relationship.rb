module OpenXml
  module Elements
      class Relationship < Struct.new(:type, :target, :id, :target_mode)
        def initialize(type, target, id=nil, target_mode=nil)
          super type, target, id || "R#{SecureRandom.hex}", target_mode
        end
      end
  end
end
