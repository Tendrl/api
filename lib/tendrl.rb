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
      sds_version =
        content['object_details']['tendrl_context']['attrs']['sds_type']['value']
      $config[sds_version] = content
    end
    $config
  end

end
