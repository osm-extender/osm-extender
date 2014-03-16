# Cause an error if any spec causes a real web request
# This should both speed up tests and ensure that our tests cover all remote requests
FakeWeb.allow_net_connect = false
FakeWeb.allow_net_connect = %r[^https://coveralls.io] # Allow coveralls to report coverage

Before do
  FakeWeb.clean_registry # Clear the registery of intercepted URLs
end
