# frozen_string_literal: true

require 'spec_helper'
require 'yle/aws/role/accounts'

describe Yle::AWS::Role::Accounts do
  subject(:accounts) { described_class.new(aliases) }

  def account_alias(name, id)
    Yle::AWS::Role::AccountAlias.new(name, id)
  end

  describe '#find' do
    subject(:account_id) { accounts.find(id_or_alias) }

    context 'without aliases' do
      let(:aliases) { nil }

      context 'with an account id' do
        let(:id_or_alias) { '112233445566' }
        it { is_expected.to eq account_alias('112233445566', '112233445566') }
      end

      context 'with a numeric account id' do
        let(:id_or_alias) { 112_233_445_566 }
        it { is_expected.to eq account_alias('112233445566', '112233445566') }
      end

      context 'with a (non-existing) alias' do
        let(:id_or_alias) { 'foo' }
        it { is_expected.to be nil }
      end
    end

    context 'without aliases' do
      let(:aliases) do
        {
          'foo'       => '123456789012',
          'foo-bar'   => '234567890123',
          'baz'       => '987654321098',
          'barbapapa' => '876543210987'
        }
      end

      context 'with an account id' do
        let(:id_or_alias) { '112233445566' }
        it { is_expected.to eq account_alias('112233445566', '112233445566') }
      end

      context 'with a non-matching alias' do
        let(:id_or_alias) { 'hello-world' }
        it { is_expected.to be nil }
      end

      context 'with an exact matching alias' do
        let(:id_or_alias) { 'baz' }
        it { is_expected.to eq account_alias('baz', '987654321098') }
      end

      context 'with a partial match' do
        let(:id_or_alias) { 'ar' }
        it { is_expected.to eq account_alias('foo-bar', '234567890123') }
      end

      context 'with multiple matches' do
        let(:id_or_alias) { 'oo' }
        it 'returns the shortest match' do
          is_expected.to eq account_alias('foo', '123456789012')
        end
      end

      context 'with a non-continuous match' do
        let(:id_or_alias) { 'oa' }
        it { is_expected.to eq account_alias('foo-bar', '234567890123') }
      end

      context 'with anchored pattern' do
        let(:id_or_alias) { '^bar' }
        it { is_expected.to eq account_alias('barbapapa', '876543210987') }
      end
    end
  end
end
