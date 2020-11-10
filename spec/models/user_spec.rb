require 'rails_helper'

RSpec.describe User, type: :model do
  before :all do
    @user = create(:user, email: 'steve@bar.com', password: 'password')
  end

  it 'authenticates a correct password' do
    actual = @user.authenticate('password')

    expect(actual).to be_truthy
  end

  it 'does not authenticate an incorrect password' do
    actual = @user.authenticate('bad_password')

    expect(actual).to be_falsey
  end

  context 'unapproved profiles' do
    xit 'does not return unapproved profiles as favourites' do
    end

    xit 'does not return unapproved profiles as fans' do
    end
  end

  context 'approved profiles' do
    xit 'returns approved profiles as favourites' do
    end

    xit 'returns approved profiles as fans' do
    end
  end

  it 'returns mutual fave/fans by limit and page' do
    current_user = create(:user, email: 'nillo@bar.com', password: 'password')
    create(:profile, user: current_user)
    second_user = create(:user, email: 'jools@bar.com', password: 'password')
    second_profile = create(:profile, user: second_user)
    third_user = create(:user, email: 'jack@bar.com', password: 'password')
    third_profile = create(:profile, user: third_user)

    current_user.add_favourite(second_user)
    current_user.add_favourite(third_user)
    second_user.add_favourite(current_user)

    mutuals = current_user.reload.mutuals
    expect(mutuals).to include second_profile
    expect(mutuals).to_not include third_profile
  end
end
