module ClusterPresenter

  class << self

    def list(cluster_list)
      clusters = []
      cluster_list.each do |cluster|
        cluster.each do |cluster_id, attributes|
          context = attributes.delete('tendrlcontext')
          context['cluster_id'] = cluster_id
          attributes.slice!('pools',
                            'volumes',
                            'utilization',
                            'globaldetails',
                            'nodes'
                           )
          nodes = attributes.delete('nodes')
          cluster_nodes = {}
          if nodes.present?
            nodes.each do |node_id, values|
              cluster_nodes[node_id] = values['nodecontext']
              glusterbricks = values['glusterbricks']
              if glusterbricks
                cluster_nodes[node_id]['bricks'] = {}
                cluster_nodes[node_id]['bricks']['free'] = glusterbricks['free'].keys if glusterbricks['free']
                cluster_nodes[node_id]['bricks']['used'] = glusterbricks['used'].keys if glusterbricks['used']
              end
            end
          end
          clusters << context.merge(attributes).merge(nodes: cluster_nodes)
        end
      end
      clusters
    end

  end

end
