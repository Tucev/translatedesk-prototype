class Dictionary < ActiveRecord::Base

  def self.words_meanings(words, from, to, dict = 'dict')
    return {} if words.blank?

    words = words.uniq.reject{ |w| w.blank? || w.match(/^[0-9]+$/) }
    meanings = {}

    case dict
    # Use `dict`
    when 'dict'
      if %x[which dict]
        # Open3 is the only safe way to do what we need
        require 'open3'
        # FIXME: This works on Ubuntu, maybe this should be customized?
        dict = 'fd-' + ISO_639.find(from).alpha3 + '-' + ISO_639.find(to).alpha3
        stdin, stdout, stderr, wait_thr = Open3.popen3('dict', '-d', dict, *words)
        word = ''

        while !(output = stdout.gets).nil?
          # Word
          if output.match(/^  [^ ]/)
            word = output.chomp.strip
            meanings[word] = []
          # Meaning
          elsif output.match(/^   +/)
            meanings[word] += output.chomp.strip.split(/[;,]\s*/)
          end
        end
      end
    end

    return meanings.reject{ |w, m| w.blank? || m.blank? }
  end

end
