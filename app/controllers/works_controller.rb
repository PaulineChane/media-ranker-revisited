class WorksController < ApplicationController
  # We should always be able to tell what category
  # of work we're dealing with
  before_action :require_login, except: [:root]
  before_action :must_be_owner, only: [:edit, :update, :destroy]
  before_action :category_from_work, except: [:root, :index, :new, :create]

  def root
    @albums = Work.best_albums
    @books = Work.best_books
    @movies = Work.best_movies
    @best_work = Work.order(vote_count: :desc).first
  end

  def index
    @works_by_category = Work.to_category_hash
  end

  def new
    @work = @current_user.works.new
  end

  def create
    @work = @current_user.works.new(media_params)
    @media_category = @work.category
    if @work.save
      flash[:status] = :success
      flash[:result_text] = "Successfully created #{@media_category.singularize} #{@work.id}"
      redirect_to work_path(@work)
    else
      flash[:status] = :failure
      flash[:result_text] = "Could not create #{@media_category.singularize}"
      flash[:messages] = @work.errors.messages
      render :new, status: :bad_request
    end
  end

  def show
    @votes = @work.votes.order(created_at: :desc)
  end

  def edit
  end

  def update
    if @work.update(media_params)
      flash[:status] = :success
      flash[:result_text] = "Successfully updated #{@media_category.singularize} #{@work.id}"
      redirect_to work_path(@work)
    else
      flash.now[:status] = :failure
      flash.now[:result_text] = "Could not update #{@media_category.singularize}"
      flash.now[:messages] = @work.errors.messages
      render :edit, status: :not_found
    end
  end

  def destroy
    @work.destroy
    flash[:status] = :success
    flash[:result_text] = "Successfully destroyed #{@media_category.singularize} #{@work.id}"
    redirect_to root_path
  end

  def upvote

    vote = Vote.new(user: @current_user, work: @work)
    if vote.save
      flash[:status] = :success
      flash[:result_text] = "Successfully upvoted!"
    else
      flash[:status] = :failure
      flash[:result_text] = "Could not upvote"
      flash[:messages] = vote.errors.messages
    end
    # Refresh the page to show either the updated vote count
    # or the error message
    redirect_back fallback_location: work_path(@work)
  end

  private

  def media_params
    params.require(:work).permit(:title, :category, :creator, :description, :publication_year)
  end

  def category_from_work
    @work = Work.find_by(id: params[:id])
    return render_404 unless @work
    @media_category = @work.category.downcase.pluralize
  end

  def must_be_owner
    @current_user = User.find_by_id(session[:user_id])
    @work = Work.find_by(id: params[:id])
    if @work.nil?
      flash.now[:status] = :failure
      flash.now[:result_text] = "Work not found."
      redirect_to works_path
      return
    elsif @current_user.nil? || @work.user != @current_user
      flash.now[:status] = :failure
      flash.now[:result_text] = "Forbidden access. You may be trying to modify a work you didn't add."
      redirect_to work_path(@work.id)
      return
    end
  end
end
