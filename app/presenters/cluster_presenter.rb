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
      attributes = cluster_attributes.values[0]
      attributes = attributes.merge!('cluster_id' => cluster_attributes.keys[0])
      attributes['errors'] = JSON.parse(attributes['errors']) rescue []
      if bricks = attributes.delete('bricks')
        attributes.merge!(bricks: bricks(bricks))
      end
      attributes
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
