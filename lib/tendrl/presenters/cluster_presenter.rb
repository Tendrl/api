module ClusterPresenter

  class << self

    def list(cluster_list)
      clusters = []
      cluster_list.each do |cluster|
        cluster.each do |cluster_id, attributes|
          cluster_attr = { 'cluster_id' => cluster_id }
          clusters << cluster_attr.merge(attributes) 
        end
      end
      clusters
    end

  end

end
