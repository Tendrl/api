module Tendrl
  class Flow

    METHOD_MAPPING = { 'create' => 'POST', 'update' => 'PUT', 'delete' =>
                       'DELETE', 'action' => 'GET' }

    attr_reader :namespace, :flow_name

    def initialize(namespace, flow_name, object=nil)
      @instance = Tendrl.current_definitions
      @namespace = namespace
      @flow_name = flow_name
      @object = object
      @flow = @instance[namespace]['flows'][flow_name] ||
        @instance[namespace]['objects'][object]['flows'][flow_name]
    end

    def objects
      @flow['atoms'].map do |atom|
        atom = "namespace.#{atom}"
        namespace, object = atom.split('.objects.')
        object_type = object.split('.atoms.').first
        Object.new(namespace, object_type)
      end
    end

    def sds_name
      if @namespace.end_with?('_integration')
        @namespace.split('.').last.split('_')[0].camelize
      end
    end

    def name
      "#{sds_name}#{@flow_name}"
    end

    def reference_attributes
      attributes = []
      objects.each do |obj|
        attributes << obj.attributes
      end
      attributes
    end

    def attributes
      mandatory_attributes + optional_attributes
    end

    def type
      @flow['type'].downcase
    end

    def run
      @flow['run']
    end

    def method
      METHOD_MAPPING[type] || 'POST'
    end

    def mandatory_attributes
      flow_attributes = []
      mandatory_attributes = @flow['inputs']['mandatory'] || []
      mandatory_attributes.each do |ma|
        next if ma.end_with?('cluster_id')
        if ma.end_with?('[]')
          flow_attributes << { name: ma, type: 'List',
                               required: true }
        else
          attribute = Object.find_by_attribute(ma)
          attribute[:required] = true
          flow_attributes << attribute
        end
      end
      flow_attributes
    end

    def optional_attributes
      flow_attributes = []
      optional_attributes = @flow['inputs']['optional'] || []
      optional_attributes.each do |ma|
        next if ma.end_with?('cluster_id')
        if ma.end_with?('[]')
          flow_attributes << { 
            name: ma,
            type: 'List',
            required: false 
          }
        else
          attribute = Object.find_by_attribute(ma)
          attribute[:required] = false
          flow_attributes << attribute
        end
      end
      flow_attributes
    end


    def self.find_all
      flows = []
      Tendrl.current_definitions.keys.map do |key|
        if key.end_with?('_integration')
          Tendrl.current_definitions[key]['flows'].keys.each do |fk|
            flow = Tendrl::Flow.new(key, fk)
            flows << { 
              name: flow.name,
              method: flow.method,
              attributes: flow.attributes  
            } 
          end
          Tendrl.current_definitions[key]['objects'].keys.each do |ok|
            object_flows = Tendrl.current_definitions[key]['objects'][ok]['flows']
            next if object_flows.nil?
            object_flows.keys.each do |fk|
              flow = Tendrl::Flow.new(key, fk, ok)
              flows << { 
                name: flow.name,
                method: flow.method,
                attributes: flow.attributes  
              } 
            end
          end
        end
      end
      flows
    end

    def self.find_by_external_name_and_type(external_name, type)
      if type == 'node'
        partial_namespace = 'namespace.tendrl.node_agent'
      elsif type == 'cluster'
        partial_namespace = 'namespace.tendrl'
      end
      sds_name, operation, object = external_name.underscore.split('_')
      namespace = "#{partial_namespace}.#{sds_name}_integration"
      flow = "#{operation}_#{object}".camelize
      new(namespace, flow, object.capitalize)
    end

  end
end
