module ClusterPresenter

  class << self

    def list(cluster_list)
      clusters = []
      cluster_list.each do |cluster|
        cluster.each do |cluster_id, attributes|
          context = attributes.delete('tendrlcontext')
          next if context.blank?
          context['cluster_id'] = cluster_id
          attributes.slice!('pools',
                            'volumes',
                            'utilization',
                            'globaldetails',
                            'nodes',
                            'bricks'
                           )
          nodes = attributes.delete('nodes')
          cluster_nodes = {}
          if nodes.present?
            nodes.each do |node_id, values|
              next if values['nodecontext'].blank?
              cluster_nodes[node_id] = values['nodecontext']
            end
          end

          if bricks = attributes.delete('bricks')
            attributes.merge!(bricks: bricks(bricks))
          end

          clusters << context.merge(attributes).merge(nodes: cluster_nodes)
        end
      end
      clusters
    end

    def bricks(bricks)
      all = bricks.delete('all') || {}
      free = {}
      used = {}
      if all.present?
        all.each do |device, attributes|
          if bricks['free'].present? && bricks['free'].keys.include?(device)
            free[device] = attributes
          elsif bricks['used'].present? && bricks['used'].keys.include?(device)
            used[device] = attributes
          end
        end
      end
      { all: all, used: used, free: free }
    end

  end
end
