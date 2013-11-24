class GoogleTranslate

  def self.translate(source, target, text, options = {})
    EasyTranslate.translate(text, options.merge({ :from => source, :to => target, :key => GOOGLE_TRANSLATE_API_KEY }))
  end

  def self.languages(target = nil, options = {})
    EasyTranslate.translations_available(target, :key => GOOGLE_TRANSLATE_API_KEY)
  end

  def self.detect(text)
    text = [text] unless text.is_a?(Array)
    begin
      EasyTranslate.detect(text, :key => GOOGLE_TRANSLATE_API_KEY)
    rescue
      text.collect{ |t| t = '' }
    end
  end

end
