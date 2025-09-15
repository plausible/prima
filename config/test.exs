import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :prima, PrimaWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "/qGx+vs80toFVnnA2ZjkIuFNfeiDRPRGVR/QA2yVZ8vteEpXhkJUWiCRhLFzHw38",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

config :wallaby, js_logger: nil
