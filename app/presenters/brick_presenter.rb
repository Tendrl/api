module BrickPresenter
  class << self
    def list(bricks)
      bricks.map do |attributes|
        %w[devices partitions pv].each do |key|
          attributes[key] = JSON.parse(attributes[key] || '[]') rescue {}
        end
        attributes
      end
    end
  end
end
