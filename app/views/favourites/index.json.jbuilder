json.mode @mode

json.profiles @profiles do |profile|
  json.profile_id profile.id
  json.gender profile.gender
  json.displayName profile.text_display_name
  json.photo photo_url(profile.main_photo, is_thumbnail: true)
end
