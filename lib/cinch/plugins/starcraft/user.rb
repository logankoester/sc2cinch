module Cinch
  module Plugins
    module Starcraft

      class User
        include MongoMapper::Document
        key :nick, String
        key :username, String
        key :region, String
        key :bnetid, String
        key :url, String
        key :feed, String

        def get_character
          begin
            sc2ranks = SC2Ranks::API.new('logankoester.com')
            sc2ranks.get_team_info(self.username, self.bnetid)
          rescue SC2Ranks::API::NoCharacterError => e
            m.reply "Character not found: #{e}"
          rescue Exception => e
            m.reply "Failed to fetch SC2Ranks data: #{e}"
          end
        end

        def update_from_url(url)
          split = url.split(/.*sc2ranks.com\/(.+)\/(.+)\/(.+)/)
          self.url = url
          self.region = split[1]
          self.bnetid = split[2]
          self.username = split[3]

          doc = Nokogiri::HTML(open(url))
          self.feed = doc.xpath("//link/@href")[3].value
        end
        
        def queue_refresh!
          url = "http://sc2ranks.com/char/refresh/#{self.region}/#{self.bnetid}/#{self.username}"
          doc = Nokogiri::HTML(open(url))
          resp = doc.css("html body div.charprofile div.w960 div.profile div.updated-container div.lastupdated div.refresh span.green").first.content
          if ( resp.is_a?(String) and resp.size < 140 ) 
            resp
          else
            "Unexpected response, try clicking #{url}"
          end
        end
      end

    end
  end
end
