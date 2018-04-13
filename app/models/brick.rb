module Tendrl
  class Brick
    class << self
      def find_all_by_cluster_id_and_node_fqdn(cluster_id, fqdn)
        begin
          Tendrl.etcd.get("/clusters/#{cluster_id}/Bricks/all/#{fqdn}", recursive: true)
            .children.inject({}) do |bricks, node|
            bricks.merge! Tendrl.recurse(node)
          end
        rescue Etcd::KeyNotFound, Etcd::NotDir
          {}
        end
      end

      def find_refs_by_cluster_id_and_volume_id(cluster_id, volume_id)
        begin
          Tendrl.etcd.get("/clusters/#{cluster_id}/Volumes/#{volume_id}/Bricks", recursive: true)
                .children.inject({}) do |subvolume_refs, subvolume|
            sv_paths = Tendrl.recurse(subvolume, {}, downcase_keys: false)
            sv_paths.each { |name, paths| sv_paths[name] = paths.keys }
            subvolume_refs.merge sv_paths
          end
        rescue Etcd::KeyNotFound, Etcd::NotDir
        end
      end

      def find_by_cluster_id_and_refs(cluster_id, sub_volumes)
        bricks = {}
        sub_volumes.collect_concat do |sub_volume, paths|
          paths.collect_concat do |path|
            path = path.sub(':_', '/')
            begin
              path_bricks = Tendrl.recurse(
                Tendrl.etcd.get(
                  "/clusters/#{cluster_id}/Bricks/all/#{path}",
                  recursive: true
                )
              )
              path_bricks.each_value { |brick| brick['subvolume'] = sub_volume }
              bricks.merge! path_bricks
            rescue Etcd::KeyNotFound, Etcd::NotDir
            end
          end
        end
        bricks
      end
    end
  end
end
