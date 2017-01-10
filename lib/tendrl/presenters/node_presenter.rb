module NodePresenter

  class << self

    def list(nodes_list)
      nodes = []
      nodes_list.each do |node|
        node.each do |_, attributes|
          node_attr = attributes.delete('node')
          nodes << node_attr.merge(attributes) 
        end
      end
      clusters = []
      nodes.group_by{|k, v| k['tendrl_context']['cluster_id'] }.each do |key,
        values |
        cluster = { cluster_id: key, node_ids: [] }
        values.each do |val|
          cluster[:node_ids] << val['tendrl_context']['node_id']
        end
        clusters << cluster
      end
      [nodes, clusters]
    end

  end

end
