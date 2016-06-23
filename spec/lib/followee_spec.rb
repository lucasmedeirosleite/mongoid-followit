require 'spec_helper'

describe Mongoid::Followit::Followee do
  subject(:admin) { FactoryGirl.create(:group, :admin) }
  let(:user) { FactoryGirl.create(:user) }
  let(:role) { FactoryGirl.create(:role) }

  it 'must be a mongoid document' do
    expect(admin).to be_a(Mongoid::Document)
  end

  it 'must be a follower' do
    expect(admin).to be_a(Mongoid::Followit::Followee)
  end

  describe 'api' do
    it 'is followed?' do
      expect(admin).to respond_to(:followed?)
    end

    it 'can have followers' do
      expect(admin).to respond_to(:followers)
    end

    it 'can retrieve followers count' do
      expect(admin).to respond_to(:followers_count)
    end
  end

  describe '#followed?' do
    context 'when no other model follows model' do
      it 'is not followed' do
        expect(admin).not_to be_followed
      end
    end

    context 'when other model follows model' do
      before { user.follow(admin) }

      it 'is following a model' do
        expect(admin).to be_followed
      end
    end
  end

  describe '#followers' do
    context 'when criteria false' do

      context 'when there is no followers' do
        it 'returns an empty array' do
          expect(admin.followers).to be_empty
        end
      end

      context 'when there are followers of one type' do
        before do
          user.follow(admin)
        end

        it 'returns an array of its followers' do
          expect(admin.followers).to eq [user]
        end
      end

      context 'when there are followees of different types' do
        let(:role) { FactoryGirl.create(:role) }

        before do
          user.follow(admin)
          role.follow(admin)
        end

        it 'returns an array of its followees' do
          expect(admin.followers).to eq [user, role]
        end
      end

    end

    context 'when criteria true' do

      context 'when there is no followers' do
        it 'returns an empty relation' do
          expect(admin.followers(criteria: true)).to eq(Follow.none)
        end
      end

      context 'when there are followers of one type' do
        before do
          user.follow(admin)
        end

        it 'returns a criteria of its followers' do
          expect(admin.followers(criteria: true).to_a).to eq [user]
        end
      end

      context 'when there are followers of different types' do
        let(:role) { FactoryGirl.create(:role) }

        before do
          user.follow(admin)
          role.follow(admin)
        end

        it 'warns that has followers of two different types' do
          expect {
            admin.followers(criteria: true)
          }.to raise_error 'HasTwoFollowerTypesError'
        end
      end

    end
  end

  describe '#followers_count' do
    context 'when there is no followers' do
      it 'total is zero' do
        expect(admin.followers_count).to be 0
      end
    end

    context 'when there are followers' do
      before do
        user.follow(admin)
      end

      it 'total is more than zero' do
        expect(admin.followers_count).to be > 0
      end
    end
  end
end
