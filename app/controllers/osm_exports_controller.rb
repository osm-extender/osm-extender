class OsmExportsController < ApplicationController
  before_filter :require_connected_to_osm

  before_filter {
    params[:file_options] ||= {}
    params[:file_options][:column_separator] ||= ','
    params[:file_options][:quote] ||= '"'
    params[:file_options][:include_header] = params[:file_options][:include_header].eql?('1')
    params[:file_options][:force_quotes] = params[:file_options][:force_quotes].eql?('1')
  }


  def index
    params[:term_id] ||= get_current_term_id
  end

  def members
    require_osm_permission :read, :member
    data = get_members_data
    csv_options = {
      :col_sep => get_column_separator,
      :write_headers => params[:file_options][:include_header],
      :force_quotes => params[:file_options][:force_quotes],
      :quote_char => params[:file_options][:quote] || '"',
      :skip_blanks => true,
      :headers => data[:headers]
    }
    send_csv('Members', csv_options, data[:items])
  end

  def programme_activities
    require_osm_permission :read, :programme
    data = []
    Osm::Meeting.get_for_section(current_user.osm_api, current_section, params[:term_id]).each do |meeting|
      meeting.activities.each do |activity|
        data.push [meeting.id, activity.activity_id, activity.title, activity.notes]
      end
    end

    csv_options = {
      :col_sep => get_column_separator,
      :write_headers => params[:file_options][:include_header],
      :force_quotes => params[:file_options][:force_quotes],
      :quote_char => params[:file_options][:quote] || '"',
      :skip_blanks => true,
      :headers => [
        'Meeting ID',
        'Activity ID',
        'Title',
        'Notes',
      ]
    }
    send_csv('Programme Activities', csv_options, data)
  end

  def programme_meetings
    require_osm_permission :read, :programme
    data = Osm::Meeting.get_for_section(current_user.osm_api, current_section, params[:term_id]).map { |i|
      i.attributes.values_at(
        'id',
        'date',
        'start_time',
        'finish_time',
        'title',
        'notes_for_parents',
        'pre_notes',
        'post_notes',
        'leaders',
        'games',
      )
    }

    csv_options = {
      :col_sep => get_column_separator,
      :write_headers => params[:file_options][:include_header],
      :force_quotes => params[:file_options][:force_quotes],
      :quote_char => params[:file_options][:quote] || '"',
      :skip_blanks => true,
      :headers => [
        'ID',
        'Date',
        'Start Time',
        'Finish Time',
        'Title',
        'Notes for Parents',
        'Pre Notes',
        'Post Notes',
        'Leaders',
        'Games',
      ]
    }
    send_csv('Programme Meetings', csv_options, data)
  end


  private
  def get_filename_extension
    filename_extension = {
      'TAB' => 'tsv',
      ',' => 'csv',
      'PIPE' => 'psv'
    }[params[:file_options][:column_separator]]
    return filename_extension || "#{params[:file_options][:column_separator][0]}sv"
  end

  def get_column_separator
    column_separator = {'TAB' => "\t", 'PIPE' => '|'}[params[:file_options][:column_separator]]
    return column_separator || params[:file_options][:column_separator][0]
  end

  def send_csv(data_label, options, data)
    extension = get_filename_extension
    filename = [
      current_section.group_name.gsub(' ', '_').camelize,
      current_section.name.gsub(' ', '_').camelize,
      data_label.gsub(' ', '_').camelize
    ].join('_') + ".#{extension}"

    csv_string = CSV.generate(options) do |csv|
      data.each do |item|
        csv << item
      end
    end
    send_data csv_string, :filename => filename, :type => "text/#{extension}", :disposition => 'attachment'
  end


  def get_members_data
    items = Osm::Member.get_for_section(current_user.osm_api, current_section, params[:term_id])
    groupings = get_current_section_groupings.invert
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
      :items => items.map { |i|
        data = i.attributes.values_at(
          'id',
          'first_name',
          'last_name',
          '', # Will be filled with grouping name later
          'age',
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
        )
        data[3] = groupings[i.grouping_id] # Grouping name
        data
      }
    }
  end

end
