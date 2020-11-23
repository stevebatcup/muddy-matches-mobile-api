require 'rails_helper'

RSpec.describe UserEvent, type: :model do
  it 'logs a registration form error' do
    create(:user_event_type, name: 'registration-form-error')
    errors = { email: 'that email sucks' }
    event = UserEvent.log_registration_form_error(errors)

    expect(event).to_not be_nil
    expect(event.errors).to be_empty
    expect(event.event_type.name).to eq 'registration-form-error'
    expect(event.details.find_by(key: :error_field).value).to eq 'email'
    expect(event.details.find_by(key: :error_message).value).to eq 'that email sucks'
  end
end
