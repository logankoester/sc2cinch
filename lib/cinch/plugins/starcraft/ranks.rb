module Cinch
  module Plugins
    module Starcraft
      class Ranks
        include Cinch::Plugin

        match /set (.+)/, :method => :set
        match /help/, :method => :help
        match /refresh (.+)/, :method => :refresh_nick
        match /refresh$/, :method => :refresh
        match /rank (.+)/, :method => :rank_nick
        match /rank$/, :method => :rank

        listen_to :channel
        prefix /^!sc2/

        def initialize(*args)
          super
          start_rss_thread
        end

        # Usage:
        #   To set your own Starcraft II user
        #     !sc2set http://sc2ranks.com/#{region}/#{bnetid}/#{username}
        #   To set another Starcraft II user
        #     !sc2set <nick> http://sc2ranks.com/#{region}/#{bnetid}/#{username}
        def set(m, args)
          args = args.split(" ")

          # Optional nickname parameter
          if args.size > 1
            nick = args[0].downcase
            url = args[1]
          else
            nick = m.user.nick.downcase
            url = args[0]
          end

          user = User.find_by_nick(nick)
          user = User.create(:nick => nick) unless user
          user.update_from_url(url)
          user.save
          restart_rss_thread
          m.reply "#{user.nick}'s battle.net user set to #{user.username}, Battle.net ID #{user.bnetid}"
        end

        def help(m)
          m.reply "Display current rank for a Starcraft II player"
          m.reply "!sc2rank - Display your current rank"
          m.reply "!sc2rank <nick> - Display <nick>'s current rank"
          m.reply "!sc2set <url> - Set your profile URL"
          m.reply "!sc2set <nick> <url> - Set <nick>'s profile URL"
          m.reply "!sc2refresh - Queue a refresh for yourself"
          m.reply "!sc2refresh <nick> - Queue a refresh for your <nick>"
          m.reply "To get your SC2ranks URL, visit http://sc2ranks.com"
          m.reply "Author: Logan Koester <logan@logankoester.com>"
        end

        # Queue refresh for yourself
        def refresh(m)
          user = User.find_by_nick(m.user.nick.downcase)
          if user
            m.reply "#{user.nick}: #{user.queue_refresh!}"
          else
            m.reply "That nick is not registered, use !sc2set (!sc2help for more info)"
          end
        end
        
        # Queue refresh for <nick>
        def refresh_nick(m, nick)
          user = User.find_by_nick(nick.downcase)
          if user
            m.reply "#{user.nick}: #{user.queue_refresh!}"
          else
            m.reply "That nick is not registered, use !sc2set (!sc2help for more info)"
          end
        end
        
        # Display current rank for yourself
        def rank(m)
          user = User.find_by_nick(m.user.nick.downcase)
          if user
            display_rank(m, user)
          else
            m.reply "Your nick is not registered, use !sc2set (!sc2help for more info)"
          end
        end

        # Display <nick>'s current rank
        def rank_nick(m, nick)
          user = User.find_by_nick(nick.downcase)
          if user
            display_rank(m, user)
          else
            m.reply "That nick is not registered, use !sc2set (!sc2help for more info)"
          end
        end

      private
        def display_rank(m, user)
          begin
            character = user.get_character
            team = character.teams.select { |v| v['bracket'] == 1 }.first
            m.reply "#{character.name} is rank ##{team['division_rank']} in #{team['division']} (#{team['league']}) with #{team['wins']} wins and #{team['losses']} losses (#{team['ratio']} win ratio) (last updated #{time_ago_in_words(team['updated_at'])} ago)"
          rescue Exception => e
            m.reply "Sorry, an error occurred: #{e}"
            m.reply "Try setting your username with !sc2set (!sc2help for more info)"
          end
        end

        def start_rss_thread
          @rss_thread = Thread.new { FeedsReader.new($bot, $config['channels']).start }
        end

        def stop_rss_thread
          @rss_thread.kill if @rss_thread
        end

        def restart_rss_thread
          stop_rss_thread
          start_rss_thread
        end
      end
    end
  end
end
