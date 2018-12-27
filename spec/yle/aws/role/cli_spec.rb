# frozen_string_literal: true

require 'spec_helper'
require 'yle/aws/role/cli'

describe Yle::AWS::Role::Cli do
  subject(:cli) { described_class.new(argv) }

  let(:argv) { %w[112233445566 --role foo --quiet].concat(command) }
  let(:command) { [] }

  describe '#command' do
    subject { cli.command }

    context 'when not given in command line' do
      context 'when SHELL is defined' do
        before { ENV['SHELL'] = '/usr/bin/myshell' }
        it { is_expected.to eq(['/usr/bin/myshell']) }
      end

      context 'when SHELL is not defined' do
        before { ENV.delete('SHELL') }
        it { is_expected.to eq(['bash']) }
      end
    end

    context 'when given in command line' do
      let(:command) { %w[-- some_cmd arg1] }
      it { is_expected.to eq(%w[some_cmd arg1]) }
    end
  end
end
