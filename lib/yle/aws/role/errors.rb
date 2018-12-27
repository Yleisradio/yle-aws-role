# frozen_string_literal: true

module Yle
  module AWS
    class Role
      module Errors
        class AssumeRoleError < StandardError; end

        class AccountNotFoundError < AssumeRoleError; end
      end
    end
  end
end
