require 'sinatra'
require "sinatra/reloader" if development?
require 'data_mapper'                              #te permite abstraerte de la base de datos. Implementa el patrón ->
require 'pp'                                       #-> active record

# full path!
DataMapper.setup(:default,                                                           
                 ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/database.db" )   #indica donde esta la base de datos

class PL0Program                                   #Creo una clase para definir una tabla de la base de datos
  include DataMapper::Resource                     
  
  property :name, String, :key => true
  property :source, String, :length => 1..1024
end

  DataMapper.finalize
  DataMapper.auto_upgrade!                         #se modifica la base de datos 

enable :sessions                                   #no se usa en esta practica

helpers do                                         #se usa para definir metodos para k esten disponibles en las 
  def current?(path='/')                           #rutas y en las vistas
    (request.path==path || request.path==path+'/') ? 'class = "current"' : ''
  end
end


get '/grammar' do                                  
  erb :grammar
end

get '/:selected?' do |selected|                    #cualquier ruta que case con este patrón (/:selected?), ->
  programs = PL0Program.all                        #->cualquier ruta que escriba se guardara en selected
  pp programs
  puts "selected = #{selected}"
  c  = PL0Program.first(:name => selected)         #dame el registro(programa) cuyo nombre es "selected"
  source = if c then c.source else "3-2-1" end     
  erb :index,                                      
      :locals => { :programs => programs, :source => source }
end

post '/save' do
  pp params
  name = params[:fname]
  c  = PL0Program.first(:name => name)
  puts "prog <#{c.inspect}>"
  if c
    c.source = params["input"]
    c.save
  else
    c = PL0Program.new
    c.name = params["fname"]
    c.source = params["input"]
    c.save
  end
  pp c
  redirect '/'
end
