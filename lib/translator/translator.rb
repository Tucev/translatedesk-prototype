module Translator

  # Same as the class name
  PROVIDERS = ['GoogleTranslate', 'Bing']

  def self.const_missing(c)
    Object.const_get(c)
  end

  # Return available translators and their supported languages
  def self.translators
    Rails.cache.fetch 'machine_translators' do
      translators = []
      PROVIDERS.each do |provider|
        translators << {
          :name => provider,
          :languages => provider.constantize.languages.collect do |code|
            { :name => (entry = ISO_639.find(code)) ? entry.english_name : code, :code => code }
          end
        }
      end
      translators
    end
  end

  def self.translate(translator, source, target, text)
    if PROVIDERS.include?(translator)
      translator.constantize.translate(source, target, text)
    end
  end

end
