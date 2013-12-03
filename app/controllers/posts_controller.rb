class PostsController < ApplicationController

  respond_to :json
  
  skip_before_filter :authenticate_user!, :only => :show
  before_filter(:except => :show) { |c| c.load_model params[:provider] }
  before_filter(:except => :show) { |c| c.check_user params[:provider] }

  # Get posts
  def fetch
    respond_with @model.fetch(params[:query].to_s, params[:options], current_user)
  end

  # Get a conversation from a post
  def conversation
    respond_with @model.conversation(params[:post_id])
  end

  # Create a post
  def create
    begin
      @post = @model.create!(
        :text => params[:text],
        :source_language => params[:source_language],
        :target_language => params[:target_language],
        :original_text => params[:original_text],
        :original_post_id => params[:original_post_id],
        :original_post_author => params[:original_post_author],
        :user_id => current_user.id,
        :provider => params[:provider])
      respond_with @post, :location => post_path(@post)
    rescue Exception => e
      respond_with({ :error => e.message }, :location => '/posts')
    end
  end

  # Full view of a post
  def show
    post = Post.find_by_uuid(params[:uuid])
    model = Post::PROVIDERS.include?(post.provider.to_sym) ? Post::PROVIDERS[post.provider.to_sym] : Post
    @post = model.find(post.id)
  end

  # Preview how a text would be posted
  def preview
    respond_with({ :text => @model.truncate_text(params[:text].to_s, params[:author], BITLY['example']) }, :location => '/posts')
  end

  # Get translations of a post
  def translations
    respond_with @model.translations(params[:post_id], params[:provider])
  end

  protected

  def load_model(provider)
    @model = Post::PROVIDERS.include?(provider.to_sym) ? Post::PROVIDERS[provider.to_sym] : Post
  end

  def check_user(provider)
    raise 'You must be signed in through the same provider you are trying to translate' unless current_user.provider == provider
  end
end
