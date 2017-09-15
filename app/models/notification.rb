module Tendrl
  class Notification

    class << self

      def all
        Tendrl.etcd.get('/_tendrl/notifications', recursive:
                        true).children.map do |children|
          Tendrl.recurse(children)
        end
      rescue Etcd::KeyNotFound, Etcd::NotDir
        []
      end

    end
  end
end
