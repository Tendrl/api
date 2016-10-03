module Tendrl

  class Component

    attr_reader :sds_version, :object_type

    def initialize(sds_version, object_type)
      @object_type = object_type
      @sds_version = sds_version
      raise InvalidObjectError.new("#{object_type} is not a valid object") unless valid_objects.include?(object_type)
      @attributes = attributes
      @actions = actions
    end

    def attributes
      @attributes ||= Tendrl.sds_config[sds_version]['object_details'][object_type]['attrs']
    end

    def valid_objects
      @valid_objects ||= Tendrl.sds_config[sds_version]['valid_objects']
    end

    def actions
      Tendrl.sds_config[sds_version]['object_details'][object_type]['atoms']
    end

  end
end
