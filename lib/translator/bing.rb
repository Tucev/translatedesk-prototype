class Bing

  def self.translate(source, target, text, options = {})
    bing = BingTranslator.new(BING_CLIENT_ID, BING_CLIENT_SECRET)
    bing.translate(text, options.merge({ :from => source, :to => target }))
  end

  def self.languages(target = nil, options = {})
    bing = BingTranslator.new(BING_CLIENT_ID, BING_CLIENT_SECRET)
    bing.supported_language_codes
  end

end
