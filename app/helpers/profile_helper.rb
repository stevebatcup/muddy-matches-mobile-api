module ProfileHelper
  def photo_url(photo, is_thumbnail: false)
    return unless photo

    size = if is_thumbnail
             'thumbnail'
           else
             photo.has_mobile_version ? 'mobile' : 'thumbnail'
           end
    if photo.photo_id.nil? || photo.photo_id.zero?
      "https://s3-eu-west-1.amazonaws.com/cdn.muddymatches.co.uk/data/photos/#{size}/#{photo.file}"
    else
      "https://s3-eu-west-1.amazonaws.com/cdn.muddymatches.co.uk/data/photos/#{size}/#{photo.photo_id}.jpg"
    end
  end

  def gender_subject(profile)
    profile.gender == 'male' ? 'him' : 'her'
  end

  def here_for(profile)
    case profile.dating_looking_for
    when 'male'
      'Men'
    when 'female'
      'Women'
    else
      'Men and women'
    end
  end

  def height(profile)
    return if profile.height_inches.nil?

    feet = profile.height_inches / 12
    inches = profile.height_inches % 12
    cm = profile.height_inches * 2.54
    "#{feet}'#{inches}\" - #{cm}cm"
  end
end
