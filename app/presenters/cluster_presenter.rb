module ClusterPresenter

  class << self

    def list(cluster_list)
      clusters = []
      cluster_list.each do |cluster|
        clusters << single(cluster)
      end
      clusters.compact
    end

    def single(cluster_attributes)
      cluster = nil
      cluster_attributes.each do |cluster_id, attributes|
        context = attributes.delete('tendrlcontext')
        break if context.nil?
        context['cluster_id'] = cluster_id
        attributes.slice!(
          'errors',
          'globaldetails',
          'nodes',
          'public_network',
          'cluster_network',
          'is_managed',
          'enable_volume_profiling',
          'import_status',
          'import_job_id',
          'alert_counters'
        )
        attributes['errors'] = JSON.parse(attributes['errors']) rescue []
        nodes = attributes.delete('nodes')
        cluster_nodes = []
        if nodes.present?
          nodes.each do |node_id, values|
            next if values['nodecontext'].blank?
            values['nodecontext']['tags'] = JSON.parse(values['nodecontext']['tags']) rescue []
            values['nodecontext']['status'] ||= 'DOWN'
            cluster_nodes << values['nodecontext'].merge({ node_id: node_id })
          end
        end

        if bricks = attributes.delete('bricks')
          attributes.merge!(bricks: bricks(bricks))
        end

        cluster = context.merge(attributes).merge(nodes: cluster_nodes)
      end
      cluster
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
