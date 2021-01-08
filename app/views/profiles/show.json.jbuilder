json.id @profile.id
json.displayName @profile.text_display_name
json.main_photo photo_url(@profile.main_photo)
json.thumb_photo photo_url(@profile.main_photo, is_thumbnail: true)
json.age @profile.age
json.town @profile.town&.town
json.county @profile.county&.county
json.gender @profile.gender
json.gender_subject gender_subject(@profile)
json.muddy_ratio @profile.muddy_ratio
json.relationship_status @profile.marital_status&.marital_status
json.is_hidden !@profile.visible_and_approved?
json.body_type @profile.body_type&.body_type
json.here_for here_for(@profile)
json.height height(@profile)
