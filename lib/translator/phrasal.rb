class Phrasal

  # FIXME: For the time being, Phrasal just supports EN-DE

  def self.translate(source, target, text, options = {})
    require 'net/http'
    require 'json'

    if source.upcase == 'EN' and target.upcase == 'DE'
      
      msg = {
        :src => source.upcase,
        :tgt => target.upcase,
        :n => options[:n] || 3, # FIXME: What is it for?
        :text => text,
        :tgtPrefix => options[:tgtPrefix] || '', # FIXME: What is it for?
      }

      begin
        uri = URI.parse(URI::escape('http://joan.stanford.edu:8017/t?tReq=' + msg.to_json))
        http = Net::HTTP.new(uri.host, uri.port)
        request = Net::HTTP::Get.new(uri.request_uri)
        response = http.request(request)

        response.code.to_i == 200 ? JSON.parse(response.body)['tgtList'].first : text
      rescue
        text
      end
    else
      text
    end
  end

  def self.languages(target = nil, options = {})
    ['en', 'de']
  end

end
