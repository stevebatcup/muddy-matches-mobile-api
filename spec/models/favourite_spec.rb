require 'rails_helper'

RSpec.describe Favourite, type: :model do
  before :all do
    @user1 = create(:user, email: 'user1@bar.com', password: 'a_password', firstname: 'Steve')
    create(:profile, user: @user1)
    @user2 = create(:user, email: 'user2@bar.com', password: 'a_password', firstname: 'James')
    create(:profile, user: @user2)
  end

  it 'cannot be duplicated' do
    fave = Favourite.create({ profile_id: @user1.profile.id, favourite_profile_id: @user2.profile.id })
    fave.valid?
    expect(fave.errors).to be_empty

    fave = Favourite.create({ profile_id: @user1.profile.id, favourite_profile_id: @user2.profile.id })
    fave.valid?
    expect(fave.errors).to_not be_empty
  end

  it 'deletes for the favouriter (updates favouriter_status)' do
    fave = Favourite.create({ profile_id: @user1.profile.id, favourite_profile_id: @user2.profile.id })

    fave.delete_for_favouriter

    expect(fave.favouriter_status).to eq 'deleted'
    expect(fave.favourited_status).to eq 'active'
  end

  it 'deletes for the favourited (updates favourited_status)' do
    fave = Favourite.create({ profile_id: @user1.profile.id, favourite_profile_id: @user2.profile.id })

    fave.delete_for_favourited

    expect(fave.favourited_status).to eq 'deleted'
    expect(fave.favouriter_status).to eq 'active'
  end
end
