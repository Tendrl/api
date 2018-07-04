module Tendrl
  class Cluster
    attr_accessor :uuid

    def initialize(cluster_id)
      @uuid = cluster_id
    end

    def endpoints
      Tendrl.etcd.get(
        "/clusters/#{@uuid}/endpoints", recursive: true
      ).children.map(&:value).sort.uniq.map { |e| JSON.parse e }
    end

    def gd2
      @gd2 ||= Gd2Client.from_endpoint endpoints.sample
    end

    class << self
      def exist?(cluster_id)
        Tendrl.etcd.get "/clusters/#{cluster_id}"
      rescue Etcd::KeyNotFound => e
        raise Tendrl::HttpResponseErrorHandler.new(
          e, cause: '/clusters/id', object_id: cluster_id
        )
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
          raise Tendrl::HttpResponseErrorHandler.new(
            e, cause: '/clusters/id', object_id: cluster_id
          )
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
