class FaqTagsController < ApplicationController
  load_and_authorize_resource

  def index
    @tags = FaqTag.order(:name)
    render json: @tags.tags(params[:q])
  end

  def re_order
    params[:tag].each_with_index do |id, index|
      FaqTag.find(id).update_attributes({position: index+1})
    end
    render nothing: true
  end

end
