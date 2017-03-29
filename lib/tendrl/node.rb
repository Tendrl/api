module Tendrl
  class Node

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
