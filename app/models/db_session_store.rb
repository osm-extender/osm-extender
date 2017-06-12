class DbSessionStore < ActionDispatch::Session::AbstractStore
  # Attributes to be moved between the model and data hash
  MOVE_ATTRIBUTES = (Session.attribute_names - ['id', 'session_id', 'data', 'created_at', 'updated_at', 'data']).freeze
  private_constant :MOVE_ATTRIBUTES

  # All thread safety and session retrival proceedures should occur here.
  # Should return [session_id, session].
  # If nil is provided as the session id, generation of a new valid id
  # should occur within.
  def get_session(_env, session_id)
    session_id ||= generate_sid
    session = Session.find_by_session_id(session_id)
    session ||= Session.create(session_id: session_id)
    session_data = session.data || {}
    session_data.merge!(session.attributes.slice(*MOVE_ATTRIBUTES).select{ |_k,v| !v.nil? })
    [session.session_id, session_data]
  end

  # All thread safety and session storage proceedures should occur here.
  # Should return session_id
  def set_session(_env, session_id, session_data, _options)
    session = Session.find_by_session_id(session_id)
    session ||= Session.new(session_id: session_id)
    session.assign_attributes(session_data.slice(*MOVE_ATTRIBUTES).except{ |_k,v| v.nil? })
    session.data = session_data.except(*MOVE_ATTRIBUTES)
    session.save!
    session.session_id
  end

  # All thread safety and session destroy proceedures should occur here.
  # Should return a new session id or nil if options[:drop]
  def destroy_session(_env, session_id, options)
    Session.destroy_all(session_id: session_id)
    options[:drop] ? nil : generate_sid
  end

end
