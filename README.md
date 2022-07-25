# Rails Templates

Quickly generate a rails app with the default configuration using [Rails Templates](http://guides.rubyonrails.org/rails_application_templates.html).

Get a rails app ready with Doker config, Bootstrap, Simple form, debugging gems and initial setup project.

```bash
rails new \
  -j webpack \
  --skip-test \
  -m https://raw.githubusercontent.com/Hospimedia/rails-templates/main/config.rb \
  CHANGE_THIS_TO_YOUR_RAILS_APP_NAME
```

# Setup du projet
- config/database.yml >> changer le nom de la DB de test
- docker-compose.yml >> changer le nom du projet dans le fichier docker-compose.yml
- créer la DB dans phpMyAdmin avec le nom choisi dans le docker-compose
- Ajouter le nom de domain dans /etc/hosts
