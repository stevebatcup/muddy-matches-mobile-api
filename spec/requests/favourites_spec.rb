require 'rails_helper'
require 'support/helpers'

RSpec.describe 'Favourites', type: :request do
  include SpecHelpers

  before :all do
    @current_user = create(:user, email: 'john@bar.com', password: 'a_password', firstname: 'Steve')
    @current_profile = create(:profile, user: @current_user)
  end

  describe 'GET /favourites' do
    it 'lists the favourites for a signed in user' do
      build_favourites
      sign_in(@current_user.email, 'a_password')
      get favourites_path, headers: json_headers

      expect(response).to have_http_status(200)
      expect(firstnames).to include 'sam'
      expect(firstnames).to_not include 'bob'
    end
  end

  describe 'GET /fans' do
    it 'lists the fans for a signed in user' do
      build_favourites
      sign_in(@current_user.email, 'a_password')
      get fans_path, headers: json_headers

      expect(response).to have_http_status(200)
      expect(firstnames).to include 'albert'
      expect(firstnames).to_not include 'dave'
    end
  end

  describe 'GET /mutuals' do
    it 'lists the profiles who are both favourites AND fans for a signed in user as mutuals' do
      build_mutuals
      sign_in(@current_user.email, 'a_password')
      get mutuals_path(page: 1, per_page: 10), headers: json_headers

      expect(response).to have_http_status(200)
      expect(firstnames).to include 'greta'
      expect(firstnames).to include 'helga'
      expect(firstnames).to_not include 'liz'
      expect(firstnames).to_not include 'paula'
    end

    describe 'paginate the mutual listings' do
      context 'page 1' do
        it 'lists the mutuals for page 1' do
          build_mutuals
          sign_in(@current_user.email, 'a_password')

          get mutuals_path(page: 1, per_page: 1), headers: json_headers

          expect(firstnames).to include 'greta'
          expect(firstnames).to_not include 'helga'
        end
      end

      context 'page 2' do
        it 'lists the mutuals for page 2' do
          build_mutuals
          sign_in(@current_user.email, 'a_password')

          get mutuals_path(page: 2, per_page: 1), headers: json_headers

          expect(firstnames).to include 'helga'
          expect(firstnames).to_not include 'greta'
        end
      end
    end
  end

  describe 'POST /favourites' do
    xit 'adds a favourite' do
    end
  end

  describe 'DELETE /favourites' do
    xit 'deletes a favourite for the fave adder' do
    end

    xit 'deletes a favourite for the fave receiver' do
    end
  end

  private

  def firstnames
    json_response['profiles'].map { |f| f['firstname'] } if json_response['profiles'].present?
  end

  def build_favourites
    %w[sam james dave jon ian].each do |fave|
      user = create(:user, firstname: fave)
      profile = create(:profile, user: user)
      @current_profile.favourite_profiles << profile
    end

    %w[bob albert fred].each do |non_fave|
      user = create(:user, firstname: non_fave)
      create(:profile, user: user)
      user.add_favourite(@current_user)
    end
  end

  def build_mutuals
    %w[greta helga ingrid].each do |mutual|
      user = create(:user, firstname: mutual)
      profile = create(:profile, user: user)
      @current_profile.favourite_profiles << profile
      profile.favourite_profiles << @current_profile
    end

    %w[liz elaine betty].each do |non_mutual_fan|
      user = create(:user, firstname: non_mutual_fan)
      create(:profile, user: user)
      user.add_favourite(@current_user)
    end

    %w[corrina paula sheila].each do |non_mutual_fave|
      user = create(:user, firstname: non_mutual_fave)
      create(:profile, user: user)
      @current_user.add_favourite(user)
    end
  end
end
