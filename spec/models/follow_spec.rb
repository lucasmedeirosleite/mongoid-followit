require 'spec_helper'

describe Follow do
  it 'must be a mongoid document' do
    is_expected.to be_a Mongoid::Document
  end

  describe 'fields' do

    it { is_expected.to respond_to(:followee_class) }
    it { is_expected.to respond_to(:followee_id) }
    it { is_expected.to respond_to(:follower_class) }
    it { is_expected.to respond_to(:follower_class) }

  end
end
