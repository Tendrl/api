module BrickPresenter
  class << self
    def list(bricks)
      bricks.map do |(brick_id, attributes)|
        attributes['brick_id'] = brick_id
        attributes['devices'] = JSON.parse(attributes['devices'] || '[]')
        attributes['partitions'] = JSON.parse(attributes['partitions'] || '[]')
        attributes['pv'] = JSON.parse(attributes['pv'] || '[]')
        attributes
      end
    end
  end
end
