module Tendrl
  class Flow
    METHOD_MAPPING = {
      'create' => 'POST',
      'update' => 'PUT',
      'delete' => 'DELETE',
      'action' => 'GET'
    }.freeze

    attr_reader :namespace, :flow_name

    def initialize(namespace, flow_name, object = nil)
      @instance = Tendrl.current_definitions
      @namespace = namespace
      @flow_name = flow_name
      @object = object
      @objects = @instance[namespace]['objects']
      flows = @instance[namespace]['flows'] || {}
      @flow = flows[flow_name] || @objects[object]['flows'][flow_name]
    end

    def objects
      @objects.keys.map do |object_name|
        Object.new(namespace, object_name)
      end
    end

    def sds_name
      if @namespace.end_with?('gluster')
        'gluster'
      elsif @namespace.end_with?('ceph')
        'ceph'
      end
    end

    def name
      "#{sds_name.to_s.capitalize}#{@flow_name}"
    end

    def tags(context)
      tags = []
      return tags unless @flow['tags']
      @flow['tags'].each do |tag|
        finalized_tag = []
        placeholders = tag.split('/')
        placeholders.each do |placeholder|
          finalized_tag << if placeholder.start_with?('$')
                            context[placeholder[1..-1]]
                          else
                            placeholder
                          end
        end
        tags << finalized_tag.join('/')
      end
      tags
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
        next unless [
          'namespace.tendrl',
          'namespace.gluster',
          'namespace.ceph',
          'namespace.node_agent'
        ].include?(key)
        if Tendrl.current_definitions[key]['flows']
          Tendrl.current_definitions[key]['flows'].keys.each do |fk|
            flow = Tendrl::Flow.new(key, fk)
            flows << {
              name: flow.name,
              method: flow.method,
              attributes: flow.attributes
            }
          end
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
      flows
    end

    def self.find_by_external_name_and_type(external_name, type)
      if type == 'node'
        namespace = 'namespace.tendrl'
        flow = external_name
      elsif type == 'cluster'
        partial_namespace = 'namespace'
        sds_parameters = external_name.underscore.split('_')
        namespace = "#{partial_namespace}.#{sds_parameters[0].downcase}"
        flow = sds_parameters[1..-1].join('_').to_s.camelize
        object = sds_parameters[2].capitalize
      elsif type == 'node_agent'
        namespace = 'namespace.node_agent'
        flow = external_name
      end
      new(namespace, flow, object)
    end
  end
end
