class Gd2Client
  include HTTParty

  def self.from_endpoint(endpoint)
    new(gd2_url: endpoint['gd2_url'], secret: endpoint['secret'])
  end

  def initialize(gd2_url: 'http://localhost:24007', user: 'glustercli', secret: nil)
    @gd2_url = gd2_url
    @secret = secret || File.read(File.join('var', 'lib', 'glusterd2', 'auth'))
    @claim = {
      iss: user,
      iat: DateTime.now.utc,
      exp: DateTime.now.utc + 10.seconds,
      qsh: ''
    }
  end

  def jwt_token
    JWT.encode(@claim, @secret, 'HS256')
  end

  def respond_to_missing?(method, include_private = false)
    %i[get put post delete].include?(method) || super
  end

  def method_missing(m, *args, &block)
    return http_call(m, *args) if %i[get put post delete].include? m
    super
  end

  def http_call(method, path, opts = {})
    @claim[:qsh] = Digest::SHA256.hexdigest(method.to_s.upcase + '&' + path)
    response = HTTParty.public_send(
      method,
      @gd2_url + path,
      opts.merge(headers: { 'Authorization' => 'Bearer ' + jwt_token })
    )
    return JSON.parse(response.body) if response.success?
    raise Tendrl::HttpResponseErrorHandler.new(StandardError.new, cause: 'gd2_api_error', object_id: method.to_s.capitalize + path.to_s)
  end

  def peers
    get('/v1/peers')
  end

  def state
    get('/statedump')
  end

  def volumes
    get('/v1/volumes')
  end

  def volume(vol_name)
    get("/v1/volumes/#{vol_name}")
  end

  def bricks(vol_name)
    get("/v1/volumes/#{vol_name}/bricks")
  end

  def ping?
    HTTParty.get(@gd2_url + "/ping").success?
  end

  def endpoints
    get('/endpoints')
  end
end
