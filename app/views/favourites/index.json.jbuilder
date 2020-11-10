json.mode @mode

if @profiles.any?
  json.profiles @profiles do |profile|
    user = profile.user
    json.gender profile.gender
    json.firstname user.firstname
  end
end
