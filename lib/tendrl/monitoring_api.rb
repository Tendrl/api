require 'net/http'
require 'uri'
module Tendrl
  class MonitoringApi

    attr_accessor :base_uri

    def initialize(config)
      scheme = config['api_server_scheme'] || 'http'
      hostname = config['api_server_addr']
      port = config['api_server_port']
      @base_uri = "#{scheme}://#{hostname}:#{port}"
    end

    def nodes(node_ids="")
      path = "/monitoring/nodes/summary"
      path += "?node_ids=#{node_ids.split(',').compact.join(',')}" if node_ids.present?
      uri = URI(
        "#{base_uri}#{path}"
      )
      response = Net::HTTP.get(uri)
      JSON.parse(response)
    rescue JSON::ParserError, Errno::ECONNREFUSED
      []
    end

    def node_memory_percent_used(node_id, interval='')
      uri = URI(
        "#{base_uri}/monitoring/nodes/#{node_id}/memory.percent-used/stats?interval=#{interval}"
      )
      response = Net::HTTP.get(uri)
      JSON.parse(response)
    rescue JSON::ParserError, Errno::ECONNREFUSED
      []
    end

    def node_swap_percent_used(node_id, interval='')
      uri = URI(
        "#{base_uri}/monitoring/nodes/#{node_id}/swap.percent-used/stats?interval=#{interval}"
      )
      response = Net::HTTP.get(uri)
      JSON.parse(response)
    rescue JSON::ParserError, Errno::ECONNREFUSED
      []
    end

    def node_throughput(node_id, type='cluster_network', interval='')
      uri = URI(
        "#{base_uri}/monitoring/nodes/#{node_id}/network_throughput-#{type}.gauge-used/stats?interval=#{interval}"
      )
      response = Net::HTTP.get(uri)
      JSON.parse(response)
    rescue JSON::ParserError, Errno::ECONNREFUSED
      []
    end

    def node_iops(node_id, interval='')
      uri = URI(
        "#{base_uri}/monitoring/nodes/#{node_id}/iops/stats?interval=#{interval}"
      )
      response = Net::HTTP.get(uri)
      JSON.parse(response)
    rescue JSON::ParserError, Errno::ECONNREFUSED
      []
    end

    def node_cpu(node_id, interval='')
      uri = URI(
        "#{base_uri}/monitoring/nodes/#{node_id}/cpu.cpu_system_user.percent-used/stats?interval=#{interval}"
      )
      response = Net::HTTP.get(uri)
      JSON.parse(response)
    rescue JSON::ParserError, Errno::ECONNREFUSED
      []
    end

    def node_storage(node_id, interval='')
      uri = URI(
        "#{base_uri}/monitoring/nodes/#{node_id}/storage.percent-used/stats?interval=#{interval}"
      )
      response = Net::HTTP.get(uri)
      JSON.parse(response)
    rescue JSON::ParserError, Errno::ECONNREFUSED
      []
    end

    def cluster(cluster_id)
      uri = URI(
        "#{base_uri}/monitoring/clusters/#{cluster_id}/summary"
      )
      response = Net::HTTP.get(uri)
      JSON.parse(response)
    rescue JSON::ParserError, Errno::ECONNREFUSED
      []
    end

    def cluster_utilization(cluster_id, interval='')
      uri = URI(
        "#{base_uri}/monitoring/clusters/#{cluster_id}/utilization/percent_used/stats?interval#{interval}"
      )
      response = Net::HTTP.get(uri)
      JSON.parse(response)
    rescue JSON::ParserError, Errno::ECONNREFUSED
      []
    end

    def cluster_throughput(cluster_id, type='cluster_network', interval='')
      uri = URI(
        "#{base_uri}/monitoring/clusters/#{cluster_id}/throughput/#{type}/stats?interval=#{interval}"
      )
      response = Net::HTTP.get(uri)
      JSON.parse(response)
    rescue JSON::ParserError, Errno::ECONNREFUSED
      []
    end

    def cluster_iops(cluster_id, interval='')
      uri = URI(
        "#{base_uri}/monitoring/clusters/#{cluster_id}/iops/stats?interval=#{interval}"
      )
      response = Net::HTTP.get(uri)
      JSON.parse(response)
    rescue JSON::ParserError, Errno::ECONNREFUSED
      []
    end

    def cluster_latency(cluster_id, interval='')
      uri = URI(
        "#{base_uri}/monitoring/clusters/#{cluster_id}/latency/stats?interval=#{interval}"
      )
      response = Net::HTTP.get(uri)
      JSON.parse(response)
    rescue JSON::ParserError, Errno::ECONNREFUSED
      []
    end

    def clusters_iops(cluster_ids="", interval='')
      path = "/monitoring/clusters/iops?interval=#{interval}"
      path += "&cluster_ids=#{cluster_ids.split(',').compact.join(',')}" if cluster_ids.present?
      uri = URI(
        "#{base_uri}#{path}"
      )
      response = Net::HTTP.get(uri)
      JSON.parse(response)
    rescue JSON::ParserError, Errno::ECONNREFUSED
      []
    end

    def system(sds_name)
      uri = URI(
        "#{base_uri}/monitoring/system/#{sds_name}/summary"
      )
      response = Net::HTTP.get(uri)
      JSON.parse(response)
    rescue JSON::ParserError, Errno::ECONNREFUSED
      []
    end

    def system_utilization(sds_name, interval='')
      uri = URI(
        "#{base_uri}/monitoring/system/#{sds_name}/utilization/percent_used/stats?interval=#{interval}"
      )
      response = Net::HTTP.get(uri)
      JSON.parse(response)
    rescue JSON::ParserError, Errno::ECONNREFUSED
      []
    end

    def system_throughput(sds_name, type='cluster_network', interval='')
      uri = URI(
        "#{base_uri}/monitoring/system/#{sds_name}/throughput/#{type}/stats?interval=#{interval}"
      )
      response = Net::HTTP.get(uri)
      JSON.parse(response)
    rescue JSON::ParserError, Errno::ECONNREFUSED
      []
    end

  end
end
