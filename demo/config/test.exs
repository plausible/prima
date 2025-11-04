import Config

config :demo, DemoWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "/qGx+vs80toFVnnA2ZjkIuFNfeiDRPRGVR/QA2yVZ8vteEpXhkJUWiCRhLFzHw38",
  server: true

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

config :wallaby, js_logger: nil
