# Cause an error if any spec causes a real web request
# This should both speed up tests and ensure that our tests cover all remote requests
FakeWeb.allow_net_connect = false

Before do
  FakeWeb.clean_registry # Clear the registery of intercepted URLs
end