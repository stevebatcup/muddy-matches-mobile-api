require 'rails_helper'

RSpec.describe Profile, type: :model do
  before :all do
    @current_user = create(:user, email: 'nillo@bar.com', password: 'password')
    @current_profile = create(:approved_profile, user: @current_user)
  end

  it 'adds a favourite' do
    second_user = create(:user, email: 'django@bar.com', password: 'password')
    second_profile = create(:approved_profile, user: second_user)

    @current_user.add_favourite(second_user)

    expect(Favourite.all.size).to eq 1

    expect(@current_user.reload.favourites.first).to eq second_profile
    expect(second_user.reload.fans.first).to eq @current_profile
  end

  it 'only finds active users with approved profiles' do
    inactive_user = create(:user, email: 'bad@bar.com', password: 'password', status: :deleted)
    create(:approved_profile, user: inactive_user)

    unapproved_user = create(:user, email: 'nasty@bar.com', password: 'password')
    create(:profile, user: unapproved_user)

    profiles = Profile.approved

    expect(profiles).to include @current_profile
    expect(profiles).to_not include inactive_user.profile
    expect(profiles).to_not include unapproved_user.profile
  end

  it 'blocks another profile' do
    user_to_block = create(:user, email: 'blocked@bar.com', password: 'password')
    create(:profile, user: user_to_block)

    @current_user.profile.block(user_to_block.profile)

    expect(@current_user.reload.profile.blocked_profiles).to include user_to_block.profile
  end

  it 'gets blocked by another profile' do
    user_blocking = create(:user, email: 'blocking@bar.com', password: 'password')
    create(:profile, user: user_blocking)

    user_blocking.profile.block(@current_user.profile)

    expect(@current_user.reload.profile.blocking_profiles).to include user_blocking.profile
  end

  context 'finding unblocked profiles' do
    before :all do
      @second_user = create(:user, email: 'django@bar.com', password: 'password')
      create(:profile, user: @second_user)

      @user_to_block = create(:user, email: 'blocked@bar.com', password: 'password')
      create(:profile, user: @user_to_block)
      @current_user.profile.block(@user_to_block.profile)

      @user_blocking = create(:user, email: 'blocking@bar.com', password: 'password')
      create(:profile, user: @user_blocking)
      @user_blocking.profile.block(@current_user.profile)
    end

    it 'finds profiles that are not blocked by current profile' do
      unblocked_profiles = Profile.unblocked(@current_profile)

      expect(unblocked_profiles).to include @second_user.profile
      expect(unblocked_profiles).to include @user_blocking.profile
      expect(unblocked_profiles).to_not include @user_to_block.profile
    end

    it 'finds profiles that are not blocking the current profile' do
      unblocking_profiles = Profile.unblocking(@current_profile)

      expect(unblocking_profiles).to include @second_user.profile
      expect(unblocking_profiles).to include @user_to_block.profile
      expect(unblocking_profiles).to_not include @user_blocking.profile
    end

    it 'finds profiles that are not blocked by another profile' do
      unblocked_profiles = Profile.mutually_unblocked(@current_profile)

      expect(unblocked_profiles).to include @second_user.profile
      expect(unblocked_profiles).to_not include @user_to_block.profile
      expect(unblocked_profiles).to_not include @user_blocking.profile
    end

    it 'grabs the approved display name from the text fields' do
      user = create(:user, email: 'test@bar.com', password: 'password')
      profile = create(:profile, user: user)

      create(:profile_text, type: 'display_name', content: 'MaryB', profile: profile)

      expect(profile.text_display_name).to eq 'MaryB'
    end

    it 'does not grab a disapproved display name from the text fields' do
      user = build_stubbed(:user, email: 'test2@bar.com', password: 'password')
      profile = build_stubbed(:profile, user: user)

      create(:profile_text, type: 'display_name', content: 'Jammer', profile: profile, status: :rejected)

      expect(profile.text_display_name).to be_nil

      create(:profile_text, type: 'display_name', content: 'Billy', profile: profile, status: :approved)

      expect(profile.text_display_name).to eq 'Billy'
    end
  end

  it 'sets the default display name text' do
    user = build_stubbed(:user, email: 'ian@foo.com', password: 'password', firstname: 'ian', lastname: 'foo')
    user.profile.set_default_display_name

    expect(user.profile.text_display_name).to eq 'ian foo'
  end

  it 'sets the missing default profile data' do
    profile = create(:profile)

    expect(profile.dating).to eq 'yes'
    expect(profile.profile_status).to eq 'new'
    expect(profile.publish_status).to eq 'new'
  end

  context 'validation' do
    it 'must have a gender' do
      profile = build_stubbed(:profile, gender: nil)
      profile.valid?

      expect(profile.errors).to_not be_empty
      expect(profile.errors['gender']).to include 'can\'t be blank'
    end

    it 'must have a seeking gender' do
      profile = build_stubbed(:profile, dating_looking_for: nil)
      profile.valid?

      expect(profile.errors).to_not be_empty
      expect(profile.errors['dating_looking_for']).to include 'can\'t be blank'
    end
  end
end
