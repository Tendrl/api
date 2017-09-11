module BrickPresenter

  class << self
    
    def list(raw_bricks)
      bricks = []
      raw_bricks.each do |brick|
        brick.each do |brick_id, attributes|
          attributes['brick_id'] = brick_id
          attributes['utilization'] = JSON.parse(attributes['utilization'])
          attributes['devices'] = JSON.parse(attributes['devices']) rescue []
          attributes['pv'] = JSON.parse(attributes['pv']) rescue []
          bricks << attributes
        end
      end
      bricks
    end

  end
end
