require 'spec_helper'
require 'yle/aws/role/config'

describe Yle::AWS::Role::Config do
  describe '.default_path' do
    subject { described_class.default_path }

    context 'when ASU_CONFIG is set' do
      before(:each) { ENV['ASU_CONFIG'] = path }
      let(:path) { '/foo/asu.yaml' }
      it { is_expected.to eq(path) }
    end

    context 'when ASU_CONFIG is not set' do
      before(:each) do
        ENV.delete('ASU_CONFIG')
        ENV['HOME'] = '/bar'
      end
      it { is_expected.to eq('/bar/.aws/asu.yaml') }
    end
  end

  describe '.load' do
    before do
      # Disable loading of local config
      ENV['ASU_CONFIG'] = ''
    end
    subject(:config) { described_class.load(config_file) }

    context 'without config file specified' do
      let(:config_file) { nil }
      it { is_expected.to eq(described_class.default_config) }
    end

    context 'when the config file exists' do
      let(:config_file) { 'spec/fixtures/config/asu.yaml' }
      it { is_expected.to eq(described_class.default_config.merge('defaults' => { 'role' => 'dev' })) }
    end

    context 'when the config file does not exist' do
      before do
        # silence the output
        allow($stderr).to receive(:write)
      end
      let(:config_file) { '/nonexisting/file' }
      it { is_expected.to eq(described_class.default_config) }
    end
  end
end
