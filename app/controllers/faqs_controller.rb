class FaqsController < ApplicationController
  skip_before_filter :require_login, :only => :list
  load_and_authorize_resource

  def index
    @faqs = FaqTag.all_by_tag(:all_faqs => true)
    @faq = Faq.new
    @faq_tags = FaqTag.order(:name)
  end

  def list
    @faqs = FaqTag.all_by_tag
  end

  def show
    @faq = Faq.find(params[:id])
  end

  def new
    @faq = Faq.new
  end

  def edit
    @faq = Faq.find(params[:id])
  end

  def create
    @faq = Faq.new(params[:faq])

    if @faq.save
      redirect_to faqs_url, notice: 'FAQ was successfully created.'
    else
      render action: "new"
    end
  end

  def update
    @faq = Faq.find(params[:id])

    if @faq.update_attributes(params[:faq])
      redirect_to faqs_url, notice: 'FAQ was successfully updated.'
    else
      render action: "edit"
    end
  end

  def destroy
    @faq = Faq.find(params[:id])

    if can? :delete, @faq
      @faq.destroy
      redirect_to faqs_url
    else
      redirect_back_or_to_root
    end
  end

  def re_order
    params["faq_#{params[:tag_id]}"].each_with_index do |id, index|
      FaqTaging.find_by_tag_id_and_faq_id(params[:tag_id], id).update_attributes({position: index+1})
    end
    render nothing: true
  end

end
