require 'aws-sdk'
require 'shellwords'

require 'yle/aws/role/accounts'
require 'yle/aws/role/config'
require 'yle/aws/role/errors'
require 'yle/aws/role/version'

module Yle
  module AWS
    class Role
      # Default duration in seconds when assuming a role
      DEFAULT_DURATION = 900

      def self.assume_role(account_name, role_name = nil, duration = nil)
        account_alias = accounts.find(account_name)
        if !account_alias
          raise Errors::AccountNotFoundError, "No account found for '#{account_name}'"
        end

        role = Role.new(account_alias, role_name, duration)
        role.with_env { yield role } if block_given?
        role
      end

      def self.config
        @config ||= Config.load
      end

      def self.accounts
        @accounts ||= Accounts.new(config['accounts'])
      end

      def self.default_role_name
        config['defaults']['role']
      end

      def self.default_duration
        config['defaults']['duration'] || DEFAULT_DURATION
      end

      attr_reader :account, :role_name, :credentials

      def initialize(account_alias, role_name = nil, duration = nil)
        @account = account_alias
        @role_name = role_name || Role.default_role_name
        duration ||= Role.default_duration

        raise Errors::AssumeRoleError, 'Role name not specified' if !@role_name

        @credentials = Aws::AssumeRoleCredentials.new(
          role_arn: role_arn,
          role_session_name: session_name,
          duration_seconds: duration
        ).credentials
      rescue Aws::STS::Errors::ServiceError,
        Aws::Errors::MissingCredentialsError => e
        raise Errors::AssumeRoleError, "Failed to assume role #{role_arn}: #{e}"
      end

      def with_env
        old_env = set_env_vars(env_vars)
        old_credentials = Aws.config[:credentials]
        Aws.config.update(credentials: credentials)

        yield

        if old_credentials
          Aws.config.update(credentials: old_credentials)
        else
          Aws.config.delete(:credentials)
        end
        set_env_vars(old_env)
      end

      def env_vars
        {
          'AWS_ACCESS_KEY_ID'     => credentials.access_key_id,
          'AWS_SECRET_ACCESS_KEY' => credentials.secret_access_key,
          'AWS_SESSION_TOKEN'     => credentials.session_token,
          'ASU_CURRENT_PROFILE'   => name
        }
      end

      def set_env_vars(vars)
        old_env = {}
        vars.each do |key, value|
          old_env[key] = ENV[key]
          ENV[key] = value
        end
        old_env
      end

      def print_env_vars
        env_vars.each do |key, value|
          puts "export #{key}=#{Shellwords.escape(value)}"
        end
      end

      def name
        "#{account.name}:#{role_name}"
      end

      def role_arn
        "arn:aws:iam::#{account.id}:role/#{role_name}"
      end

      def session_name
        "#{current_user}-#{Time.now.to_i}"
      end

      def current_user
        ENV['USER'] || ENV['USERNAME'] || 'unknown'
      end
    end
  end
end
