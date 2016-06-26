require 'spec_helper'

describe Mongoid::Followit::Follower do
  subject(:user) { FactoryGirl.create(:user) }
  let(:admin) { FactoryGirl.create(:group, :admin) }
  let(:sales) { FactoryGirl.create(:group, :sales)}
  let(:role) { FactoryGirl.create(:role)}

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

    it 'is following?' do
      expect(user).to respond_to(:following?)
    end

    it 'can check if follows a model' do
      expect(user).to respond_to(:follows?)
    end

    it 'can unfollow anything' do
      expect(user).to respond_to(:unfollow)
    end

    it 'can unfollow all followees' do
      expect(user).to respond_to(:unfollow_all)
    end

    it 'can have followees' do
      expect(user).to respond_to(:followees)
    end

    it 'can count followees' do
      expect(user).to respond_to(:followees_count)
    end

    it 'can retrive common follwees' do
      expect(user).to respond_to(:common_followees)
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
      context 'when passing one object' do
        it 'follows the object' do
          expect(Follow).to receive(:find_or_create_by!).with({
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
          expect(Follow).to receive(:find_or_create_by!).twice
          user.follow(admin, sales)
        end
      end
    end
  end

  describe '#follow?' do
    context 'when following no model' do
      it 'is not following any model' do
        expect(user).not_to be_following
      end
    end

    context 'when following model' do
      before { user.follow(admin) }

      it 'is following a model' do
        expect(user).to be_following
      end
    end
  end

  describe '#follows?' do
    context 'when not following model' do
      it { expect(user.follows?(admin)).to be false }
    end

    context 'when following model' do
      before { user.follow(admin) }

      it { expect(user.follows?(admin)).to be true }
    end
  end

  describe '#unfollow' do
    context 'when passing a non followee object' do
      context 'when passing one object' do
        it 'warns that cannot be followed' do
          expect{
            user.unfollow(double)
          }.to raise_error('Object(s) must include a Mongoid::Followit::Followee')
        end
      end

      context 'when passing more than one object' do
        it 'warns that cannot be followed' do
          expect{
            user.unfollow(double, double)
          }.to raise_error('Object(s) must include a Mongoid::Followit::Followee')
        end
      end
    end

    context 'when passing followable objects' do
      context 'when passing one object' do
        it 'unfollows the object' do
          expect(Follow).to receive_message_chain(:find_by, :destroy)
          user.unfollow(admin)
        end
      end

      context 'when passing more than one object' do
        it 'unfollows the objects' do
          call_count = 0
          allow(Follow).to receive_message_chain(:find_by, :destroy) do
            call_count += 1
          end
          user.unfollow(admin, sales)
          expect(call_count).to eq 2
        end
      end
    end
  end

  describe '#unfollow_all' do
    context 'when there are no followees' do
      it 'does not unfollow any models' do
        expect(user.followees.count).to be 0
        user.unfollow_all
        expect(user.followees.count).to be 0
      end
    end

    context 'when there are followees' do
      before do
        user.follow(admin, sales)
      end

      it 'unfollows all followee models' do
        expect(user.followees.count).to be 2
        user.unfollow_all
        expect(user.followees.count).to be 0
      end
    end
  end

  describe '#destroy' do
    before do
      Follow.create!({
        followee_class: '',
        followee_id: '',
        follower_class: user.class.to_s,
        follower_id: user.id
      })

      Follow.create!({
        followee_class: user.class.to_s,
        followee_id: user.id,
        follower_class: '',
        follower_id: ''
      })
    end

    it 'destroys its related follow data' do
      user.destroy
      expect(Follow.all).to be_empty
    end
  end

  describe 'callbacks' do
    it { expect(user.class).to include ActiveSupport::Callbacks }

    it { expect(user.class).to respond_to(:before_follow) }
    it { expect(user.class).to respond_to(:after_follow) }

    it { expect(user.class).to respond_to(:before_unfollow) }
    it { expect(user.class).to respond_to(:after_unfollow) }
  end

  describe '#followees' do
    context 'when criteria false' do
      context 'when there is no followees' do
        it 'returns an empty array' do
          expect(user.followees).to be_empty
        end
      end

      context 'when there are followees of one type' do
        before do
          user.follow(admin, sales)
        end

        it 'returns an array of its followees' do
          expect(user.followees).to eq [admin, sales]
        end
      end

      context 'when there are followees of different types' do
        let(:role) { FactoryGirl.create(:role) }

        before do
          user.follow(admin, sales, role)
        end

        it 'returns an array of its followees' do
          expect(user.followees).to eq [admin, sales, role]
        end
      end
    end

    context 'when criteria true' do
      context 'when there is no followees' do
        it 'returns none' do
          expect(user.followees(criteria: true)).to eq Follow.none
        end
      end

      context 'when there are followees of one type' do
        before do
          user.follow(admin, sales)
        end

        it 'returns a criteria of its followees' do
          expect(user.followees(criteria: true).to_a).to eq [admin, sales]
        end
      end

      context 'when there are followees of different types' do
        let(:role) { FactoryGirl.create(:role) }

        before do
          user.follow(admin, sales, role)
        end

        it 'warns that follows two different types' do
          expect {
            user.followees(criteria: true)
          }.to raise_error 'HasTwoFolloweeTypesError'
        end
      end
    end
  end

  describe '#followees_count' do
    context 'when there is no followees' do
      it 'total is zero' do
        expect(user.followees_count).to be 0
      end
    end

    context 'when there are followees' do
      before do
        user.follow(admin)
      end

      it 'total is more than zero' do
        expect(user.followees_count).to be > 0
      end
    end
  end

  describe '#common_followees' do
    let(:second_user) { FactoryGirl.create(:user) }
    let(:third_user)  { FactoryGirl.create(:user) }
    let(:fourth_user) { FactoryGirl.create(:user) }

    context 'when there is no common followees' do
      before do
        user.follow(admin)
        second_user.follow(role)
      end

      it { expect(user.common_followees(second_user)).to be_empty }
    end

    context 'when there are common followees of one type' do
      before do
        user.follow(admin, sales)
        second_user.follow(admin, sales, role)
      end

      it { expect(user.common_followees(second_user)).to eq [admin, sales] }
    end

    context 'when there are followees of different types' do
      before do
        user.follow(admin, role)
        second_user.follow(admin, role, sales)
      end

      it { expect(user.common_followees(second_user)).to eq [admin, role] }
    end
  end
end
