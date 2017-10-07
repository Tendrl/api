config = Tendrl.load_config(ENV['RACK_ENV']).symbolize_keys
etcd_config = { host: config[:host], port: config[:port] }

if [config[:ca_cert_file], config[:client_cert_file], config[:client_key_file]]
  .all?{|c| c.present? }
  etcd_config.merge!(load_cert_config(config))
end
Tendrl.etcd = Etcd.client(etcd_config)

def load_cert_config(config)
  {
    ssl:      true,
    ca_file:  config[:ca_cert_file],
    ssl_cert: load_client_cert(config[:client_cert_file]),
    ssl_key:  load_client_key(config[:client_key_file], config[:passphrase])
  }
end

def load_client_cert(path)
  OpenSSL::X509::Certificate.new(File.read(path))
end

def load_client_key(path, passphrase)
  OpenSSL::PKey::RSA.new(File.read(path), passphrase)
end
