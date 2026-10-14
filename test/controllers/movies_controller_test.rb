require "test_helper"

class MoviesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @movie = movies(:one)
  end

  test "should get index" do
    get movies_url
    assert_response :success
  end

  test "should filter by ratings" do
    get movies_url, params: { ratings: { "G" => "1" } }
    assert_response :success
    assert_select "input[id=ratings_G][checked=checked]"
  end

  test "should sort by title" do
    get movies_url, params: { sort_by: "title" }
    assert_response :success
    assert_select "select#sort_by option[value=title][selected=selected]"
  end

  test "should sort by release_date" do
    get movies_url, params: { sort_by: "release_date" }
    assert_response :success
    assert_select "select#sort_by option[value=release_date][selected=selected]"
  end

  test "should remember ratings and sort in session and redirect when params missing" do
    get movies_url, params: { ratings: { "G" => "1" }, sort_by: "title" }
    assert_response :success

    get movies_url
    assert_response :redirect
    follow_redirect!
    assert_response :success
    assert_select "input[id=ratings_G][checked=checked]"
    assert_select "select#sort_by option[value=title][selected=selected]"
  end

  test "should show all ratings when refreshing with no checkboxes checked" do
    get movies_url, params: { commit: "Refresh" }
    assert_response :success
    assert_select "input[id=ratings_G][checked=checked]"
    assert_select "input[id=ratings_PG][checked=checked]"
    assert_select "input[id=ratings_PG-13][checked=checked]"
    assert_select "input[id=ratings_R][checked=checked]"
  end

  test "should get new" do
    get new_movie_url
    assert_response :success
  end

  test "should create movie" do
    assert_difference("Movie.count") do
      post movies_url, params: { movie: { description: @movie.description, rating: @movie.rating, release_date: @movie.release_date, title: @movie.title } }
    end

    assert_redirected_to movie_url(Movie.last)
  end

  test "should show movie" do
    get movie_url(@movie)
    assert_response :success
  end

  test "should get edit" do
    get edit_movie_url(@movie)
    assert_response :success
  end

  test "should update movie" do
    patch movie_url(@movie), params: { movie: { description: @movie.description, rating: @movie.rating, release_date: @movie.release_date, title: @movie.title } }
    assert_redirected_to movie_url(@movie)
  end

  test "should destroy movie" do
    assert_difference("Movie.count", -1) do
      delete movie_url(@movie)
    end

    assert_redirected_to movies_url
  end
end
