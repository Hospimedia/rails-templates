run "if uname | grep -q 'Darwin'; then pgrep spring | xargs kill -9; fi"

# Gemfile
########################################
inject_into_file "Gemfile", before: "group :development, :test do" do
  <<~RUBY
    gem "autoprefixer-rails"
    gem 'rack-cors', '~> 1.1', '>= 1.1.1'
    gem 'faraday', '~> 2.3'
    gem "font-awesome-sass", "~> 6.1"
    gem "simple_form", github: "heartcombo/simple_form"
    gem 'bootstrap', '~> 5.1.3'

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

gem_group :test do
  gem "capybara"
  gem "selenium-webdriver"
  gem "webdrivers"
end

gsub_file("Gemfile", '# gem "sassc-rails"', 'gem "sassc-rails"')

# Configs
########################################
environment "config.sass.inline_source_maps = true", env: 'development'
run "rm -r tmp/cache/assets"

configs = <<~RUBY
  config.i18n.load_path += Dir[Rails.root.join('config', 'locales', '**', '*.{rb,yml}')]
  config.i18n.default_locale = :fr
  config.time_zone = "Paris"
  config.active_record.default_timezone = :local

RUBY

environment configs

# Generators
########################################
generators = <<~RUBY
  config.generators do |generate|
    generate.assets false
    generate.helper false
    generate.test_framework :rspec, fixture: false
  end

RUBY

environment generators

run "curl -L https://raw.githubusercontent.com/Hospimedia/rails-templates/main/config/fr.yml > config/locales/fr.yml"

# Doker
########################################
custom_db_name = ask("What do you want to call the db ?")
custom_domain_name = ask("What do you want to call the domain ?")

run "curl -L https://raw.githubusercontent.com/Hospimedia/rails-templates/main/config/database.yml > config/database.yml"
run "curl -L https://raw.githubusercontent.com/Hospimedia/rails-templates/main/docker/Dockerfile > Dockerfile"
run "curl -L https://raw.githubusercontent.com/Hospimedia/rails-templates/main/docker/docker-compose.dev.yml > docker-compose.dev.yml"
run "curl -L https://raw.githubusercontent.com/Hospimedia/rails-templates/main/docker/docker-compose.yml > docker-compose.yml"
run "curl -L https://raw.githubusercontent.com/Hospimedia/rails-templates/main/docker/start-app.sh > start-app.sh"
run "curl -L https://raw.githubusercontent.com/Hospimedia/rails-templates/main/docker/dev.sh > dev.sh"

gsub_file("config/database.yml", "CHANGE_DB_NAME", custom_db_name)
gsub_file("docker-compose.yml", "CHANGE_DB_NAME", custom_db_name)
gsub_file("docker-compose.yml", "CHANGE_DOMAIN_NAME", custom_domain_name)

run "chmod 775 dev.sh start-app.sh"

inject_into_file "config/puma.rb", before: 'port ENV.fetch("PORT") { 3000 }' do
  <<~RUBY
    set_default_host '0.0.0.0'
  RUBY
end

environment "config.hosts << '#{custom_domain_name}.dave'", env: "development"

run "sudo nano /etc/hosts" if yes?("Add now domain name in your /etc/hosts ? (You need to add : #{custom_domain_name}.dave) Yes/No ?")

# Assets
########################################
run "rm -rf app/assets/stylesheets"
run "rm -rf vendor"

file "app/assets/stylesheets/application.scss", <<~TXT
  // Graphical variables
  @import "config/fonts";
  @import "config/colors";
  @import "config/bootstrap_variables";

  // External libraries
  @import "bootstrap";
  @import "font-awesome";

  // Your CSS partials
  @import "components/index";
TXT

file "app/assets/stylesheets/components/_index.scss", <<~TXT
  // Import your components CSS files here.
  @import "form_legend_clear";
TXT

file "app/assets/stylesheets/components/_form_legend_clear.scss", <<~TXT
  // In bootstrap 5 legend floats left and requires the following element
  // to be cleared. In a radio button or checkbox group the element after
  // the legend will be the automatically generated hidden input; the fix
  // in https://github.com/twbs/bootstrap/pull/30345 applies to the hidden
  // input and has no visual effect. Here we try to fix matters by
  // applying the clear to the div wrapping the first following radio button
  // or checkbox.
  legend ~ div.form-check:first-of-type {
    clear: left;
  }
