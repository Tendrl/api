module Tendrl
  class Cluster
    attr_accessor :uuid

    def initialize(cluster_id)
      @uuid = cluster_id
    end

    def data
      @data ||= Tendrl.recurse(
        Tendrl.etcd.get(
          "/clusters/#{@uuid}", recursive: true
        )
      )[@uuid] rescue {'endpoints' => {}, 'short_name' => nil}
    end

    def endpoints
      @endpoints ||= data['endpoints'].values.sort.uniq.map { |e| JSON.parse e }
    end

    def gd2
      @gd2 ||= endpoints.map { |e| Gd2Client.new e }.find(&:ping?).generate_api_methods
    end

    def to_json(_ = nil)
      gd2
        .statedump.to_h
        .merge(endpoints: endpoints)
        .merge(peers: @gd2.get_peers.to_a)
        .merge(volumes: @gd2.volume_list.to_a)
        .merge(short_name: short_name)
        .to_json
    end

    def short_name
      data['short_name']
    end

    def add_endpoint(peer_id, endpoint)
      Tendrl.etcd.set(
        "/clusters/#{@uuid}/endpoints/#{peer_id}",
        value: endpoint.to_json
      )
      @data = nil
      @endpoints = nil
    end

    def add_short_name(name)
      Tendrl.etcd.set(
        "/clusters/#{@uuid}/short_name",
        value: name.present? ? name : uuid
      )
      @data = nil
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
