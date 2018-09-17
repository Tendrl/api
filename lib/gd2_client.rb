class Gd2Client
  include HTTParty

  UNVERSIONED_APIS = %w[/version /ping /statedump /endpoints]

  def initialize(endpoint)
    endpoint = endpoint.with_indifferent_access
    @gd2_url = endpoint[:gd2_url]
    @user = endpoint[:user].present? ? endpoint[:user] : 'glustercli'
    @secret = endpoint[:secret] || File.read(File.join('var', 'lib', 'glusterd2', 'auth'))
    generate_api_methods
  end

  def claim(method, path)
    {
      iss: @user,
      iat: DateTime.now.utc,
      exp: DateTime.now.utc + 10.seconds,
      qsh: Digest::SHA256.hexdigest(method.to_s.upcase + '&' + path)
    }
  end

  def jwt_token(method, path)
    JWT.encode(claim(method, path), @secret, 'HS256')
  end

  def respond_to_missing?(method, include_private = false)
    %i[get put post delete].include?(method) || super
  end

  def method_missing(m, *args, &block)
    return http_call(m, *args) if %i[get put post delete].include? m
    super
  end

  def http_call(method, path, opts = {})
    req_data = { headers: { 'Authorization' => 'Bearer ' + jwt_token(method, path) } }
    req_data[:body] = args[-1].to_h if %w[put post patch].include?(method) && args[-1].respond_to(:to_h)
    HTTParty.public_send(
      method,
      @gd2_url + path,
      opts.merge(req_data)
    )
  end

  def prefixed_path(path)
    UNVERSIONED_APIS.include?(path) ? path : '/v1' + path
  end

  def generate_api_methods
    apis.each do |api|
      method_name = api['name'].split.join('_').underscore
      action = api['methods'].downcase
      self.class.send(:define_method, method_name) do |*args|
        path = api['path'].gsub(/{.*?}/).with_index { |_, i| args[i] }
        path = prefixed_path(path)
        response = http_call(action, path, args[-1].present? && args[-1].respond_to?(:to_h) ? args[-1] : {})
        return response if response.success?
        raise Tendrl::HttpResponseErrorHandler.new(response.body, cause: 'gd2_api_error', object_id: api['methods'] + path.to_s)
      end
    end
    self
  end

  def ping?
    HTTParty.get(@gd2_url + '/ping').success?
  end

  def apis
    get('/endpoints').to_a
  end
end
