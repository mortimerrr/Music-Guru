require 'echowrap'
require 'sinatra'
require 'rack-flash'
require 'json'

enable :sessions
set :session_secret, 'super secret'
use Rack::Flash

configure do
  Echowrap.configure do |config|
    config.api_key = ENV['API_KEY'] || File.read('api.key')
  end

  set :arch, 'Linux-x86_64'
end

configure :development do
  # Uncomment the line below if you are using Mac OSX
  set :arch, 'Darwin'
end

get '/' do
  erb :index
end

post '/tracks' do
  puts params
  if params[:tc].to_i != 1 
    flash[:notice] = "Hey, you've not checked the box!"
  elsif params[:track] == nil
    flash[:notice] = "Hey, you haven't uploaded a track!"
  else
    fingerprint = `ENMFP_codegen/codegen.#{settings.arch} #{params[:track][:tempfile].path} 10 20`
    code = JSON.parse(fingerprint).first["code"]
    song = Echowrap.song_identify(:code => code)
    if song.nil?
      flash[:notice] = "Er.. you've got me..."
    else
      flash[:notice] = "Hey #{params[:thetext]} ! Was your song #{song.title} by #{song.artist_name}?"
    end   
  end

  redirect '/'
end