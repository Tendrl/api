module VolumePresenter
  class << self
    def list(volumes)
      vols = []
      volumes.each do |volume|
        volume.each do |vol_id, attributes|
          attributes['vol_id'] = vol_id
          attributes['bricks'] = attributes['bricks'].values

          vols << attributes
        end
      end
      vols
    end
  end
end
