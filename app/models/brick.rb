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
            parsed = Tendrl.recurse(node)
            parsed = [parsed] if parsed.is_a? Hash
            parsed.each do |ref|
              ref.each do |_, attrs|
                next if attrs.nil?
                attrs.each do |path, _|
                  refs << path
                end
              end
            end
          end
        rescue Etcd::KeyNotFound, Etcd::NotDir
        end
        refs
      end

      def find_by_cluster_id_and_refs(cluster_id, brick_paths)
        bricks = []
        brick_paths.each do |path|
          path = path.sub(":_","/")
          begin
            bricks << Tendrl.recurse(
              Tendrl.etcd.get(
                "/clusters/#{cluster_id}/Bricks/all/#{path}",
                recursive: true
              )
            )
          rescue Etcd::KeyNotFound, Etcd::NotDir
          end
        end
        bricks
      end

    end

  end
end
