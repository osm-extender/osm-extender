class FaqTagsController < ApplicationController

  def index
    @tags = FaqTag.order(:name)
    render json: @tags.tokens(params[:q])
  end

end
