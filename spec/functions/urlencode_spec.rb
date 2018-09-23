# coding: utf-8

require 'spec_helper'

describe 'st2::urlencode' do
  context 'when checking parameter validity' do
    it { is_expected.not_to eq(nil) }

    it 'when passing no arguments' do
      is_expected.to run.with_params.and_raise_error(ArgumentError, %r{expects 1 argument, got none})
    end

    it 'when more than one argument' do
      is_expected.to run.with_params('one', 'two').and_raise_error(ArgumentError, %r{expects 1 argument, got 2})
    end

    it 'when passing an array (non-string)' do
      is_expected.to run.with_params([]).and_raise_error(ArgumentError)
    end

    it 'when passing a hash (non-string)' do
      is_expected.to run.with_params({}).and_raise_error(ArgumentError)
    end

    it 'when passing an integer (non-string)' do
      is_expected.to run.with_params(1).and_raise_error(ArgumentError)
    end
  end

  context 'when urlencoding' do
    sample_text    = 'abc@/:+xyz'
    desired_output = 'abc%40%2F%3A%2Bxyz'

    it 'outputs URL encoded text' do
      is_expected.to run.with_params(sample_text).and_return(desired_output)
    end
  end
end
