class MoviesController < ApplicationController
  before_action :set_movie, only: %i[ show edit update destroy ]

  # GET /movies or /movies.json
  def index
    @all_ratings = Movie.all_ratings

    sort_param = params[:sort_by] || params[:sort]
    ratings_param = params[:ratings]
    user_submitted_form = params[:commit].present?

    # Detect if sorting or filtering settings were missing from params
    # but exist in session, and the user did not just submit the form (e.g., navigated back)
    need_redirect = false

    if sort_param.nil? && session[:sort_by].present? && !user_submitted_form
      sort_param = session[:sort_by]
      need_redirect = true
    end

    if ratings_param.nil? && session[:ratings].present? && !user_submitted_form
      ratings_param = session[:ratings]
      need_redirect = true
    end

    if need_redirect
      flash.keep
      redirect_to movies_path(sort_by: sort_param, ratings: ratings_param) and return
    end

    # Determine ratings to show and update session if provided
    if ratings_param.present?
      if ratings_param.is_a?(Array)
        @ratings_to_show = ratings_param
      elsif ratings_param.respond_to?(:keys)
        @ratings_to_show = ratings_param.keys
      else
        @ratings_to_show = @all_ratings
      end
      session[:ratings] = ratings_param.respond_to?(:to_unsafe_h) ? ratings_param.to_unsafe_h : ratings_param
    elsif user_submitted_form
      # If no boxes are checked after Refresh, display all and check all
      @ratings_to_show = @all_ratings
      session[:ratings] = @all_ratings.to_h { |r| [r, "1"] }
    elsif session[:ratings].present?
      saved = session[:ratings]
      @ratings_to_show = saved.respond_to?(:keys) ? saved.keys : (saved.is_a?(Array) ? saved : @all_ratings)
    else
      @ratings_to_show = @all_ratings
    end

    # Determine sort order and update session if provided
    if sort_param.present?
      @sort_by = sort_param
      session[:sort_by] = @sort_by
    elsif session[:sort_by].present? && !user_submitted_form
      @sort_by = session[:sort_by]
    else
      @sort_by = nil
    end

    @movies = Movie.with_ratings(@ratings_to_show)

    if @sort_by.present? && Movie.column_names.include?(@sort_by)
      @movies = @movies.order(@sort_by => :asc)
    end
  end

  # GET /movies/1 or /movies/1.json
  def show
  end

  # GET /movies/new
  def new
    @movie = Movie.new
  end

  # GET /movies/1/edit
  def edit
  end

  # POST /movies or /movies.json
  def create
    @movie = Movie.new(movie_params)

    respond_to do |format|
      if @movie.save
        format.html { redirect_to @movie, notice: "Movie was successfully created." }
        format.json { render :show, status: :created, location: @movie }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @movie.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /movies/1 or /movies/1.json
  def update
    respond_to do |format|
      if @movie.update(movie_params)
        format.html { redirect_to @movie, notice: "Movie was successfully updated." }
        format.json { render :show, status: :ok, location: @movie }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @movie.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /movies/1 or /movies/1.json
  def destroy
    @movie.destroy!

    respond_to do |format|
      format.html { redirect_to movies_path, status: :see_other, notice: "Movie was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_movie
      @movie = Movie.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def movie_params
      params.require(:movie).permit(:title, :rating, :description, :release_date)
    end
end
