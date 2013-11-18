class PostDraftsController < ApplicationController
  
  respond_to :json

  def create
    saved = PostDraft.create_or_update({ :user_id => current_user.id,
                                         :text => params[:text].to_s,
                                         :provider => params[:provider],
                                         :original_post_id => params[:original_post_id].to_i
                                       })
    respond_with({ :saved => saved }, :location => '/post_drafts')
  end

  # FIXME: Using original_post_id instead of id here
  def show
    respond_with PostDraft.find_by_user_id_and_original_post_id_and_provider(current_user.id, params[:id], params[:provider])
  end
end
