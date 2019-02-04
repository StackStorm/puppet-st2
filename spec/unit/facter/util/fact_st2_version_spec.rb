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
        allow(Facter::Core::Execution).to receive(:execute)
        expect(Facter::Core::Execution).to receive(:which).with('st2')
                                                          .and_return(true)
        expect(Facter::Core::Execution).to receive(:execute).with('st2 --version 2>&1')
                                                            .and_return(st2_version_output)
        expect(Facter.fact(:st2_version).value).to eq('2.9.1')
      end
    end

    context 'when st2 isnt installed' do
      it do
        expect(Facter::Core::Execution).to receive(:which).with('st2').and_return(false)
        expect(Facter.fact(:st2_version).value).to eq(nil)
      end
    end
  end
end
