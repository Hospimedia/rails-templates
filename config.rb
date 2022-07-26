run "if uname | grep -q 'Darwin'; then pgrep spring | xargs kill -9; fi"

# Gemfile
########################################
inject_into_file "Gemfile", before: "group :development, :test do" do
  <<~RUBY
    gem "autoprefixer-rails"
    gem 'mysql2', '~> 0.5'
    gem 'rack-cors', '~> 1.1', '>= 1.1.1'
    gem 'faraday', '~> 0.9.2'
    gem "font-awesome-sass", "~> 6.1"
    gem "simple_form", github: "heartcombo/simple_form"

  RUBY
end

inject_into_file "Gemfile", after: 'gem "debug", platforms: %i[ mri mingw x64_mingw ]' do
<<-RUBY
    
  gem 'byebug', '~> 9.0', '>= 9.0.5'
  gem "rspec-rails"
  gem "factory_bot_rails"
  gem "faker"
RUBY
end

gsub_file("Gemfile", '# gem "sassc-rails"', 'gem "sassc-rails"')
gsub_file("Gemfile", 'gem "sqlite3", "~> 1.4"', '# gem "sqlite3", "~> 1.4"')

# Generators
########################################
generators = <<~RUBY
  config.generators do |generate|
    generate.assets false
    generate.helper false
    generate.test_framework :test_unit, fixture: false
  end
RUBY

environment generators

# Configs
########################################
# inject_into_file "config/application.rb", after: '# config.eager_load_paths << Rails.root.join("extras")' do
# <<~RUBY
#       config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]
#       config.i18n.default_locale = :fr
      
#       config.time_zone = "Paris"
#       config.active_record.default_timezone = :local
# RUBY
# end

configs = <<~RUBY
  config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]
  config.i18n.default_locale = :fr
  config.time_zone = "Paris"
  config.active_record.default_timezone = :local
RUBY

environment configs

run "curl -L https://raw.githubusercontent.com/Hospimedia/rails-templates/main/fr.yml > config/locales/fr.yml"

# Assets
########################################
inject_into_file "config/initializers/assets.rb", before: "# Precompile additional assets." do
  <<~RUBY
    Rails.application.config.assets.paths << Rails.root.join("node_modules")

  RUBY
end

# Layout
########################################
gsub_file(
  "app/views/layouts/application.html.erb",
  '<meta name="viewport" content="width=device-width,initial-scale=1">',
  '<meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">'
)

# README
########################################
markdown_file_content = <<~MARKDOWN
  Rails app generated with [hospimedia/rails-templates](https://github.com/Hospimedia/rails-templates)
MARKDOWN
file "README.md", markdown_file_content, force: true

########################################
# After bundle
########################################
after_bundle do
  # Doker
  ########################################
  custom_db_name = ask("What do you want to call the db ?")
  custom_domain_name = ask("What do you want to call the domain ?")

  run "curl -L https://raw.githubusercontent.com/Hospimedia/rails-templates/main/database.yml > config/database.yml"
  run "curl -L https://raw.githubusercontent.com/Hospimedia/rails-templates/main/Dockerfile > Dockerfile"
  run "curl -L https://raw.githubusercontent.com/Hospimedia/rails-templates/main/docker-compose.dev.yml > docker-compose.dev.yml"
  run "curl -L https://raw.githubusercontent.com/Hospimedia/rails-templates/main/docker-compose.yml > docker-compose.yml"
  run "curl -L https://raw.githubusercontent.com/Hospimedia/rails-templates/main/start-app.sh > start-app.sh"
  run "curl -L https://raw.githubusercontent.com/Hospimedia/rails-templates/main/dev.sh > dev.sh"

  gsub_file("config/database.yml", "CHANGE_DB_NAME", "#{custom_db_name}_test")
  gsub_file("docker-compose.yml", "traefik.backend=CHANGE_NAME", "traefik.backend=#{custom_db_name}")
  gsub_file("docker-compose.yml", "traefik.frontend.rule=Host:CHANGE_NAME.dave", "traefik.frontend.rule=Host:#{custom_domain_name}.dave")
  gsub_file("docker-compose.yml", "CHANGE_NAME_development", "#{custom_db_name}_development")

  run "chmod 775 dev.sh start-app.sh"

  inject_into_file "config/puma.rb", before: 'port ENV.fetch("PORT") { 3000 }' do
    <<~RUBY
      set_default_host '0.0.0.0'
    RUBY
  end

  inject_into_file "config/environments/development.rb", after: "# config.action_cable.disable_request_forgery_protection = true" do
    <<~RUBY

      config.hosts << "#{custom_domain_name}.dave"
    RUBY
  end

  run "sudo nano /etc/hosts" if yes?("Add now domain name in your /etc/hosts ? (You need add : #{custom_domain_name}.dave")

  # Gitignore
  ########################################
  append_file ".gitignore", <<~TXT

    # Ignore file containing credentials.
    docker-compose.dev.yml

    # Ignore Mac and Linux file system files
    *.swp
    .DS_Store
  TXT

  run "./dev.sh up --build"

  # Yarn
  ########################################
  run "./dev.sh bundle exec yarn add bootstrap @popperjs/core"
  append_file "app/javascript/application.js", <<~JS
    import "bootstrap"
  JS

  # Simple Form
  ########################################
  generate("simple_form:install", "--bootstrap")

  # Testing
  ########################################
  generate("rspec:install")
  run "mkdir 'spec/support'"
  run "touch 'spec/factories.rb'"
  
  append_file ".rspec", <<~TXT
    --format documentation
  TXT

  file "spec/support/factory_bot.rb", <<~RUBY
    RSpec.configure do |config|
      config.include FactoryBot::Syntax::Methods
    end
  RUBY

  file "spec/support/chrome.rb", <<~RUBY
    RSpec.configure do |config|
      config.before(:each, type: :system) do
        if ENV["SHOW_BROWSER"] == "true"
          driven_by :selenium_chrome
        else
          driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1400]
        end
      end
    end
  RUBY

  inject_into_file "spec/rails_helper.rb", after: "require 'spec_helper'" do
    <<-RUBY

      require_relative 'support/factory_bot'
      require_relative 'support/chrome'
    RUBY
  end

  # Git
  ########################################
  git :init
  git add: "."
  git commit: "-m 'Initial commit with template from https://github.com/Hospimedia/rails-templates'"
end
