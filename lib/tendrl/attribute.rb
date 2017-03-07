module Tendrl
  class Attribute

    attr_reader :name, :help, :type, :default, :required

    def initialize(object_type, name, attributes)
      attributes ||= {}
      @object_type = object_type
      @name = name
      @help = attributes['help']
      @type = attributes['type']
      @default = attributes['default']
      @required = nil
    end

    def to_hash
      {
        name: "#{@object_type}.#{@name}",
        help: @help,
        type: @type,
        default: @default,
        required: @required
      }
    end

  end
end
