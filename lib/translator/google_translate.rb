class GoogleTranslate

  def self.translate(source, target, text, options = {})
    google = GoogleFish.new(GOOGLE_TRANSLATE_API_KEY)
    google.translate(source, target, text, options).gsub(/@ ([A-Za-z0-9_]+)/, '@\1')
  end

  def self.languages(target = nil, options = {})
    google = GoogleFish.new(GOOGLE_TRANSLATE_API_KEY)
    google.get_supported_languages(target)
  end

end
