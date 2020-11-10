FactoryBot.define do
  factory :user do
    profile
    firstname { 'Test' }
    lastname { 'McTestersons' }
    status { :active }
    created { 5.months.ago }
    last_active { 2.weeks.ago }

    sequence :email do |n|
      "person#{n}@example.com"
    end

    password { 'password123' }

    # after(:build) do |user|
    #   user.class.skip_callback(:create, :before, :set_default_status, raise: false)
    # end
  end
end
