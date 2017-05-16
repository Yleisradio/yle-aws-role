# yle-aws-role

Tooling to help to assume [AWS IAM roles](http://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles.html).

Offers a command-line helper tool, `asu`, and a Ruby library. After assuming the specified role, it sets the standard environment variables and configures the Ruby SDK for the role.

## Installation

The project can be installed in a shell:

```sh
gem install yle-aws-role
```

To use the Ruby library, add this line to your application's Gemfile:

```ruby
gem 'yle-aws-role'
```

and then execute `bundle`

## Usage

```plain
Usage: asu <account> [options] -- [command ...]
   or: asu --list

    account         The account ID or pattern of the role account
    command         Command to execute with the role. Defaults to launching new shell session.

    -d, --duration  Duration for the role credentials. Default: 900
    --env           Print out environment variables and exit
    -l, --list      Print out all configured account aliases
    -q, --quiet     Be quiet
    -r, --role      Name of the role

    -h, --help      Prints this help
    -v, --version   Prints the version information
```

### Configuration

Account aliases and their IDs can be specified in a configuration file. Then you can list the known accounts with `asu --list`, and use aliases (even with partial matching) when specifying the account for `asu`. Also the default role can be set.

The configuration file location defaults to _$HOME/.aws/asu.yaml_, but can be specified with the `ASU_CONFIG` environment variable.

Example configuration:

```yaml
defaults:
  role: "dev"

accounts:
  foo-bar: "123456789012"
  baz:     "987654321098"
```

With this you can just call for example

```sh
asu foo -- aws s3 ls s3://mybucket/
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Yleisradio/yle-aws-role. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
