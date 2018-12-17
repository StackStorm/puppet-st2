require 'spec_helper'

describe Facter::Util::Fact do
  before(:each) do
    Facter.clear
  end

  let(:st2_version_output) do
    <<-EOS
st2 2.9.1, on Python 2.7.5
EOS
  end

  describe 'st2_version' do
    context 'with value' do
      it do
        Facter::Core::Execution.stubs(:execute)
        Facter::Core::Execution.expects(:which).with('st2').returns(true)
        Facter::Core::Execution.expects(:execute).with('st2 --version 2>&1').returns(st2_version_output)
        expect(Facter.fact(:st2_version).value).to eq('2.9.1')
      end
    end

    context 'when st2 isnt installed' do
      it do
        Facter::Core::Execution.expects(:which).with('st2').returns(false)
        expect(Facter.fact(:st2_version).value).to eq(nil)
      end
    end
  end
end
