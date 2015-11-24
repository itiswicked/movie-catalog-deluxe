require "sinatra"
require "pg"
require "pry"

set :views, File.join(File.dirname(__FILE__), "app/views")

configure :development do
  set :db_config, { dbname: "movie_project" }
end

configure :test do
  set :db_config, { dbname: "movies_test" }
end

def db_connection
  begin
    connection = PG.connect(Sinatra::Application.db_config)
    yield(connection)
  ensure
    connection.close
  end
end

get '/' do
  redirect '/actors'
end

get '/actors' do
  db_connection do |conn|
    sql_query = 'SELECT * FROM actors ORDER BY name ASC;'
    @actor_list = conn.exec(sql_query).to_a
  end
  erb :'/actors/index'
end

get '/actors/:id' do
   id = params[:id]
   db_connection do |conn|
     query = 'SELECT m.*, cm.character, a.name AS actor_name FROM cast_members cm
     INNER JOIN actors a
     ON a.id = cm.actor_id
     LEFT JOIN movies m
     ON cm.movie_id = m.id
     WHERE a.id = $1;'
     @actor_movie = conn.exec_params(query, [id]).to_a
  end
  erb :'/actors/show'
end

get '/movies' do
  order_type = params[:order]
  order_type = 'title' if order_type.nil? || order_type.empty?
  order_type.nil? ? asc_or_desc = "ASC" : asc_or_desc = "DESC"
  page_num = params[:page]
  page_num = 1 if page_num.nil? || page_num.empty?
  offset = page_num.to_i * 20 - 20
  db_connection do |conn|
    sql_query = "
    SELECT m.*, g.name AS genre_name, s.name AS studio_name FROM movies m
    LEFT JOIN genres g
    ON m.genre_id = g.id
    LEFT JOIN studios s
    ON m.studio_id = s.id
    ORDER BY m.#{order_type} #{asc_or_desc}
    LIMIT 20 OFFSET $1;
    "
    @movie_list = conn.exec_params(sql_query,[offset]).to_a
  end
  db_connection do |conn|
    sql_query = "
    SELECT COUNT(1) FROM movies;
    "
    @page_count = conn.exec(sql_query).to_a.first['count'].to_i / 20
    if conn.exec(sql_query).to_a.first['count'].to_i % 20 != 0
      @page_count += 1
    end
  end
  erb :'/movies/index'
end

get '/movies/:id' do
  id = params[:id]
  db_connection do |conn|
    query = 'SELECT m.id
    , m.title
    , m.year
    , m.rating
    , g.name AS genre
    , s.name AS studio
    , cm.character
    , a.id AS actor_id
    , a.name AS actor_name
    FROM movies m
    LEFT JOIN cast_members cm
    ON cm.movie_id = m.id
    LEFT JOIN genres g
    ON g.id = m.genre_id
    LEFT JOIN actors a
    ON a.id = cm.actor_id
    LEFT JOIN studios s
    ON s.id = m.studio_id
    WHERE m.id = $1;'
    @movie_actor = conn.exec_params(query, [id]).to_a
  end
  erb :'/movies/show'
end
