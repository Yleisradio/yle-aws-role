require 'slop'

require 'yle/aws/role'

module Yle
  module AWS
    class Role
      class Cli
        attr_reader :account_name, :opts

        def initialize(argv)
          parse_args(argv)
        end

        # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        def parse_args(argv)
          @opts = Slop.parse(argv) do |o|
            o.banner = 'Usage: asu <account> [options] -- [command ...]'
            o.separator '   or: asu --list'
            o.separator ''
            o.separator '    account         The account ID or pattern of the role account'
            o.separator '    command         Command to execute with the role. ' \
                                            'Defaults to launching new shell session.'
            o.separator ''
            o.integer '-d', '--duration', 'Duration for the role credentials. ' \
                                          "Default: #{Role.default_duration}"
            o.bool '--env', 'Print out environment variables and exit'
            o.bool '-l', '--list', 'Print out all configured account aliases'
            o.bool '-q', '--quiet', 'Be quiet'
            o.string '-r', '--role', "Name of the role. Default: '#{Role.default_role_name}'"
            o.separator ''
            o.on '-h', '--help', 'Prints this help' do
              puts o
              exit
            end
            o.on '-v', '--version', 'Prints the version information' do
              puts VERSION
              exit
            end
          end

          @account_name = opts.args.shift
          @command = opts.args

          if !@opts[:list]
            if !@account_name
              STDERR.puts @opts
              exit 64
            elsif !(@opts[:role] || Role.default_role_name)
              STDERR.puts 'Role name must be passed with `--role` or set in the config'
              exit 64
            end
          end
        rescue Slop::Error => e
          STDERR.puts e
          exit 64
        end
        # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

        # rubocop:disable Metrics/AbcSize
        def execute
          return list_accounts if opts[:list]

          assume_role(account_name, opts[:role], opts[:duration]) do |role|
            STDERR.puts("Assumed role #{role.name}") if !opts[:quiet]

            if opts[:env]
              role.print_env_vars
            else
              run_command
            end
          end
        end
        # rubocop:enable Metrics/AbcSize

        def list_accounts
          puts Role.accounts
        end

        def assume_role(account_name, role_name, duration, &block)
          Role.assume_role(account_name, role_name, duration, &block)
        rescue Errors::AssumeRoleError => e
          STDERR.puts e
          exit 1
        end

        def run_command
          ret = system(*command)
          STDERR.puts "Failed to execute '#{command.first}'" if ret.nil?
          exit(1) if !ret
        end

        def command
          @command = shell if @command.empty?
          @command
        end

        def shell
          shell = default_shell

          if !opts[:quiet]
            puts "Executing shell '#{shell}' with the assumed role"
            puts 'Use `exit` to quit'
            puts
          end

          [shell]
        end

        def default_shell
          ENV.fetch('SHELL', 'bash')
        end
      end
    end
  end
end
