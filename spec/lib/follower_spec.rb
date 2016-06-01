require 'spec_helper'

describe Mongoid::Followit::Follower do
  subject(:user) { FactoryGirl.build(:user) }

  it 'must be a mongoid document' do
    expect(user).to be_a(Mongoid::Document)
  end

  it 'must be a follower' do
    expect(user).to be_a(Mongoid::Followit::Follower)
  end

  describe 'api' do
    it 'can follow anything' do
      expect(user).to respond_to(:follow)
    end

    it 'can unfollow anything' do
      expect(user).to respond_to(:unfollow)
    end

    it 'can have followees' do
      expect(user).to respond_to(:followees)
    end
  end
end
