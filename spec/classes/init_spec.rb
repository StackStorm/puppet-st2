require 'spec_helper'
describe 'stackstorm' do

  context 'with defaults for all parameters' do
    it { should contain_class('stackstorm') }
  end
end
