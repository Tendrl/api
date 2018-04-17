module Tendrl
  class Node

    class << self

      # TODO: The interface sucks. Don't like making people use .nil? here and
      # .exist? in the actual object.
      def self.find_by_ip(ip)
        begin
          uuid = Tendrl.etcd.get("/indexes/ip/#{ip}").value
        rescue ::Etcd::KeyNotFound
          return nil
        end
        new(uuid)
      end

      def all
        Tendrl.etcd.get('/nodes').children.map do |node|
          begin
            nodecontext = Tendrl.recurse(Tendrl.etcd.get("#{node.key}/NodeContext"))
            tendrlcontext = Tendrl.recurse(Tendrl.etcd.get("#{node.key}/TendrlContext"))
            counters = Tendrl.recurse(Tendrl.etcd.get("#{node.key}/alert_counters"))
            node_key = node.key.split('/')[-1]
            { node_key => nodecontext.merge(tendrlcontext).merge(counters) }
          rescue Etcd::KeyNotFound, Etcd::NotDir
          end
        end.compact
      rescue Etcd::KeyNotFound, Etcd::NotDir
        []
      end

      def find_all_by_cluster_id(cluster_id)
        begin
          tendrlcontext = Tendrl.recurse(Tendrl.etcd.get("/clusters/#{cluster_id}/TendrlContext"))
          Tendrl.etcd.get("/clusters/#{cluster_id}/nodes", recursive: true)
            .children.map do |node|
            node = Tendrl.recurse(node)
            node.values.first.merge!(tendrlcontext)
            node
          end
        rescue Etcd::KeyNotFound, Etcd::NotDir
          []
        end
      end

      def find_by_cluster_id(cluster_id, node_id)
        node = {}
        begin
          Tendrl.recurse Tendrl.etcd.get("/clusters/#{cluster_id}/nodes/#{node_id}/NodeContext")
        rescue Etcd::KeyNotFound
        end
        node
      end

    end

    attr_reader :uuid

    def initialize(uuid)
      @uuid   = uuid
      @exists = true
      begin
        @path = Tendrl.etcd.get("/nodes/#{uuid}")
      rescue ::Etcd::KeyNotFound
        @exists = false
      end
    end

    def exist?
      @exists
    end
  end
end
