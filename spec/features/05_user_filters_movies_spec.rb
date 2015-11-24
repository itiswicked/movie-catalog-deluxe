require 'faker'
require 'spec_helper'

feature 'user filters movies' do
  before(:each) do
    db_connection do |conn|
      40.times do
        sql_query_1 = "INSERT INTO actors (name) VALUES ($1) RETURNING id"
        data_1 = [Faker::Name.name]
        actor_id = conn.exec_params(sql_query_1, data_1).first["id"]

        sql_query_2 = "INSERT INTO genres (name) VALUES ($1) RETURNING id"
        data_2 = ["Action & Adventure"]
        genre_id = conn.exec_params(sql_query_2, data_2).first["id"]

        sql_query_3 = "INSERT INTO studios (name) VALUES ($1) RETURNING id"
        data_3 = ["Lionsgate Films"]
        studio_id = conn.exec_params(sql_query_3, data_3).first["id"]

        sql_query_4 = "INSERT INTO movies (title, year, rating, genre_id, studio_id) VALUES ($1, $2, $3, $4, $5) RETURNING id"
        data_4 = [Faker::Address.street_address,(1990..2020).to_a.sample, (70..100).to_a.sample, genre_id, studio_id]
        movie_id = conn.exec_params(sql_query_4, data_4).first["id"]

        sql_query_5 = "INSERT INTO cast_members (movie_id, actor_id, character) VALUES ($1, $2, $3) RETURNING id"
        data_5 = [movie_id, actor_id, Faker::Commerce.product_name]
        conn.exec_params(sql_query_5, data_5)
      end
      sql_query_1 = "INSERT INTO actors (name) VALUES ($1) RETURNING id"
      data_1 = ["Aaaaaaaa"]
      actor_id = conn.exec_params(sql_query_1, data_1).first["id"]

      sql_query_2 = "INSERT INTO genres (name) VALUES ($1) RETURNING id"
      data_2 = ["Action & Adventure"]
      genre_id = conn.exec_params(sql_query_2, data_2).first["id"]

      sql_query_3 = "INSERT INTO studios (name) VALUES ($1) RETURNING id"
      data_3 = ["Lionsgate Films"]
      studio_id = conn.exec_params(sql_query_3, data_3).first["id"]

      sql_query_4 = "INSERT INTO movies (title, year, rating, genre_id, studio_id) VALUES ($1, $2, $3, $4, $5) RETURNING id"
      data_4 = ["Faker::Address.street_address",2021, 101, genre_id, studio_id]
      movie_id = conn.exec_params(sql_query_4, data_4).first["id"]

      sql_query_5 = "INSERT INTO cast_members (movie_id, actor_id, character) VALUES ($1, $2, $3) RETURNING id"
      data_5 = [movie_id, actor_id, "Faker::Commerce.product_name"]
      conn.exec_params(sql_query_5, data_5)
    end
  end

  scenario "user organizes by rating" do
    visit "/movies?order=rating"
    expect(page).to have_content "101"
  end

  scenario 'user organizes by year' do
    visit "/movies?order=year"
    save_and_open_page
    expect(page).to have_content("2021")
  end
end
