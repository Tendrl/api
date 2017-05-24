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
                            'nodes'
                           )
          nodes = attributes.delete('nodes')
          cluster_nodes = {}
          if nodes.present?
            nodes.each do |node_id, values|
              next if values['nodecontext'].blank?
              cluster_nodes[node_id] = values['nodecontext']
              glusterbricks = values['glusterbricks']
              if glusterbricks && glusterbricks['all'].present?
                cluster_nodes[node_id]['bricks'] = {}
                cluster_nodes[node_id]['bricks']['free'] = []
                cluster_nodes[node_id]['bricks']['used'] = []
                free = glusterbricks['free'] ? glusterbricks['free'].keys : []
                used = glusterbricks['used'] ? glusterbricks['used'].keys : []
                glusterbricks['all'].each do |name, attributes|
                  if free.include?(name)
                    cluster_nodes[node_id]['bricks']['free'] <<
                    attributes['brick_path']
                  else
                    cluster_nodes[node_id]['bricks']['used'] <<
                    attributes['brick_path']
                  end
                end
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
