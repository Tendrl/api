module Tendrl
  class Cluster

    attr_accessor :attributes

    def initialize(attributes={})
      @attributes = attributes
    end

    def update_attributes(attributes)
      attributes.each do |key, value|
        Tendrl.etcd.set("/clusters/#{@attributes['integration_id']}/#{key}", value: value)
        @attributes[key.to_s] = value
      end
      self
    end

    class << self

      def exist?(cluster_id)
      end

      def find(cluster_id)
        attributes = {}
        begin
          attributes = Tendrl.recurse(
            Tendrl.etcd.get(
              "/clusters/#{cluster_id}", recursive: true
            )
          )[cluster_id]
        rescue Etcd::KeyNotFound
        end
        new(attributes)
      end

      def all
        begin
          Tendrl.etcd.get('/clusters', recursive: true).children.map do |cluster|
            Tendrl.recurse(cluster)
          end
        rescue Etcd::KeyNotFound
          []
        end
      end
    end

  end
end
