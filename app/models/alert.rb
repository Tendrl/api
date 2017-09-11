module Tendrl
  class Alert

    class << self

      def all(path='alerts')
        alerts = []
        Tendrl.etcd.get("/alerting/#{path}", recursive: true).children.each do |children|
          alert = {}
          children.children.each do |child|
            key = child.key.split('/')[-1]
            if child.dir
              alert[key] = {}
              child.children.each do |cchild|
                alert[key][cchild.key.split('/')[-1]] = cchild.value
              end
            else
              alert[key] = child.value
            end
          end
          alert['tags'] = JSON.parse(alert['tags']) || []
          alerts << alert
        end
        alerts.sort do |a, b|
          Time.parse(a['time_stamp']) <=> Time.parse(b['time_stamp'])
        end
      end

      def find(alert_id)
        alert = {}
        Tendrl.etcd.get("/alerting/alerts/#{alert_id}", recursive: true).children.each do |children|
          key = children.key.split('/')[-1]
          if children.dir
            alert[key] = {}
            children.children.each do |child|
              alert[key][child.key.split('/')[-1]] = child.value
            end          
          else
            alert[key] = children.value
          end
        end
        alert
      end

    end

  end
end
