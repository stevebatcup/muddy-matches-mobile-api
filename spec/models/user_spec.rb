require 'rails_helper'

RSpec.describe User, type: :model do
  before :all do
    @user = create(:user, email: 'steve@bar.com', password: 'password')
  end

  context 'registration' do
    it 'generates a unique auth token' do
      tokens = []
      10.times do |i|
        user = build_stubbed(:user, email: "autho_#{i}@bar.com", password: 'password')
        tokens << user.set_auth_token
      end

      expect(tokens.uniq.length).to eq 10
    end

    it 'sets the missing default data' do
      user = create(:user, email: 'steve@bar.com', password: 'password', last_active: nil)

      expect(user.last_active).to_not be_nil
    end

    context 'validation' do
      let(:user) { User.new }

      it 'must contain a first name' do
        user.valid?

        expect(user.errors).to_not be_empty
        expect(user.errors['firstname']).to include 'can\'t be blank'
      end

      it 'must contain a last name' do
        user.valid?

        expect(user.errors).to_not be_empty
        expect(user.errors['lastname']).to include 'can\'t be blank'
      end

      it 'must contain a password' do
        user.valid?

        expect(user.errors).to_not be_empty
        expect(user.errors['password']).to include 'can\'t be blank'
      end

      it 'must contain a valid email address' do
        user.valid?

        expect(user.errors).to_not be_empty
        expect(user.errors['email']).to include 'can\'t be blank'
      end

      it 'must be a unique email' do
        user.email = 'foobar'
        user.valid?

        expect(user.errors).to_not be_empty
        expect(user.errors['email']).to include 'is invalid'
      end

      it 'must not be a blacklisted email' do
        create(:email_blacklist_item, email: 'foo@bar.com')
        user.email = 'foo@bar.com'

        user.valid?

        expect(user.errors).to_not be_empty
        expect(user.errors['email']).to include 'Sorry you cannot register at this time'
      end

      it 'must not be an email already flagged as misused' do
        create(:email_wronglist_item, email: 'moo@bar.com')
        user.email = 'moo@bar.com'

        user.valid?

        expect(user.errors).to_not be_empty
        expect(user.errors['email']).to include 'Sorry you cannot register at this time'
      end
    end
  end

  context 'login' do
    it 'authenticates a correct password' do
      actual = @user.authenticate('password')

      expect(actual).to be_truthy
    end

    it 'does not authenticate an incorrect password' do
      actual = @user.authenticate('bad_password')

      expect(actual).to be_falsey
    end
  end

  context 'favourites' do
    it 'returns mutual fave/fans by limit and page' do
      current_user = create(:user, email: 'nillo@bar.com', password: 'password')
      create(:approved_profile, user: current_user)
      second_user = create(:user, email: 'jools@bar.com', password: 'password')
      create(:approved_profile, user: second_user)
      third_user = create(:user, email: 'jack@bar.com', password: 'password')
      create(:approved_profile, user: third_user)

      current_user.add_favourite(second_user)
      current_user.add_favourite(third_user)
      second_user.add_favourite(current_user)

      mutuals = current_user.reload.mutuals
      expect(mutuals).to include second_user.profile
      expect(mutuals).to_not include third_user.profile
    end
  end

  context 'with unread messages' do
    it 'returns a list of unread messages' do
      sender = create(:user, email: 'sender@foo.com', password: 'password')
      message = build(:message, body:                 'An ice breaking message',
                                sender_profile_id:    sender.profile.id,
                                recipient_profile_id: @user.profile.id)
      create(:conversation, profile_id_1: sender.profile.id,
                            profile_id_2: @user.profile.id,
                            messages:     [message])

      expect(@user.unseen_messages.length).to eq 1
      expect(@user.unseen_messages.last.body).to eq 'An ice breaking message'
    end
  end
end
