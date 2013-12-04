class Annotation < ActiveRecord::Base
  belongs_to :post
  belongs_to :user
  attr_accessible :text

  validates_presence_of :post_id, :user_id, :text

  def as_json(options = {})
    {
      :text => self.text,
      :date => self.created_at,
      :published_id => self.published_id,
      :user => {
        :name => self.user.name,
        :url => self.user.url 
      }
    }
  end
end
