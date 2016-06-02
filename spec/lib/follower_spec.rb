require 'spec_helper'

describe Mongoid::Followit::Follower do
  subject(:user) { FactoryGirl.create(:user) }

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

  describe '#follow' do
    context 'when passing a non followee object' do
      context 'when passing one object' do
        it 'warns that cannot be followed' do
          expect{
            user.follow(double)
          }.to raise_error('Object(s) must include a Mongoid::Followit::Followee')
        end
      end

      context 'when passing more than one object' do
        it 'warns that cannot be followed' do
          expect{
            user.follow(double, double)
          }.to raise_error('Object(s) must include a Mongoid::Followit::Followee')
        end
      end
    end

    context 'when passing followable objects' do
      let(:admin) { FactoryGirl.create(:group, :admin) }
      let(:sales) { FactoryGirl.create(:group, :sales)}

      context 'when passing one object' do
        it 'follows the object' do
          expect(Follow).to receive(:create!).with({
            followee_class: admin.class.to_s,
            followee_id: admin.id,
            follower_class: user.class.to_s,
            follower_id: user.id
          })
          user.follow(admin)
        end
      end

      context 'when passing more than one object' do
        it 'follows the objects' do
          expect(Follow).to receive(:create!).twice
          user.follow(admin, sales)
        end
      end
    end
  end

  describe 'callbacks' do
    it { expect(user.class).to include ActiveSupport::Callbacks }

    it { expect(user.class).to respond_to(:before_follow) }
    it { expect(user.class).to respond_to(:after_follow) }
  end
end
