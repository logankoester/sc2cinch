%w{rubygems cinch sc2ranks nokogiri open-uri
   action_view mongo_mapper feedzirra}.each { |d| require d }

require "#{File.dirname(__FILE__)}/cinch/plugins/starcraft"

include ActionView::Helpers::DateHelper

begin
  MongoMapper.connection = Mongo::Connection.new($config['mongodb']['host'], $config['mongodb']['port'])
  MongoMapper.database = $config['mongodb']['database']
  MongoMapper.database.authenticate($config['mongodb']['username'], $config['mongodb']['password'])
rescue Mongo::AuthenticationError => e
  puts e
  puts "Host: " + $config['mongodb']['host']
  puts "Port: " + $config['mongodb']['port']
  puts "Database: " + $config['mongodb']['database']
  puts "Username: " + $config['mongodb']['username']
  puts "Password: " + $config['mongodb']['password']
  exit
rescue Exception => e
  "Failed to connect to database: #{e}"
end

$bot = Cinch::Bot.new do
  configure do |c|
    c.server = $config['server']
    c.nick = $config['nick']
    c.channels = $config['channels']
    c.plugins.plugins = [Cinch::Plugins::Starcraft::Ranks, Cinch::Plugins::Starcraft::Feeds]
  end
end

$bot.start
