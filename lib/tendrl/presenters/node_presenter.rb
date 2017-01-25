module NodePresenter

  class << self

    def list(nodes_list)
      nodes = []
      nodes_list.each do |node|
        node.each do |_, attributes|
          attributes.delete('service')
          node_attr = attributes.delete('nodecontext')
          nodes << node_attr.merge(attributes) 
        end
      end
      clusters = []
      nodes.each do |node|
        next if node['detectedcluster'].nil?
        detected_cluster = node['detectedcluster']
        detected_cluster_id = detected_cluster['detected_cluster_id']
        if cluster = clusters.find{|e| e[:cluster_id] == detected_cluster_id }
          cluster[:node_ids] << node['node_id']
        else
          clusters << { 
            cluster_id: detected_cluster_id,
            sds_name: detected_cluster['sds_pkg_name'],
            sds_version: detected_cluster['sds_pkg_version'],
            node_ids: [node['node_id']] 
          }
        end
      end
      [nodes, clusters]
    end

  end

end
