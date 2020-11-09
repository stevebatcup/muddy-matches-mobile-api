require 'rails_helper'

RSpec.describe User, type: :model do
  before :all do
    @user = create(:user, email: 'foo@bar.com', password: '123abc456xzy')
  end

  it 'authenticates a correct password' do
    actual = @user.authenticate('123abc456xzy')

    expect(actual).to be_truthy
  end

  it 'does not authenticate an incorrect password' do
    actual = @user.authenticate('fjk4j4wh5f')

    expect(actual).to be_falsey
  end
end
