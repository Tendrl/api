module Tendrl
  class Volume
    class << self

      def find_all_by_cluster_id(cluster_id)
        begin
          Tendrl.etcd.get("/clusters/#{cluster_id}/Volumes", recursive: true)
            .children.map do |node|
            Tendrl.recurse(node)
          end
        rescue Etcd::KeyNotFound, Etcd::NotDir
          []
        end
      end

    end
  end
end
