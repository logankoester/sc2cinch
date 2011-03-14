module Cinch
  module Plugins
    module Starcraft
      autoload :Ranks, File.expand_path('../starcraft/ranks', __FILE__)
      autoload :Feeds, File.expand_path('../starcraft/feeds', __FILE__)
      autoload :User, File.expand_path('../starcraft/user', __FILE__)
    end
  end
end
