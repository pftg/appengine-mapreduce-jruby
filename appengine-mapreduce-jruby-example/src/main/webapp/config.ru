require "rubygems"
require "bundler"
Bundler.setup(:default, :development)


require 'app'

#configure :development do
class ::Sinatra::Reloader < ::Rack::Reloader
  def safe_load(file, mtime, stderr)
    if File.expand_path(file) == File.expand_path(::Sinatra::Application.app_file)
      ::Sinatra::Application.reset!
      stderr.puts "#{self.class}: reseting routes"
    end
    ::Sinatra::Application.reset!

    super
  end
end


use Rack::Reloader
#end



run Sinatra::Application
