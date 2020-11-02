require 'spec_helper'

describe Puppet::Type.type(:st2_pack).provider(:default) do
  let(:name) { 'rspec st2_pack test' }
  let(:attributes) { {} }
  let(:resource) do
    Puppet::Type.type(:st2_pack).new(
      {
        name: name,
        provider: :default,
        user: 'st2_user',
        password: 'st2_password',
      }.merge(attributes),
    )
  end
  let(:provider) do
    resource.provider
  end

  before(:each) do
    allow(provider).to receive(:command).with(:st2).and_return('/usr/bin/st2')
  end

  describe 'st2_authenticate' do
    it 'authenticates and receives a token' do
      expect(provider).to receive(:exec_st2).with('auth', 'st2_user',
                                                  '-t',
                                                  '-p', 'st2_password')
                                            .and_return("token\n")
      expect(provider.st2_authenticate).to eq('token')
    end

    it 'caches its token after the first call' do
      expect(provider).to receive(:exec_st2).with('auth', 'st2_user',
                                                  '-t',
                                                  '-p', 'st2_password')
                                            .and_return("cachedtoken\n")
                                            .once
      expect(provider.st2_authenticate).to eq('cachedtoken')
      expect(provider.st2_authenticate).to eq('cachedtoken')
      expect(provider.st2_authenticate).to eq('cachedtoken')
    end
  end

  describe 'create' do
    it 'creates a pack' do
      expect(provider).to receive(:exec_st2).with('auth', 'st2_user',
                                                  '-t',
                                                  '-p', 'st2_password')
                                            .and_return('token')
      expect(provider).to receive(:exec_st2).with('pack', 'install',
                                                  '-t', 'token',
                                                  'rspec st2_pack test')
      provider.create
    end
  end

  describe 'destroy' do
    it 'removes a pack' do
      expect(provider).to receive(:exec_st2).with('auth', 'st2_user',
                                                  '-t',
                                                  '-p', 'st2_password')
                                            .and_return('token')
      expect(provider).to receive(:exec_st2).with('pack', 'remove',
                                                  '-t', 'token',
                                                  'rspec st2_pack test')
      provider.destroy
    end
  end

  describe 'exists?' do
    it 'checks if pack exists' do
      expect(provider).to receive(:list_installed_packs).and_return([])
      expect(provider.exists?).to be false
    end

    it 'returns true when pack exists' do
      expect(provider).to receive(:list_installed_packs).and_return(['pack1', 'rspec st2_pack test'])
      expect(provider.exists?).to be true
    end
  end

  describe 'list_installed_packs' do
    it 'returns a list of pack names' do
      expect(provider).to receive(:exec_st2).with('auth', 'st2_user',
                                                  '-t',
                                                  '-p', 'st2_password')
                                            .and_return('token')
      expect(provider).to receive(:exec_st2).with('pack', 'list',
                                                  '-a', 'ref',
                                                  '-j',
                                                  '-t', 'token')
                                            .and_return('[{"ref": "pack1"}, {"ref": "pack2"}]')
      expect(provider.list_installed_packs).to eq ['pack1', 'pack2']
    end
  end

  describe 'parse_output_json' do
    it 'returns empty list when given nil' do
      expect(provider.parse_output_json(nil)).to eq []
    end

    it 'returns empty list when given empty string' do
      expect(provider.parse_output_json('')).to eq []
    end

    it 'extracts pack names from a JSON string' do
      expect(provider.parse_output_json('[{"ref": "core"}, {"ref": "examples"}]')).to eq ['core', 'examples']
    end
  end

  describe 'exec_st2' do
    it 'executes a command' do
      expect(Puppet::Util::Execution).to receive(:execute)
        .with('/usr/bin/st2 auth someuser -t -p blah',
              override_locale: false,
              failonfail: true,
              combine: true,
              custom_environment: {
                'LANG' => 'en_US.UTF-8',
                'LC_ALL' => 'en_US.UTF-8',
              })
      provider.send(:exec_st2, 'auth', 'someuser', '-t', '-p', 'blah')
    end

    it 'escapes arguments' do
      expect(Puppet::Util::Execution).to receive(:execute)
        .with('/usr/bin/st2 pack search arg\ with\ spaces \"\ blah\" \)\( \#',
              override_locale: false,
              failonfail: true,
              combine: true,
              custom_environment: {
                'LANG' => 'en_US.UTF-8',
                'LC_ALL' => 'en_US.UTF-8',
              })
      provider.send(:exec_st2,
                    'pack', 'search',
                    'arg with spaces',
                    '" blah"',
                    ')(',
                    '#')
    end
  end
end
