module NodePresenter
  class << self
    def list(nodes_list)
      nodes = []
      nodes_list.each do |node|
        node.each do |_, attributes|
          attributes.slice!('nodecontext','tendrlcontext','alert_counters')
          node_attr = attributes.delete('nodecontext')
          next if node_attr.blank?
          node_attr['tags'] = JSON.parse(node_attr['tags']) rescue []
          node_attr['status'] ||= 'DOWN'
          if cluster = attributes.delete('tendrlcontext')
            cluster.delete('node_id')
          end
          nodes << node_attr.merge(attributes).merge(cluster: (cluster || {}))
        end
      end
      nodes
    end
  end
end
