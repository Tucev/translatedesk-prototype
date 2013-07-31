class MachineTranslationsController < ApplicationController

  respond_to :json

  def translators
    respond_with Translator::translators
  end

  def translate
    respond_with({ :text => Translator::translate(params[:translator], params[:source], params[:target], params[:text]) }, :location => '/machine_translation/translate')
  end
end
