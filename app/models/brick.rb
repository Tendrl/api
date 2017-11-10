module Tendrl
  class Brick

    class << self

      def find_all_by_cluster_id_and_node_fqdn(cluster_id, fqdn)
        begin
          Tendrl.etcd.get("/clusters/#{cluster_id}/Bricks/all/#{fqdn}", recursive: true)
            .children.map do |node|
            Tendrl.recurse(node)
          end
        rescue Etcd::KeyNotFound, Etcd::NotDir
          []
        end
      end

      def find_refs_by_cluster_id_and_volume_id(cluster_id, volume_id)
        refs = []
        begin
          Tendrl.etcd.get("/clusters/#{cluster_id}/Volumes/#{volume_id}/Bricks", recursive: true)
            .children.map do |node|
            parsed = Tendrl.recurse(node, {}, { downcase_keys: false })
            parsed = [parsed] if parsed.is_a? Hash
            parsed.each do |ref|
              detail = {}
              ref.each do |sub_volume, attrs|
                next if attrs.blank?
                next if sub_volume.blank?
                detail[sub_volume] = [] 
                attrs.each do |path, _|
                  detail[sub_volume] << path
                end
                refs << detail
              end
            end
          end
        rescue Etcd::KeyNotFound, Etcd::NotDir
        end
        refs
      end

      def find_by_cluster_id_and_refs(cluster_id, sub_volumes)
        bricks = []
        sub_volumes.each do |sub_volume|
          sub_volume.each do |sv, paths|
            sub_volume_bricks = []
            paths.each do |path|
              path = path.sub(":_","/")
              begin
                brick = Tendrl.recurse(
                  Tendrl.etcd.get(
                    "/clusters/#{cluster_id}/Bricks/all/#{path}",
                    recursive: true
                  )
                )
                brick.each{|_, attrs| attrs[:subvolume] = sv }
                bricks << brick
              rescue Etcd::KeyNotFound, Etcd::NotDir
              end
            end
          end
        end
        bricks
      end

    end
  end
end
