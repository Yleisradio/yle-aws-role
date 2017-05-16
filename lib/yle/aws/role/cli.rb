require 'slop'

require 'yle/aws/role'

module Yle
  module AWS
    class Role
      class Cli
        attr_reader :account_name, :command, :opts

        def initialize(argv)
          parse_args(argv)
        end

        def parse_args(argv)
          @opts = Slop.parse(argv) do |o|
            o.banner = 'Usage: asu <account> [options] -- [command ...]'
            o.separator '   or: asu --list'
            o.separator ''
            o.separator '    account         The account ID or pattern of the role account'
            o.separator '    command         Command to execute with the role. Defaults to launching new shell session.'
            o.separator ''
            o.integer '-d', '--duration', "Duration for the role credentials. Default: #{Role::DEFAULT_DURATION}"
            o.bool '--env', 'Print out environment variables and exit'
            o.bool '-l', '--list', 'Print out all configured account aliases'
            o.bool '-q', '--quiet', 'Be quiet'
            o.string '-r', '--role', 'Name of the role'
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

          if !@account_name && !@opts[:list]
            STDERR.puts @opts
            exit 64
          end
        rescue Slop::Error => e
          STDERR.puts e
          exit 64
        end

        def execute
          if opts[:list]
            puts Role.accounts
            return
          end

          if !role_name
            STDERR.puts 'Role name must be passed with `--role` or set in the config'
            exit 64
          end

          Role.assume_role(account_name, role_name, duration) do |role|
            STDERR.puts("Assumed role #{role.name}") if !opts[:quiet]

            if opts[:env]
              role.print_env_vars
            else
              run_command
            end
          end
        rescue Errors::AssumeRoleError => e
          STDERR.puts e
          exit 1
        end

        def run_command
          cmd = command
          if cmd.empty?
            shell = ENV.fetch('SHELL', 'bash')
            cmd = [shell]

            if !opts[:quiet]
              puts "Executing shell '#{shell}' with the assumed role"
              puts "Use `exit` to quit"
              puts
            end
          end

          ret = system(*cmd)
          STDERR.puts "Failed to execute '#{cmd.first}'" if ret.nil?
          exit(1) if !ret
        end

        def role_name
          opts[:role] || Role.config['defaults']['role']
        end

        def duration
          opts[:duration] || Role.config['defaults']['duration']
        end
      end
    end
  end
end
