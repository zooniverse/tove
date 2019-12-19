# TOVE: Transcription Object Viewer/Editor

## Development

Prepare the Docker containers:

```
docker-compose build
docker-compose run --rm app bundle exec rails db:setup
docker-compose run --rm -e RAILS_ENV=test app bin/rails db:create
```

Run tests with:

```
docker-compose run --rm -e RAILS_ENV=test app bundle exec rspec
```

Or interactively / manually in a docker shell

```
docker-compose run --rm -e RAILS_ENV=test app bash
# from the bash prompt
bin/rspec