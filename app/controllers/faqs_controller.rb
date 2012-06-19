class FaqsController < ApplicationController
  skip_before_filter :require_login, :only => [:list]
  load_and_authorize_resource

  def index
    @faqs = Faq.all
    @faq = Faq.new

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @faqs }
    end
  end

  def list
    @faqs = Faq.where(['active = ?', true])

    respond_to do |format|
      format.html # list.html.erb
      format.json { render json: @faqs }
    end
  end

  def show
    @faq = Faq.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @faq }
    end
  end

  def new
    @faq = Faq.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @faq }
    end
  end

  def edit
    @faq = Faq.find(params[:id])
  end

  def create
    @faq = Faq.new(params[:faq])

    respond_to do |format|
      if @faq.save
        format.html { redirect_to faqs_url, notice: 'FAQ was successfully created.' }
        format.json { render json: @faq, status: :created, location: @faq }
      else
        format.html { render action: "new" }
        format.json { render json: @faq.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @faq = Faq.find(params[:id])

    respond_to do |format|
      if @faq.update_attributes(params[:faq])
        format.html { redirect_to faqs_url, notice: 'FAQ was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @faq.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @faq = Faq.find(params[:id])

    if can? :delete, @faq
      @faq.destroy
      respond_to do |format|
        format.html { redirect_to faqs_url }
        format.json { head :ok }
      end

    else
      redirect_back_or_to_root
    end
  end

end
