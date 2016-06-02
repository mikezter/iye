module I18nYamlEditor
  class Entity

    def self.attributes(*args)
      mod = Module.new do
        args.each do |attr|
          define_method attr do
            attributes[attr]
          end

          define_method "#{attr}=" do |val|
            attributes[attr] = val
          end
        end
      end
      include mod
    end

    attr_reader :attributes

    def initialize(attributes = {})
      raise "Attributes is not a Hash: #{attributes.inspect}" unless attributes.is_a?(Hash)
      @attributes = {}
      self.write_attributes(attributes)
    end

    def write_attributes(attributes)
      attributes.each do |key, value|
        self.send("#{key}=", value)
      end
    end

    def [](key)
      attributes[key]
    end
    def []=(key, value)
      attributes[key] = value
    end

    def to_h
      attributes
    end

  end
end