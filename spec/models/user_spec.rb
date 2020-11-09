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
end
