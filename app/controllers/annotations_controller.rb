class AnnotationsController < ApplicationController

  respond_to :json

  def create
    @annotation = Annotation.new
    @annotation.user = current_user
    @annotation.text= params[:text]
    @annotation.post_id = params[:post_id]
    @annotation.save!
    respond_with(@annotation, :location => annotation_path(@annotation))
  end

  def show
    respond_with Annotation.find(params[:id])
  end
end
