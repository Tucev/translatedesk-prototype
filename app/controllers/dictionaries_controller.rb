class DictionariesController < ApplicationController

  respond_to :json

  def words_meanings
    respond_with Dictionary.words_meanings(params[:words], params[:from], params[:to]), :location => words_meanings_dictionaries_path
  end

end
