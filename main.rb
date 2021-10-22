require 'json'
require 'jwt'
require 'sinatra/base'

class JwtAuth

    def initialize app
      @app = app
    end
  
    def call env
      begin
        options = { algorithm: 'HS256', iss: ENV['JWT_ISSUER'] }
        bearer = env.fetch('HTTP_AUTHORIZATION', '').slice(7..-1)
        payload, header = JWT.decode bearer, ENV['JWT_SECRET'], true, options 
        env[:user] = payload['user']
  
        @app.call env
      rescue JWT::ExpiredSignature
        [403, { 'Content-Type' => 'text/plain' }, ['El token expiró.']]
      rescue JWT::InvalidIssuerError
        [403, { 'Content-Type' => 'text/plain' }, ['El token no tienen un emisor válido.']]
      rescue JWT::InvalidIatError
        [403, { 'Content-Type' => 'text/plain' }, ['El token no tiene un tiempo de emisión válido.']]
      rescue JWT::DecodeError
        [401, { 'Content-Type' => 'text/plain' }, ['Se tiene que enviar un token.']]
      end
    end
  
  end

class Api < Sinatra::Base

  require 'uri'
  require 'net/http'

  use JwtAuth
  
  def initialize
    super

  end

  def generate_qr(aHash)
    url = URI("http://api.qrserver.com/v1/create-qr-code/?data=https://dssd-stamp.herokuapp.com/" + aHash.to_s + "&size=200x200")
    http = Net::HTTP.new(url.host, url.port)
    request = Net::HTTP::Post.new(url)
    response = http.request(request)
    response.read_body
  end

  post '/stamp' do
    dossier = request.params["dossier"] 
    statute = request.params["statute"]
    errors = []
    if dossier.nil?
      error = true
      errors.push('No se especificó un numero de expediente.')
    end
    if statute.nil?
      error = true
      errors.push('No se envió el estatuto')
    end
    if error
      [401, { 'Content-Type' => 'text/plain' }, errors]
    else 
      aHash = Time.now.to_i
      response = generate_qr(aHash)
      [200, { 'Content-Type' => 'image/png', 'hash' => aHash.to_s }, response ]

    end
  end

  not_found do
    'Uso incorrecto de la API, ingresa en: https://github.com/ucabrera/dssd-stamp para ver la documentación'
  end

end

class Public < Sinatra::Base

  def initialize
    super

    @logins = {
      walterbates: 'bpm',
      test: 'test'
    }
  end

  get '/' do
    redirect "https://github.com/ucabrera/dssd-stamp"
  end

  post '/login' do
    username = params[:username]
    password = params[:password]
    puts username
    puts password
    if username.nil? || password.nil?
      'No se envió el usuario o la contraseña'  
    else  
      if @logins[username.to_sym] == password
        content_type :json
        { token: token(username) }.to_json
      else
        [401, { 'Content-Type' => 'text/plain' }, 'Usuario o contraseña no válidos.']
      end
    end
  end

  not_found do
    'Uso incorrecto de la API, ingresa en: https://github.com/ucabrera/dssd-stamp para ver la documentación'
  end

  def token username
    JWT.encode payload(username), ENV['JWT_SECRET'], 'HS256'
  end
  
  def payload username
    {
      exp: Time.now.to_i + 75,
      iat: Time.now.to_i,
      iss: ENV['JWT_ISSUER'],
      user: {
        username: username
      }
    }
  end

end