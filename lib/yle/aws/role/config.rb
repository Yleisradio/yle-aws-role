require 'yaml'

module Yle
  module AWS
    class Role
      Config = Struct.new(:accounts, :defaults) do
        def self.default_path
          ENV.fetch('ASU_CONFIG') { File.join(Dir.home, '.aws', 'asu.yaml') }
        end

        def self.default_config
          @default_config ||= Config.new({}, {})
        end

        def self.default_config=(config)
          @default_config = default_config.merge(config)
        end

        def self.load(paths = nil)
          paths = Array(paths).push(default_path)
          paths.inject(default_config) do |config, path|
            config.merge(load_yaml(path))
          end
        end

        def self.load_yaml(path)
          (path && File.exist?(path) && YAML.load_file(path)) || {}
        rescue StandardError
          STDERR.puts("WARN: Failed to load or parse configuration from '#{path}'")
          {}
        end

        def merge(config)
          config ||= {}
          Config.new(
            accounts.merge(config['accounts'] || {}),
            defaults.merge(config['defaults'] || {})
          )
        end
      end
    end
  end
end
