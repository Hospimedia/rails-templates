run "if uname | grep -q 'Darwin'; then pgrep spring | xargs kill -9; fi"

# Gemfile
########################################
inject_into_file "Gemfile", before: "group :development, :test do" do
  <<~RUBY
    gem "autoprefixer-rails"
    gem "font-awesome-sass", "~> 6.1"
    gem "simple_form", github: "heartcombo/simple_form"
    gem 'mysql2', '~> 0.5'
    gem 'rack-cors', '~> 1.1', '>= 1.1.1'
    gem 'rest-client', '~> 2.1.0'
  RUBY
end

inject_into_file "Gemfile", after: 'gem "debug", platforms: %i[ mri mingw x64_mingw ]' do
  <<-RUBY
    gem "rspec-rails"
    gem "factory_bot_rails"
    gem "faker"
  RUBY
end

gsub_file("Gemfile", '# gem "sassc-rails"', 'gem "sassc-rails"')

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

########################################
# After bundle
########################################
after_bundle do
  # Generators: db + simple form + pages controller
  ########################################
  rails_command "db:drop db:create db:migrate"
  generate("simple_form:install", "--bootstrap")
  generate("rspec:install")

  # Gitignore
  ########################################
  append_file ".gitignore", <<~TXT
    # Ignore file containing credentials.
    docker-compose.dev.yml

    # Ignore Mac and Linux file system files
    *.swp
    .DS_Store
  TXT

  # Yarn
  ########################################
  run "yarn add bootstrap @popperjs/core"
  append_file "app/javascript/application.js", <<~JS
    import "bootstrap"
  JS

  # Doker
  ########################################
  run "touch 'docker-compose.dev.yml'"
  
  # Testing
  ########################################
  run "mkdir 'spec/support'"
  run "touch 'spec/support/factory_bot.rb'"
  run "touch 'spec/support/chrome.rb'"
  
  append_file ".rspec", <<~TXT
    --format documentation
  TXT
  
  inject_into_file "spec/support/factory_bot.rb" do
    <<~RUBY
      RSpec.configure do |config|
        config.include FactoryBot::Syntax::Methods
      end
    RUBY
  end
  
   inject_into_file "spec/support/chrome.rb" do
    <<~RUBY
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
  end

  # Git
  ########################################
  git :init
  git add: "."
  git commit: "-m 'Initial commit with template from https://github.com/Hospimedia/rails-templates'"
end
