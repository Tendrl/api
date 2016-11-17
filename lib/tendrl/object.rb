module Tendrl
  class Object
    def initialize(namespace, type)
      @config = Tendrl.current_definitions
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

    def self.find_by_object_name(object_name)
      object = nil
      Tendrl.current_definitions.keys.each do |key|
        next if key == 'tendrl_schema_version'
        objects = Tendrl.current_definitions[key]['objects'].keys
        if objects.include?(object_name)
          object = Object.new(key, object_name)
          break
        end
      end
      object
    end

    def self.find_by_attribute(attribute)
      object_name, attribute = attribute.split('.')
      object = find_by_object_name(object_name)
      attribute = object.attributes.find{|a| a.name == attribute }
      attribute.to_hash
    end

  end
end
