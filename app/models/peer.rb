module Tendrl
  class Peer
    def peers
      get("/v1/peers")
    end
  end
end
