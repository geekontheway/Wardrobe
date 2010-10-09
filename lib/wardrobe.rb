Bundler.require(:app)
Bundler.require(:daemon)
require 'sinatra/wardrobe_helpers'
require 'authorization'
require 'openid'
require 'rack-flash'


EventMachine.run do
  class Wardrobe < Sinatra::Base
    include Mongo
    include Sinatra::WardrobeHelpers
    include Sinatra::Authorization
    use Rack::Flash
    enable :sessions

    db = Connection.new("127.0.0.1","27017").db('wardrobe')
    file_info = db.collection('fs.files')

    set :views, File.join(File.dirname(__FILE__),'views')

    get '/' do
      @files = file_info.find().sort([:uploadDate, -1]).limit(20)
      haml :index
    end

    get '/file/:id' do
      @file = Grid.new(db).get(BSON::ObjectID.from_string(params[:id]))
      db.collection('file_stats').update({:file_id => @file.files_id, :hour => current_hour},
                                          {'$inc'=> {:views => 1}},
                                          {:upsert => true})
      haml :show
    end


     get '/new' do
       protected!
       haml :new
     end

    post '/create' do
       Grid.new(db).put(params[:file][:tempfile], :filename => params[:file][:filename],
                    :content_type => params[:file][:type],
                    :metadata => {:uploaded_by => session[:user],
                                  :description => params[:description],
                                  :category => params[:category],
                                   :tags =>parse_tags(params[:tags])})

       redirect '/'
    end

     get '/search' do
       keyword = params[:keyword]
       selector = {'metadata.tags' => Regexp.new('^'+keyword)}
       @files =  file_info.find(selector)
       db.collection('file_stats').update({:keyword => keyword, :hour => current_hour},
                                          {'$inc'=> {:count => 1}},
                                          {:upsert => true})
       haml :index
     end

    get '/download/:id' do
      protected!
      file = Grid.new(db).get(BSON::ObjectID.from_string(params[:id]))
      db.collection('file_stats').update({:file_id => file.files_id, :hour => current_hour},
                                          {'$inc'=> {:downloads => 1}},
                                          {:upsert => true})
      [200, {'Content-Type' => file.content_type, 'Content-Disposition' => 'attachment'}, [file.read]]
    end

    get '/stats' do
      haml :stats
    end

    get '/login' do
      haml :login
    end

    get '/logout' do
      logout!
      redirect '/'
    end

    get '/register' do
      haml :register
    end

    post '/register' do
      nickname = params[:nickname]
      if db.collection('users').find_one({:nickname => nickname}).nil?
         db.collection('users').insert({:openid => session[:openid], :nickname => nickname})
         session[:user] = nickname
         redirect '/'
      else
        flash[:notice] = "Sorry, that nickname is already registered."
        haml :register
      end
    end

    post '/login/openid' do
       openid = params[:openid_identifier]
      begin
        oidreq = openid_consumer.begin(openid)
      rescue OpenID::DiscoveryFailure => why
        "Sorry, we couldn't find your identifier '#{openid}'"
      else
        oidreq.add_extension_arg('sreg','required','nickname')
        redirect oidreq.redirect_url(root_url, root_url + "/login/openid/complete")
      end  
    end

    get '/login/openid/complete' do
      oidresp = openid_consumer.complete(params, request.url)
      case oidresp.status
        when OpenID::Consumer::FAILURE
          "Sorry, we could not authenticate you with the identifier '{openid}'."

        when OpenID::Consumer::SETUP_NEEDED
          "Immediate request failed - Setup Needed"

        when OpenID::Consumer::CANCEL
          "Login cancelled."

        when OpenID::Consumer::SUCCESS
         session[:openid] = oidresp.display_identifier
         user = db.collection('users').find_one({:openid => oidresp.display_identifier})
         if user.nil?
           redirect '/register'
         else
          session[:user] = user['nickname']
          puts request.inspect
          redirect '/'
         end
      end
    end    
  end

  EventMachine::WebSocket.start(:host => '0.0.0.0', :port => 8080) do |ws| 
     
      ws.onopen {
         # ws.send "connected!!!!"
      }

      ws.onmessage { |msg|
          puts "got message #{msg}"
      }

      ws.onclose   {
          ws.send "WebSocket closed"
      }

    puts 'code'

  end

 Wardrobe.run!({:port => 3000}) 
end
