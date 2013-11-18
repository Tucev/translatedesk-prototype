class PostDraft < ActiveRecord::Base
  belongs_to :user
  attr_accessible :text, :original_post_id, :provider, :user_id

  validates :user_id, :uniqueness => { :scope => [:original_post_id, :provider] }
  validates_presence_of :user_id, :original_post_id, :text, :provider

  def self.create_or_update(params)
    return false if params[:user_id].blank? or params[:text].blank? or params[:original_post_id].blank? or params[:provider].blank?

    draft = PostDraft.find_by_user_id_and_original_post_id_and_provider params[:user_id], params[:original_post_id], params[:provider]
    
    if draft.nil?
      draft = PostDraft.new
      draft.user_id = params[:user_id]
      draft.original_post_id = params[:original_post_id]
      draft.provider = params[:provider]
    end

    draft.text = params[:text]

    draft.save
  end
end
