class UserEvent < ApplicationRecord
  belongs_to :event_type, foreign_key: :event_type_id, class_name: 'UserEventType'
  has_many :details, class_name: 'UserEventDetail'

  class << self
    def log_registration_form_error(errors)
      event = new({ event_type: UserEventType.find_by(name: 'registration-form-error') })

      errors.each do |error_field, error_message|
        event.details << UserEventDetail.new(key: 'error_field', value: error_field)
        event.details << UserEventDetail.new(key: 'error_message', value: error_message)
      end

      event.save
      event
    end

    def log_registration(profile)
      create({
               user_id:    profile.user.id,
               profile_id: profile.id,
               event_type: UserEventType.find_by(name: 'registration')
             })
    end

    def timestamp_attributes_for_create
      super << 'created'
    end
  end
end
