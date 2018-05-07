require 'aws-sdk-core'
require 'yle/aws/role/config'

module Yle
  module AWS
    class Role
      class TokenDuration
        # Default duration in seconds when assuming a role
        DEFAULT_DURATION = 900

        # AWS gives lower bound for max age as 1 hour
        SHORTEST_MAXIMUM_ALLOWED = 3600

        def validated_duration(role_name, role_arn, session_name, duration)
          return DEFAULT_DURATION if duration.nil?
          return duration if duration.between? DEFAULT_DURATION, SHORTEST_MAXIMUM_ALLOWED

          assumed_role = Aws::AssumeRoleCredentials.new(
            role_arn: role_arn,
            role_session_name: session_name
          ).credentials

          max_duration = max_duration_for_role(assumed_role, role_name)

          cap_duration_at_max_allowed(max_duration, duration)
        end


        #private
        def self.default_duration
          Role.config['defaults']['duration'] || DEFAULT_DURATION
        end

        def max_duration_for_role(assumed_role, role_name)
          Aws::IAM::Client.new(credentials: assumed_role)
                          .get_role(role_name: role_name)
                          .role.max_session_duration
        end

        def cap_duration_at_max_allowed(max_duration, duration)
          if duration > max_duration
            STDERR.puts "Longest allowed duration is #{max_duration} seconds, "\
                        'using that as duration.'
            STDERR.puts 'If you require longer tokens for the role, '\
                        'contact your AWS administrators.'
            max_duration
          else
            duration
          end
        end
      end
    end
  end
end
