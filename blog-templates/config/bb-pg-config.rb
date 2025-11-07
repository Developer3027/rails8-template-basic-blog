# YAML file to setup pg database

create_file 'config/database.yml', <<~YAML
  # PostgreSQL version 9.3 and up supported.
  #   gem install pg
  # Using default username and password for local development instead of system roles.
  # TCP port defaults to 5432.
  # If your server runs on a different port number, change accordingly.
  # port: 5432
  # Minimum log levels, in increasing order:
  #   debug5, debug4, debug3, debug2, debug1,
  #   log, notice, warning, error, fatal, and panic
  # Defaults to warning.
  #min_messages: notice

  # Warning: The database defined as "test" will be erased and
  # re-generated from your development database when you run "rake".
  # Do not set this db to the same as development or production.
  default: &default
    adapter: postgresql
    encoding: unicode
    pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
    username: postgres
    password: postgres
    host: localhost

  development:
    <<: *default
    database: #{app_name}_development

  test:
    <<: *default
    database: #{app_name}_test

  production:
    primary: &primary_production
      <<: *default
      url: <%= ENV["DATABASE_URL"] %>

    cache:
      <<: *primary_production
      database: milk_lab_production_cache
      migrations_paths: db/cache_migrate

    queue:
      <<: *primary_production
      database: milk_lab_production_queue
      migrations_paths: db/queue_migrate

    cable:
      <<: *primary_production
      database: milk_lab_production_cable
      migrations_paths: db/cable_migrate
YAML
