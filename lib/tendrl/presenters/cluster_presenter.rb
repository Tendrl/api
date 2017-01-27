module ClusterPresenter

  class << self

    def list(cluster_list)
      clusters = []
      cluster_list.each do |cluster|
        cluster.each do |cluster_id, attributes|
          # attributes.slice!('pools', 'volumes')
          context = attributes.delete('tendrlcontext')
          context['cluster_id'] = cluster_id
          attributes.slice!('pools', 'volumes')
          clusters << context.merge(attributes)
        end
      end
      clusters
    end

  end

end
