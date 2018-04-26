class StatusController < ApplicationController
  skip_before_action :require_login
  skip_before_action :require_gdpr_consent
  before_action { require_authorized }
  respond_to :cacti, :json, :csv, :text_table

  def index
    @status = Status.new
    respond_to :html
  end


  def cache
    respond_with Status.new.cache.except(:cache_hits_percent, :cache_misses_percent)
  end

  def database_size
    data = Status.new.database_size
    respond_with data do |format|
      format.cacti do
        cacti_data = data[:tables].map{ |a| [["#{a[:table]}_size", a[:size]], ["#{a[:table]}_count", a[:count]]] }.flatten(1)
        cacti_data.push ['total_count', data[:totals][:count]]
        cacti_data.push ['total_size', data[:totals][:size]]
        render cacti: cacti_data
      end
      format.csv do
        headings = ['Model', 'Table', 'Count', 'Size']
        data = data[:tables] + [data[:totals].merge(table: 'TOTAL')]
        render csv: data, headings: headings, order: [:model, :table, :size, :count]
      end
      format.text_table do
        headings = ['Model', 'Table', 'Count', 'Size']
        data = data[:tables] + [:separator] + [data[:totals]]
        render text_table: data, headings: headings, order: [:model, :table, :size, :count]
      end
    end
  end

  def delayed_job
    data = Status.new.delayed_job
    respond_with data do |format|
      format.cacti { render cacti: flatten_hash(data) }
      format.csv { render csv: data[:jobs].to_a, headings: ['Status', 'Count'] }
      format.text_table { render text_table: data[:jobs], headings: ['Status', 'Count'] }
    end
  end

  def unicorn_workers
    respond_with Status.new.unicorn_workers
  end

  def users
    respond_with Status.new.users
  end


  private

  def require_authorized
    keys = Figaro.env.status_keys.split(':')
    return true if keys.include? params[:key]
    require_osmx_permission :view_status
  end

  def flatten_hash(hash, base_key='')
    out = {}
    hash.each do |key, value|
      key = "#{base_key}_#{key}" unless base_key.empty?
      if value.is_a?(Hash)
        out.merge! flatten_hash(value, key)
      else
        out[key] = value
      end
    end
    out
  end

end
