class OsmExportsController < ApplicationController
  before_filter :require_connected_to_osm
  before_filter :clean_params

  before_filter {
    @exports_available = {
      :member => 'Members',
    #  :register => 'Attendance register',
    #  :programme => 'Programme',
    #  :events => 'Events',
    #  :flexi => 'Flexi records',
    #  :badge => 'Badge records',
    #  :finance => 'Finance'
    }
  }


  def index
    params[:export] ||= :member
  end

  def export
    unless @exports_available.keys.include?(params[:export])
      flash[:error] = 'That is not a valid item to export.'
      render :index
      return
    end

    unless api_has_osm_permission?(:read, params[:export]) && user_has_osm_permission?(:read, params[:export])
      flash[:error] = 'You do not have the correct OSM permissions to export your selected item.'
      render :index
      return
    end

    column_separators = {'TAB' => "\t"}
    filename_extension = {
      'TAB' => 'tsv',
      ',' => 'csv',
    }[params[:column_separator]] || "#{params[:column_separator][0]}sv"
    filename = current_section.group_name.gsub(' ', '_').camelize + '_'
    filename += current_section.name.gsub(' ', '_').camelize + '_'
    filename += @exports_available[params[:export]].gsub(' ', '_').camelize
    filename += '.' + filename_extension

    data = send("get_#{params[:export].to_s}_data")
    csv_options = {
      :col_sep => column_separators[params[:column_separator]] || params[:column_separator][0],
      :write_headers => params[:include_header],
      :force_quotes => params[:force_quotes],
      :quote_char => params[:quote],
      :skip_blanks => true,
      :headers => data[:headers]
    }
    csv_string = CSV.generate(csv_options) do |csv|
      data[:items].each do |item|
        csv << item.attributes.values_at(*data[:values_at])
      end
    end

    send_data csv_string, :filename => filename, :type => "text/#{filename_extension}", :disposition => 'attachment'
  end


  private
  def clean_params
    params[:export] = params[:export].to_sym if params[:export]
    params[:column_separator] ||= ','
    params[:quote] ||= '"'
    params[:include_header] = params[:include_header] ? params[:include_header].eql?('true') : true
    params[:force_quotes] = params[:force_quotes] ? params[:force_quotes].eql?('true') : false
  end

  def get_member_data
    return {
      :headers => [
        'ID',
        'First Name',
        'Last Name',
        'Grouping',
        'Age',
        current_section.column_names[:phone1],
        current_section.column_names[:phone2],
        current_section.column_names[:phone3],
        current_section.column_names[:phone4],
        current_section.column_names[:email1],
        current_section.column_names[:email2],
        current_section.column_names[:email3],
        current_section.column_names[:email4],
        current_section.column_names[:address],
        current_section.column_names[:address2],
        current_section.column_names[:parents],
        current_section.column_names[:notes],
        current_section.column_names[:medical],
        current_section.column_names[:subs],
        current_section.column_names[:religion],
        current_section.column_names[:school],
        current_section.column_names[:ethnicity],
        current_section.column_names[:custom1],
        current_section.column_names[:custom2],
        current_section.column_names[:custom3],
        current_section.column_names[:custom4],
        current_section.column_names[:custom5],
        current_section.column_names[:custom6],
        current_section.column_names[:custom7],
        current_section.column_names[:custom8],
        current_section.column_names[:custom9],
        'Date of Birth',
        'Joined Scouting',
        'Started Section',
        'Section ID',
        'Grouping ID',
        'Grouping Leader',
      ],
      :values_at => [
        'id',
        'first_name',
        'last_name',
        'grouping',
        'phone1',
        'phone2',
        'phone3',
        'phone4',
        'email1',
        'email2',
        'email3',
        'email4',
        'address',
        'address2',
        'parents',
        'notes',
        'medical',
        'subs',
        'religion',
        'school',
        'ethnicity',
        'custom1',
        'custom2',
        'custom3',
        'custom4',
        'custom5',
        'custom6',
        'custom7',
        'custom8',
        'custom9',
        'date_of_birth',
        'joined',
        'started',
        'section_id',
        'grouping_id',
        'grouping_leader'
      ],
      :items => Osm::Member.get_for_section(current_user.osm_api, current_section),
    }
  end

end
