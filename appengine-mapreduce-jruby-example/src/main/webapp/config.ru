require 'app'

configure :development do
  class Sinatra::Reloader < ::Rack::Reloader
    def safe_load(file, mtime, stderr)
      Sinatra::Application.reset!
      super
    end
  end

  use Sinatra::Reloader
end


run Sinatra::Application