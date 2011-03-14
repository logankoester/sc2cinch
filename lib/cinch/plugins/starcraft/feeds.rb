module Cinch
  module Plugins
    module Starcraft
      class FeedsReader
        def initialize(bot, channels)
          @bot, @channels = bot, channels
          @feeds = Feedzirra::Feed.fetch_and_parse( User.all.map { |u| u.feed } )
        end

        def start
          loop do
            sleep $config['rss']['interval']
            begin
              @feeds = Feedzirra::Feed.update(@feeds.values)
              @feeds.each do |feed|
                feed = feed[1]
                nick = User.find_by_username( feed.title.split(" ").last ).nick
                entries = feed.new_entries[0..($config['rss']['floodlines']-1)]
                entries.each do |entry|
                  msg = "#{nick} just played #{entry.title}"
                  @bot.dispatch(:rss_update, nil, {:channels => @channels, :message => msg })
                end
              end
            rescue Exception => e
              puts e # Probably no feeds to refresh
            end
          end
        end
      end

      class Feeds
        include Cinch::Plugin

        listen_to :rss_update

        def listen(m, event)
          event[:channels].each do |channel|
            Channel(channel).send event[:message]
          end
        end
      end
    end
  end
end
