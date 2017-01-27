module NodePresenter

  class << self

    def list(nodes_list, existing_cluster_ids)
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
        detected_cluster = node['detectedcluster']
        next if detected_cluster.nil?
        detected_cluster_id = detected_cluster['detected_cluster_id']

        # If the node is part of an imported cluster, don't allow it to be
        # imported again
        imported_cluster_id = node['tendrlcontext']['integration_id'] if \
          node.has_key? 'tendrlcontext'
        if existing_cluster_ids.include?(imported_cluster_id)
          node.delete('detectedcluster')
          next
        end

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
