class Movie < ApplicationRecord
  def self.all_ratings
    ['G', 'PG', 'PG-13', 'R']
  end

  def self.with_ratings(ratings_list)
    return all if ratings_list.blank?

    ratings = ratings_list.respond_to?(:keys) ? ratings_list.keys : ratings_list
    ratings = Array(ratings).map(&:to_s).map(&:strip)
    return all if ratings.empty?

    where('LOWER(rating) IN (?)', ratings.map(&:downcase))
  end
end
