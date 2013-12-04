class AnnotationsController < ApplicationController

  respond_to :json

  def create
    post = Post.find(params[:post_id])
    model = Post::PROVIDERS.include?(post.provider.to_sym) ? Post::PROVIDERS[post.provider.to_sym] : Post

    @annotation = Annotation.new
    @annotation.user = current_user
    @annotation.text = params[:text]
    model.find(post.id).annotations << @annotation

    respond_with(@annotation, :location => annotation_path(@annotation))
  end

  def show
    respond_with Annotation.find(params[:id])
  end
end
