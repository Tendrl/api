module Tendrl
  class Object
    def initialize(namespace, type)
      @config = Tendrl.node_definitions
      @type = type
      @namespace = namespace
      @object = @config[namespace]['objects'][type]
    end

    def attributes
      @object['attrs'].map do |attr_name, values|
        Attribute.new(@type, attr_name, values)
      end
    end

    def atoms
      @object['atoms'].map do |atom_name, values|
        Atom.new(atom_name, values)
      end
    end

    def self.find_by_attribute(attribute)
      object, attribute = attribute.split('.')
      config = Tendrl.node_definitions
      objects = config['namespace.tendrl.node_agent']['objects']
      attrs = objects[object]['attrs']
      attrs[attribute].merge(name: "#{object}.#{attribute}")
    end

  end
end
