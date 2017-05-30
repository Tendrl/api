module NodePresenter

  class << self

    def list(nodes_list, existing_cluster_ids)
      nodes = []
      nodes_list.each do |node|
        node.each do |_, attributes|
          attributes.delete('services')
          attributes.delete('messages')
          node_attr = attributes.delete('nodecontext')
          next if node_attr.blank?
          localstorage = attributes.delete('localstorage')
          if localstorage.present?
            attributes.merge!(localstorage: {
              virtio: virtio(localstorage),
              disks: disks(localstorage),
              blockdevices: blockdevices(localstorage)
            })
          end
          nodes << node_attr.merge(attributes)
        end
      end
      clusters = []
      nodes.each do |node|
        detected_cluster = node['detectedcluster']
        next if detected_cluster.nil?
        detected_cluster_id = detected_cluster['detected_cluster_id']
        next if detected_cluster_id.blank?

        # If the node is part of an imported cluster, don't allow it to be
        # imported again
        imported_cluster_id = node['tendrlcontext']['integration_id'] if \
          node.has_key? 'tendrlcontext'
        next if existing_cluster_ids.include?(imported_cluster_id)

        if cluster = clusters.find{|e| e[:cluster_id] == detected_cluster_id }
          cluster[:node_ids] << node['node_id']
        else
          clusters << {
            cluster_id: detected_cluster_id,
            sds_name: detected_cluster['sds_pkg_name'],
            sds_version: detected_cluster['sds_pkg_version'],
            node_ids: [node['node_id']]
          }
        end
      end
      [nodes, clusters]
    end


    def virtio(data)
      virtio = data.delete('virtio') || {}
      virtio.each do |device, attributes|
        if attributes['partitions']
          attributes['partitions'] = JSON.parse(attributes['partitions']) rescue
          {}
        end
      end
      virtio
    end

    def disks(data)
      disks = data.delete('disks') || {}
      disks.delete('rawreference')
      disks.each do |device, attributes|
        if attributes['partitions']
          attributes['partitions'] = JSON.parse(attributes['partitions']) rescue
          {}
        end
      end
      disks
    end

    def blockdevices(data)
      blkd = data.delete('blockdevices') || {}
      all = blkd['all']
      used = {}
      free = {}
      if all.present?
        all.each do |device, attributes|
          if attributes['partitions']
            attributes['partitions'] = JSON.parse(attributes['partitions']) rescue
            {}
          end

          if blkd['used'].keys.include?(device)
            used[device] = attributes
          elsif blkd['free'].keys.include?(device)
            free[device] = attributes
          end

        end
      end
      { all: all, used: used, free: free }
    end

  end

end
