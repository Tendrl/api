require 'active_support/core_ext/hash/deep_merge'
require './lib/tendrl/version'
require './lib/tendrl/component'

#Errors
require './lib/tendrl/errors/tendrl_error'
require './lib/tendrl/errors/invalid_object_error'

module Tendrl

  def self.sds_config(sds_dir_path='config/sds')
    return $config if $config
    $config = {}
    Dir.glob("#{sds_dir_path}/*.yaml").each do |file|
      content = YAML.load_file(file)
      if $config[content['sds_version']]
        $config[content['sds_version']].deep_merge!(content)
      else
        $config[content['sds_version']] = content
      end
    end
    $config
  end

end
