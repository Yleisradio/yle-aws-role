require 'aws-sdk-iam'
require 'yle/aws/role/config'

module Yle
  module AWS
    class Role
      # Default duration in seconds when assuming a role
      DEFAULT_DURATION = 900

      #private

      def self.default_token_duration
        config['defaults']['duration'] || DEFAULT_DURATION
      end

      def get_validated_duration(account, role_name, duration)
        assumed_role = Aws::AssumeRoleCredentials.new(
          role_arn: role_arn,
          role_session_name: session_name
        ).credentials
        
        max_duration = get_max_duration_for_role(assumed_role, role_name)

        cap_duration_at_max_allowed(max_duration, duration)
      end

      def get_max_duration_for_role(assumed_role, role_name)
        Aws::IAM::Client.new({credentials: assumed_role})
          .get_role({role_name: role_name})
          .role.max_session_duration
      end

      def cap_duration_at_max_allowed(max_duration, duration)
        if duration > max_duration
          puts "Longest allowed duration is #{max_duration} seconds, using that as duration."
          puts "If you require longer tokens for the role, contact your AWS administrators."
          max_duration
        else
          duration
        end
      end
    end
  end
end