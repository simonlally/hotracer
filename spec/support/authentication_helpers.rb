module AuthenticationHelpers
  def sign_in(user)
    allow(Current).to receive(:user).and_return(user)

    mock_session = { user_id: user.id }
    allow(Current).to receive(:session).and_return(mock_session)
  end
end
