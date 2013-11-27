# encoding: utf-8
class Dictionary < ActiveRecord::Base

  # Special rules for parsing "dict" output data
  DICTS = Hash.new({ :rule => /^   \s*(.+)/ }).merge({
    'en-ar' => { :dict => 'fd-eng-ara',
                 :rule => /^\s+([؆-ۿ]+)/u
               },
    'ar-en' => { :dict => 'fd-ara-eng',
                 :rule => /^  ([^\s]+)/
               },
    'en-zh' => { :dict => 'stardic',
                 :rule => /  [a-z]+\. ([^;]+);/
               }
  })

  def self.words_meanings(words, from, to, dict = 'dict')
    return {} if words.blank?

    words = words.uniq.reject{ |w| w.blank? || w.match(/^[0-9]+$/) }.map(&:downcase)
    meanings = {}

    case dict
    when 'dict'
      if %x[which dict]
        # Open3 is the only safe way to do what we need
        require 'open3'
        dict = DICTS.keys.include?(from + '-' + to) ? DICTS[from + '-' + to][:dict] : 'fd-' + ISO_639.find(from).alpha3 + '-' + ISO_639.find(to).alpha3
        stdin, stdout, stderr, wait_thr = Open3.popen3('dict', '-d', dict, *words)

        # First, filter words that were not found
        while !(output = stderr.gets).nil?
          if word = output.match(/^No definitions found for "(.+)"$/)
            words.delete(word[1])
          end
        end

        # Now get the words that were found
        word = nil
        while !(output = stdout.gets).nil?
          # Word found
          if output.match(/^[0-9]+ definitions? found/)
            word = words.shift
            meanings[word] = []
          # Meaning
          elsif meaning = output.match(DICTS[from + '-' + to][:rule])
            meanings[word] += meaning[1].chomp.strip.split(/[;,]\s*/).reject{ |w| w.blank? }
          end
        end
      end
    end

    return meanings.reject{ |w, m| w.blank? || m.blank? }
  end

end