TXT

file "app/assets/stylesheets/config/_fonts.scss", <<~TXT
  // Import Google fonts
  @import url('https://fonts.googleapis.com/css?family=Nunito:400,700|Work+Sans:400,700&display=swap');

  // Define fonts for body and headers
  $body-font: "Work Sans", "Helvetica", "sans-serif";
  $headers-font: "Nunito", "Helvetica", "sans-serif";

  // To use a font file (.woff) uncomment following lines
  // @font-face {
  //   font-family: "Font Name";
  //   src: font-url('FontFile.eot');
  //   src: font-url('FontFile.eot?#iefix') format('embedded-opentype'),
  //        font-url('FontFile.woff') format('woff'),
  //        font-url('FontFile.ttf') format('truetype')
  // }
  // $my-font: "Font Name";
TXT

file "app/assets/stylesheets/config/_colors.scss", <<~TXT
  // Define variables for your color scheme

  // For example:
  $red: #FD1015;
  $blue: #0D6EFD;
  $yellow: #FFC65A;
  $orange: #E67E22;
  $green: #1EDD88;
  $gray: #0E0000;
  $light-gray: #F4F4F4;
TXT

file "app/assets/stylesheets/config/_bootstrap_variables.scss", <<~TXT
  // This is where you override default Bootstrap variables
  // 1. All Bootstrap variables are here => https://github.com/twbs/bootstrap/blob/master/scss/_variables.scss
  // 2. These variables are defined with default value (see https://robots.thoughtbot.com/sass-default)
  // 3. You can override them below!

  // General style
  $font-family-sans-serif:  $body-font;
  $headings-font-family:    $headers-font;
  $body-bg:                 $light-gray;
  $font-size-base: 1rem;

  // Colors
  $body-color: $gray;
  $primary:    $blue;
  $success:    $green;
  $info:       $yellow;
  $danger:     $red;
  $warning:    $orange;

  // Buttons & inputs' radius
  $border-radius:    2px;
  $border-radius-lg: 2px;
  $border-radius-sm: 2px;

  // Override other variables below!
TXT

inject_into_file "config/initializers/assets.rb", after: "# Rails.application.config.assets.paths << Emoji.images_path" do
  <<~RUBY

    Rails.application.config.assets.paths << Rails.root.join("node_modules")
  RUBY
end

inject_into_file "config/initializers/assets.rb", after: "# Rails.application.config.assets.precompile += %w( admin.js admin.css )" do
  <<~RUBY

    Rails.application.config.assets.precompile += %w( application.scss )
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
  # Gitignore
  ########################################
  append_file ".gitignore", <<~TXT

    /public/assets
    .byebug_history
    /public/packs
    /public/packs-test
    /node_modules
    /yarn-error.log
    yarn-debug.log*
    .yarn-integrity

    # Ignore file containing credentials.
    docker-compose.dev.yml

    # Ignore Mac and Linux file system files
    *.swp
    .DS_Store
  TXT
  
  # Launch Container
  ########################################
  run "./dev.sh up --build"
  run "./dev.sh bundle install"

  # Simple Form
  ########################################
  run "./dev.sh bundle exec rails g simple_form:install --bootstrap"
  run "curl -L https://raw.githubusercontent.com/Hospimedia/rails-templates/main/config/simple_form.fr.yml > config/locales/simple_form.fr.yml"

  # Testing
  ########################################
  run "./dev.sh bundle exec rails g rspec:install"
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

  # Bootstrap / Popper
  ########################################
  append_file "config/importmap.rb", <<~RUBY
    pin "bootstrap", to: "https://ga.jspm.io/npm:bootstrap@5.1.3/dist/js/bootstrap.esm.js"
    pin "@popperjs/core", to: "https://ga.jspm.io/npm:@popperjs/core@2.11.2/lib/index.js"
  RUBY

  append_file "app/javascript/application.js", <<~JS
    import "bootstrap"
  JS

  # Git
  ########################################
  git :init
  git add: "."
  git commit: "-m 'Initial commit with template from https://github.com/Hospimedia/rails-templates'"
end
