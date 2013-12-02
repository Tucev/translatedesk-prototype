class UsersController < ApplicationController
  respond_to :json

  def show
    respond_with(User.find(params[:id])) if current_user.id.to_i === params[:id].to_i
  end

  def update
    if current_user.id.to_i === params[:id].to_i
      user = User.find(params[:id])
      user.queue = params[:queue]
      user.save!
      respond_with user
    else
      raise 'You are not allowed to do that.'
    end
  end
end
