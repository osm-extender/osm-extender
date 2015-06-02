class OsmExportsController < ApplicationController
  before_action :require_connected_to_osm

  before_filter {
    params[:file_options] ||= {}
    # Set defaults
    params[:file_options][:include_header] ||= '1'
    params[:file_options][:force_quotes] ||= '0'
    params[:file_options][:column_separator] ||= ','
    params[:file_options][:quote] ||= '"'
    # Convert to Boolean
    params[:file_options][:include_header] = params[:file_options][:include_header].eql?('1')
    params[:file_options][:force_quotes] = params[:file_options][:force_quotes].eql?('1')
  }


  def index
    params[:term_id] ||= get_current_term_id
    @flexi_records = Hash[current_section.flexi_records.sort.map{ |f| [f.name, f.id] } ]
  end


  def flexi_record
    require_osm_permission :read, :flexi
    flexi_record = nil
    flexi_record_id = params[:flexi_record_id].to_i

    current_section.flexi_records.each do |record|
      flexi_record = record if record.id == flexi_record_id
      break
    end
    if flexi_record.nil? # Record isn't accessible by this user
      flash[:error] = "You don't have access to that flexi record."
      redirect_back_or_to osm_export_path
      return
    end

    additional_information_fields = []
    system_fields = []
    flexi_record.get_columns(osm_api).each do |field|
      field.name = 'Date of Birth' if field.id.eql?('dob')
      if field.id.match(/\Af_\d+\Z/)
        additional_information_fields.push field
      else
        system_fields.push field
      end
    end

    fields = [*system_fields, *additional_information_fields]
    headers = ['Member ID', *fields.map{ |f| f.name }]
    records = flexi_record.get_data(osm_api).map{ |r| [
      r.member_id,
      *r.fields.values_at(*fields.map{ |f| f.id })
    ]}

    send_csv(flexi_record.name, headers, records)
    log_usage(:extra_details => {:flexi_record_id => flexi_record_id})
  end


  def members
    require_osm_permission :read, :member

    members = Osm::Member.get_for_section(osm_api, current_section, params[:term_id])

    additional_information_fields_for = {member: [], contact: [], primary_contact: [], secondary_contact: [], emergency_contact: [], doctor: []}
    additional_information_field_labels_for = {member: {}, contact: {}, primary_contact: {}, secondary_contact: {}, emergency_contact: {}, doctor: {}}
    enabled_contacts = {contact: false, primary_contact: false, secondary_contact: false, emergency_contact: false, doctor: false}
    members.each do |member|
      additional_information_fields_for[:member].push *member.additional_information.keys
      additional_information_field_labels_for[:member].merge!(member.additional_information_labels)
      [:contact, :primary_contact, :secondary_contact, :emergency_contact, :doctor].each do |contact|
        unless member.send(contact).nil?
          enabled_contacts[contact] = true
          additional_information_fields_for[contact].push *member.send(contact).additional_information.keys
          additional_information_field_labels_for[contact].merge!(member.send(contact).additional_information_labels)
        end
      end
    end

    additional_information_fields_for.keys.each do |contact|
      additional_information_fields_for[contact].uniq!
    end

    headers = [
      'Member ID',
      'Section ID',
      'Grouping ID',
      'Grouping Role',
      'Title',
      'First Name',
      'Last Name',
      'Grouping',
      'Grouping Leader',
      'Age',
      'Date of Birth',
      'Joined Movement',
      'Started Section',
      'Finished Section',
      'Gender',
    ]
    if enabled_contacts[:contact]
      headers.push(
        'Member - Address 1',
        'Member - Address 2',
        'Member - Address 3',
        'Member - Address 4',
        'Member - Postcode',
        'Member - Phone 1',
        'Member - Receieve Phone 1',
        'Member - Phone 2',
        'Member - Receieve Phone 2',
        'Member - Email 1',
        'Member - Receieve Email 1',
        'Member - Email 2',
        'Member - Receieve Email 2',
        *additional_information_field_labels_for[:contact].values_at(*additional_information_fields_for[:contact]).map{ |l| "Member - #{l}"}
      )
    end
    if enabled_contacts[:primary_contact]
      headers.push(
        'Primary Contact 1 - Title',
        'Primary Contact 1 - First Name',
        'Primary Contact 1 - Last Name',
        'Primary Contact 1 - Address 1',
        'Primary Contact 1 - Address 2',
        'Primary Contact 1 - Address 3',
        'Primary Contact 1 - Address 4',
        'Primary Contact 1 - Postcode',
        'Primary Contact 1 - Phone 1',
        'Primary Contact 1 - Receieve Phone 1',
        'Primary Contact 1 - Phone 2',
        'Primary Contact 1 - Receieve Phone 2',
        'Primary Contact 1 - Email 1',
        'Primary Contact 1 - Receieve Email 1',
        'Primary Contact 1 - Email 2',
        'Primary Contact 1 - Receieve Email 2',
        *additional_information_field_labels_for[:primary_contact].values_at(*additional_information_fields_for[:primary_contact]).map{ |l| "Primary Contact 1 - #{l}"}
      )
    end
    if enabled_contacts[:secondary_contact]
      headers.push(
        'Primary Contact 2 - Title',
        'Primary Contact 2 - First Name',
        'Primary Contact 2 - Last Name',
        'Primary Contact 2 - Address 1',
        'Primary Contact 2 - Address 2',
        'Primary Contact 2 - Address 3',
        'Primary Contact 2 - Address 4',
        'Primary Contact 2 - Postcode',
        'Primary Contact 2 - Phone 1',
        'Primary Contact 2 - Receieve Phone 1',
        'Primary Contact 2 - Phone 2',
        'Primary Contact 2 - Receieve Phone 2',
        'Primary Contact 2 - Email 1',
        'Primary Contact 2 - Receieve Email 1',
        'Primary Contact 2 - Email 2',
        'Primary Contact 2 - Receieve Email 2',
        *additional_information_field_labels_for[:secondary_contact].values_at(*additional_information_fields_for[:secondary_contact]).map{ |l| "Primary Contact 2 - #{l}"}
      )
    end
    if enabled_contacts[:emergency_contact]
      headers.push(
        'Emergency Contact - Title',
        'Emergency Contact - First Name',
        'Emergency Contact - Last Name',
        'Emergency Contact - Address 1',
        'Emergency Contact - Address 2',
        'Emergency Contact - Address 3',
        'Emergency Contact - Address 4',
        'Emergency Contact - Postcode',
        'Emergency Contact - Phone 1',
        'Emergency Contact - Phone 2',
        'Emergency Contact - Email 1',
        'Emergency Contact - Email 2',
        *additional_information_field_labels_for[:emergency_contact].values_at(*additional_information_fields_for[:emergency_contact]).map{ |l| "Emergency Contact - #{l}"}
      )
    end
    if enabled_contacts[:doctor]
      headers.push(
        "Doctor's Surgery - Title",
        "Doctor's Surgery - First Name",
        "Doctor's Surgery - Last Name",
        "Doctor's Surgert - Surgery",
        "Doctor's Surgery - Address 1",
        "Doctor's Surgery - Address 2",
        "Doctor's Surgery - Address 3",
        "Doctor's Surgery - Address 4",
        "Doctor's Surgery - Postcode",
        "Doctor's Surgery - Phone 1",
        "Doctor's Surgery - Phone 2",
        *additional_information_field_labels_for[:doctor].values_at(*additional_information_fields_for[:doctor]).map{ |l| "Doctor's Surgery - #{l}"}
      )
    end
    headers.push *additional_information_field_labels_for[:member].values_at(*additional_information_fields_for[:member])

    members.map! { |i|
      member = []
      member.push *i.attributes.values_at(*%w{ id section_id grouping_id grouping_leader title first_name last_name grouping_label grouping_leader_label age date_of_birth joined_movement started_section finished_section gender })
      if enabled_contacts[:contact]
        member.push *i.contact.attributes.values_at(*%w{ address_1 address_2 address_3 address_4 postcode phone_1 receive_phone_1 phone_2 receive_phone_2 email_1 receive_email_1 email_2 receive_email_2 })
        member.push *i.contact.additional_information.values_at(*additional_information_fields_for[:contact])
      end
      if enabled_contacts[:primary_contact]
        member.push *i.primary_contact.attributes.values_at(*%w{ title first_name last_name address_1 address_2 address_3 address_4 postcode phone_1 receive_phone_1 phone_2 receive_phone_2 email_1 receive_email_1 email_2 receive_email_2 })
        member.push *i.primary_contact.additional_information.values_at(*additional_information_fields_for[:primary_contact])
      end
      if enabled_contacts[:secondary_contact]
        member.push *i.secondary_contact.attributes.values_at(*%w{ title first_name last_name address_1 address_2 address_3 address_4 postcode phone_1 receive_phone_1 phone_2 receive_phone_2 email_1 receive_email_1 email_2 receive_email_2 })
        member.push *i.secondary_contact.additional_information.values_at(*additional_information_fields_for[:secondary_contact])
      end
      if enabled_contacts[:emergency_contact]
        member.push *i.emergency_contact.attributes.values_at(*%w{ title first_name last_name address_1 address_2 address_3 address_4 postcode phone_1 phone_2 email_1 email_2 })
        member.push *i.emergency_contact.additional_information.values_at(*additional_information_fields_for[:emergency_contact])
      end
      if enabled_contacts[:doctor]
        member.push *i.doctor.attributes.values_at(*%w{ title first_name last_name surgery address_1 address_2 address_3 address_4 postcode phone_1 phone_2 })
        member.push *i.doctor.additional_information.values_at(*additional_information_fields_for[:doctor])
      end
      member.push *i.additional_information.values_at(*additional_information_fields_for[:member])
    }

    send_csv('Members', headers, members)
    log_usage(:extra_details => {:term_id => params[:term_id].to_i})
  end


  def programme_activities
    require_osm_permission :read, :programme

    headers = [
      'Meeting ID',
      'Activity ID',
      'Title',
      'Notes',
    ]

    data = []
    Osm::Meeting.get_for_section(osm_api, current_section, params[:term_id]).each do |meeting|
      meeting.activities.each do |activity|
        data.push [meeting.id, activity.activity_id, activity.title, activity.notes]
      end
    end

    send_csv('Programme Activities', headers, data)
    log_usage(:extra_details => {:term_id => params[:term_id].to_i})
  end

  def programme_meetings
    require_osm_permission :read, :programme

    headers = [
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

    data = Osm::Meeting.get_for_section(osm_api, current_section, params[:term_id]).map { |i|
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

    send_csv('Programme Meetings', headers, data)
    log_usage(:extra_details => {:term_id => params[:term_id].to_i})
  end


  private
  def send_csv(data_label, headers, data)
    options = {
      :col_sep => get_column_separator,
      :write_headers => params[:file_options][:include_header],
      :force_quotes => params[:file_options][:force_quotes],
      :quote_char => params[:file_options][:quote] || '"',
      :skip_blanks => true,
      :headers => headers,
    }

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

end
