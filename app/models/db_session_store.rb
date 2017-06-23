class DbSessionStore < ActionDispatch::Session::AbstractStore
  # Attributes to be moved between the model and data hash

  # All thread safety and session retrival proceedures should occur here.
  # Should return [session_id, session].
  # If nil is provided as the session id, generation of a new valid id
  # should occur within.
  def get_session(_env, session_id)
    session_id ||= generate_sid
    session = Session.find_by_session_id(session_id)
    session ||= Session.create(session_id: session_id)
    session_data = session.data || {}
    # Copy attributes from session to session_data
    session_data['user_id'] = session.user_id if session.user_id?
    [session.session_id, session_data]
  end

  # All thread safety and session storage proceedures should occur here.
  # Should return session_id
  def set_session(_env, session_id, session_data, _options)
    session = Session.find_by_session_id(session_id)
    session ||= Session.new(session_id: session_id)
    # Move attributes from session_data to session
    user_id = session_data.delete('user_id')
    session.user_id = user_id.nil? ? nil : user_id.to_i
    session.data = session_data
    # Save session to DB and return
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
