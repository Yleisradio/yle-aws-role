# frozen_string_literal: true

module Yle
  module AWS
    class Role
      AccountAlias = Struct.new(:name, :id)

      class Accounts
        attr_reader :aliases

        def initialize(aliases = nil)
          @aliases = aliases || {}
        end

        # Returns an `AccountAlias` that best matches the passed string
        def find(id_or_alias)
          id_or_alias = id_or_alias.to_s
          if account_id?(id_or_alias)
            name = aliases.key(id_or_alias) || id_or_alias
            AccountAlias.new(name, id_or_alias)
          else
            name = best_matching_account(id_or_alias)
            AccountAlias.new(name, aliases[name]) if name
          end
        end

        def to_s
          max_name_length = aliases.keys.map(&:length).max
          aliases.sort.map do |name, id|
            "#{name.ljust(max_name_length)}\t#{id}"
          end.join("\n")
        end

        # Returns truish if the argument looks like an AWS Account ID
        def account_id?(id_or_alias)
          id_or_alias =~ /^\d{12}$/
        end

        def best_matching_account(id_or_alias)
          matcher = alias_matcher(id_or_alias)
          aliases.keys.select { |key| matcher =~ key }.min_by(&:length)
        end

        def alias_matcher(id_or_alias)
          pattern = id_or_alias.gsub(/([^^])(?=[^$])/, '\1.*')
          Regexp.new(pattern)
        end
      end
    end
  end
end
