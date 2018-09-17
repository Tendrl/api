module Tendrl
  class Cluster
    attr_accessor :uuid

    def initialize(cluster_id)
      @uuid = cluster_id
    end

    def endpoints
      @endpoints ||= Tendrl.etcd.get(
        "/clusters/#{@uuid}/endpoints", recursive: true
      ).children.map(&:value).sort.uniq.map { |e| JSON.parse e }
    rescue Etcd::KeyNotFound
      []
    end

    def gd2
      @gd2 ||= endpoints.map { |e| Gd2Client.new e }.find(&:ping?)
    end

    def to_json(_)
      gd2.statedump.merge(endpoints: endpoints).to_json
    end

    def add_endpoint(endpoint)
      Tendrl.etcd.create_in_order(
        "/clusters/#{@uuid}/endpoints",
        value: endpoint.to_json
      )
      @endpoints = nil
    end

    class << self
      def find(cluster_id)
        cluster = new(cluster_id)
        cluster.gd2.present? ? cluster : nil
      end

      def all
        Tendrl.etcd.get('/clusters').children.map do |etcd_node|
          Cluster.new File.basename(etcd_node.key)
        end
      rescue Etcd::KeyNotFound
        []
      end
    end
  end
end
