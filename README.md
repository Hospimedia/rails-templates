# Rails Templates

Quickly generate a rails app with the default configuration using [Rails Templates](http://guides.rubyonrails.org/rails_application_templates.html).

Get a rails app ready with Doker config, Bootstrap, Simple form, debugging gems and initial setup project.

```bash
rails new \
  --database mysql \
  --skip-test \
  -m https://raw.githubusercontent.com/Hospimedia/rails-templates/rails_7_template/config.rb \
  CHANGE_THIS_TO_YOUR_RAILS_APP_NAME
```
# Le template installe...
- la config Docker classique ainsi que le fichier docker-compose.dev.yml
- DB mysql ainsi que les points d'entrée dans phpMyAdmin en local
- Testing : Byebug, Rspec avec le setup factory_bot_rails & faker
- Gem : faraday (HTTP Client lib), font-awesome-sass, simple_form, rack-cors
- Config local i18n FR + Fuseau Horaire Paris
- Bootstrap
