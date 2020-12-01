require 'rails_helper'

RSpec.describe 'Search', type: :request do
  include SpecHelpers

  context 'when not signed in' do
    it 'does not run a search' do
      post search_path, params: basic_search_params, headers: json_headers

      expect(response).to have_http_status(403)
      expect(json_response['error']).to eq 'You must be signed in'
    end
  end

  context 'when signed in' do
    before :all do
      @current_user = create(:subscribing_user, email: 'searchyman@foo.com', password: 'a_password', firstname: 'Steve')
      create(:approved_profile, user: @current_user, gender: 'male', dating_looking_for: 'female')

      create_profiles
    end

    before(:each) { sign_in(@current_user.email, 'a_password') }
    after(:each) { sign_out }

    it 'runs a basic search and returns results' do
      post search_path, params: basic_search_params, headers: json_headers

      expect(response).to have_http_status(200)
      expect(json_response['profiles']).to_not be_empty
      expect(display_names).to include 'Becky Smith'
    end

    it 'limits results to an age range' do
      young_user = create(:user, firstname: 'Young', lastname: 'Smith')
      create(:approved_profile, user: young_user, gender: 'female', dating_looking_for: 'male', birth_date: 18.years.ago)
      old_user = create(:user, firstname: 'Old', lastname: 'Smith')
      create(:approved_profile, user: old_user, gender: 'female', dating_looking_for: 'male', birth_date: 65.years.ago)

      post search_path, params: basic_search_params, headers: json_headers

      expect(json_response['profiles']).to_not be_empty
      expect(display_names).to include 'Samantha Smith'
      expect(display_names).to_not include 'Young Smith'
      expect(display_names).to_not include 'Old Smith'
    end

    it 'does not include non-published profile in the results' do
      unpublished_user = create(:user, firstname: 'Unpub', lastname: 'Smith')
      profile = create(:profile, user: unpublished_user, gender: 'female', dating_looking_for: 'male', birth_date: 30.years.ago)
      create(:main_approved_photo, profile: profile, user: unpublished_user)

      post search_path, params: basic_search_params, headers: json_headers

      expect(json_response['profiles']).to_not be_empty
      expect(display_names).to include 'Samantha Smith'
      expect(display_names).to_not include 'Unpub Smith'
    end

    it 'does not include inactive users in the results' do
      inactive_user = create(:user, firstname: 'Inactive', lastname: 'Smith', status: 'deleted')
      profile = create(:approved_profile, user: inactive_user, gender: 'female', dating_looking_for: 'male', birth_date: 30.years.ago)
      create(:main_approved_photo, profile: profile, user: inactive_user)

      post search_path, params: basic_search_params, headers: json_headers

      expect(json_response['profiles']).to_not be_empty
      expect(display_names).to include 'Daluda Smith'
      expect(display_names).to_not include 'Inactive Smith'
    end

    it 'does not include users who are not flagged for "dating" in the results' do
      non_dating_user = create(:user, firstname: 'Undate', lastname: 'Smith')
      profile = create(:approved_profile, user: non_dating_user, gender: 'female', dating_looking_for: 'male', birth_date: 30.years.ago, dating: 'no')
      create(:main_approved_photo, profile: profile, user: non_dating_user)

      post search_path, params: basic_search_params, headers: json_headers

      expect(json_response['profiles']).to_not be_empty
      expect(display_names).to include 'Magenta Smith'
      expect(display_names).to_not include 'Undate Smith'
    end

    it 'does not include results that have already been approved' do
      create_full_profile
      @current_user.approve_connect(@full_profile)

      post search_path, params: basic_search_params, headers: json_headers

      expect(display_names).to_not include 'Carol Carolsons'
    end

    it 'does not include results that have already been rejected' do
      create_full_profile
      @current_user.reject_connect(@full_profile)

      post search_path, params: basic_search_params, headers: json_headers

      expect(display_names).to_not include 'Carol Carolsons'
    end

    it 'does not include results that have already been favourited' do
      create_full_profile
      @current_user.add_favourite(@full_user)

      post search_path, params: basic_search_params, headers: json_headers

      expect(display_names).to include 'Magenta Smith'
      expect(display_names).to_not include 'Carol Carolsons'
    end

    it 'includes all necessary profile data' do
      create_full_profile
      post search_path, params: basic_search_params, headers: json_headers

      profile = json_response['profiles'].first

      expect(profile['id']).to be_an(Numeric)
      expect(profile['display_name']).to eq 'Carol Carolsons'
      expect(profile['main_photo']).to include '/mobile/an-awesome-photo.jpg'
      expect(profile['thumb_photo']).to_not be_empty
      expect(profile['age']).to eq 30
      expect(profile['town']).to eq 'Luton'
      expect(profile['county']).to eq 'Bedfordshire'
      expect(profile['gender']).to eq 'female'
      expect(profile['gender_subject']).to eq 'her'
      expect(profile['muddy_ratio']).to eq 40
      expect(profile['relationship_status']).to eq 'Single'
      expect(profile['is_hidden']).to eq false
      expect(profile['body_type']).to eq 'Curvy'
      expect(profile['here_for']).to eq 'Men'
      expect(profile['height']).to eq '5\'2" - 157.48cm'
    end

    context 'paginates the results' do
      it 'lists the results for page 1' do
        post search_path, params: basic_search_params.merge({ page: 1, per_page: 2 }), headers: json_headers

        expect(json_response['profiles']).to_not be_empty
        expect(display_names).to include 'Samantha Smith'
        expect(display_names).to_not include 'Daluda Smith'
      end

      it 'lists the results for page 2' do
        post search_path, params: basic_search_params.merge({ page: 2, per_page: 2 }), headers: json_headers

        expect(json_response['profiles']).to_not be_empty
        expect(display_names).to include 'Daluda Smith'
        expect(display_names).to_not include 'Samantha Smith'
      end
    end
  end

  def basic_search_params
    { search: { age_min: 25, age_max: 35 } }
  end

  def create_profiles
    %w[samantha becky daluda betty magenta].each_with_index do |person, index|
      user = create(:user, firstname: person.capitalize, lastname: 'Smith', created: (index + 1).days.ago)
      profile = create(:approved_profile, user: user, gender: 'female', dating_looking_for: 'male', birth_date: 30.years.ago)
      create(:main_approved_photo, profile: profile, user: user)
    end
  end

  def create_full_profile
    @full_user = create(:user, firstname: 'Carol', lastname: 'Carolsons', created: Time.now)
    @full_profile = create(:approved_profile,
                           town:               create(:town, town: 'Luton'),
                           county:             create(:county, county: 'Bedfordshire'),
                           user:               @full_user,
                           gender:             'female',
                           dating_looking_for: 'male',
                           birth_date:         30.years.ago,
                           muddy_ratio:        40,
                           marital_status:     create(:marital_status, marital_status: 'Single'),
                           body_type:          create(:body_type, body_type: 'Curvy'),
                           height_inches:      62)
    create(:main_approved_photo, profile: @full_profile, user: @full_user, file: 'an-awesome-photo.jpg', has_mobile_version: true)
  end

  def display_names
    json_response['profiles'].map { |f| f['display_name'] } if json_response['profiles'].present?
  end
end
