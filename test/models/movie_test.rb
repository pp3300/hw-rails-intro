require "test_helper"

class MovieTest < ActiveSupport::TestCase
  test "all_ratings returns expected list" do
    assert_equal ['G', 'PG', 'PG-13', 'R'], Movie.all_ratings
  end

  test "with_ratings returns movies matching given ratings" do
    movies = Movie.with_ratings(['G'])
    assert movies.all? { |m| m.rating == 'G' }
    assert movies.any?
  end

  test "with_ratings is case-insensitive" do
    movies_upper = Movie.with_ratings(['R'])
    movies_lower = Movie.with_ratings(['r'])
    assert_equal movies_upper.pluck(:id).sort, movies_lower.pluck(:id).sort
  end

  test "with_ratings with nil returns all movies" do
    assert_equal Movie.count, Movie.with_ratings(nil).count
  end

  test "with_ratings with empty array returns all movies" do
    assert_equal Movie.count, Movie.with_ratings([]).count
  end
end
