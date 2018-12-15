# coding: utf-8

require 'spec_helper'

describe 'st2::version_ge' do
  context 'when StackStorm is not installed' do
    let(:facts) do
      {
        st2_version: nil,
      }
    end

    it 'comparing with any version returns true' do
      is_expected.to run.with_params('2.10.0').and_return(true)
    end
  end

  context 'when StackStorm is installed' do
    context 'and st2::version = "present"' do
      let(:facts) do
        {
          st2_version: '2.9.0',
          'st2::version' => 'present',
        }
      end

      it 'comparing with higher version returns false' do
        is_expected.to run.with_params('2.10.0').and_return(false)
      end

      it 'comparing with lower version returns true' do
        is_expected.to run.with_params('2.8.0').and_return(true)
      end
    end

    context 'and st2::version = "installed"' do
      let(:facts) do
        {
          st2_version: '2.9.0',
          'st2::version' => 'installed',
        }
      end

      it 'comparing with higher version (2.10.0) returns false' do
        is_expected.to run.with_params('2.10.0').and_return(false)
      end

      it 'comparing with lower version (2.8.0) returns true' do
        is_expected.to run.with_params('2.8.0').and_return(true)
      end
    end

    context 'and st2::version = "latest"' do
      let(:facts) do
        {
          st2_version: '2.9.0',
          'st2::version' => 'latest',
        }
      end

      it 'comparing with higher version (2.10.0) returns true' do
        is_expected.to run.with_params('2.10.0').and_return(true)
      end

      it 'comparing with lower version (2.8.0) returns true' do
        is_expected.to run.with_params('2.8.0').and_return(true)
      end
    end

    context 'and st2_version = "2.9.0" st2::version = "2.9.0"' do
      let(:facts) do
        {
          st2_version: '2.9.0',
          'st2::version' => '2.9.0',
        }
      end

      it 'comparing with higher version (2.10.0) returns false' do
        is_expected.to run.with_params('2.10.0').and_return(false)
      end

      it 'comparing with lower version (2.8.0) returns true' do
        is_expected.to run.with_params('2.8.0').and_return(true)
      end
    end

    context 'and st2_version = "2.9.0" st2::version = "2.10.0"' do
      let(:facts) do
        {
          st2_version: '2.9.0',
          'st2::version' => '2.10.0',
        }
      end

      it 'comparing with higher version (2.11.0) returns false' do
        is_expected.to run.with_params('2.11.0').and_return(false)
      end

      it 'comparing with lower version (2.8.0) returns true' do
        is_expected.to run.with_params('2.8.0').and_return(true)
      end
    end

    context 'and st2_version = "2.10.0" st2::version = "2.9.0"' do
      let(:facts) do
        {
          st2_version: '2.10.0',
          'st2::version' => '2.9.0',
        }
      end

      it 'comparing with higher version (2.11.0) returns false' do
        is_expected.to run.with_params('2.11.0').and_return(false)
      end

      it 'comparing with lower version (2.8.0) returns true' do
        is_expected.to run.with_params('2.8.0').and_return(true)
      end
    end
  end
end
