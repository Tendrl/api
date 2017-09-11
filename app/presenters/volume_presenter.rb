module VolumePresenter
  class << self
    def list(raw_volumes)
      volumes = []
      raw_volumes.each do |volume|
        volume.each do |vol_id, attributes|
          attributes['vol_id'] = vol_id
          attributes.delete('bricks')
          attributes.delete('options')
          volumes << attributes
        end
      end
      volumes
    end
  end
end
