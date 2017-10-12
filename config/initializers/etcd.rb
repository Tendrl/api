config = Tendrl.load_config(ENV['RACK_ENV']).symbolize_keys
etcd_config = { host: config[:host], port: config[:port] }

if [config[:ca_cert_file], config[:client_cert_file], config[:client_key_file]]
  .all?{|c| c.present? }
  etcd_config.merge!(Tendrl.load_cert_config(config))
end

Tendrl.etcd = Etcd.client(etcd_config)

