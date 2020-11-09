require 'rails_helper'
require 'support/helpers'

RSpec.describe 'Favourites', type: :request do
  include SpecHelpers

  describe 'GET /favourites' do
    before :all do
      @user = create(:user, email: 'john@bar.com', password: 'a_password', firstname: 'Steve')
    end

    it 'lists the favourites for a signed in user' do
      sign_in(@user.email, 'a_password')
      get favourites_path

      expect(response).to have_http_status(200)
    end
  end
end
