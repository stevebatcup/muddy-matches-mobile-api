require 'rails_helper'
require 'support/helpers'

RSpec.describe 'Favourites', type: :request do
  include SpecHelpers

  describe 'GET /favourites' do
    xit 'lists the favourites for a signed in user' do
    end

    xit 'denies access to a non signed-in user' do
    end
  end
end
