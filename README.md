# Docker Setup for Hyrax Development

__NOT FOR PRODUCTION USE.__

This configuration should only be used for local development of a [Hyrax](https://github.com/samvera/hyrax) application.

## Requirements

[Docker Toolbox](https://www.docker.com/products/docker-toolbox) or [Docker for Mac](https://www.docker.com/docker-mac) or [Docker for Windows](https://www.docker.com/docker-windows)

## Containers

The compose file includes a `CAS` and `LDAP`. These containers are optional, to exclude just remove from the `docker-compose.yml` file.

If using LDAP you will want to configure users and groups before building the containers. See the files in the `docker/ldap/bootstrap/ldif` directory.

## Usage

To use this docker configuration just drop the contents of this repo in the
root directory of your Hyrax app.

Start a docker machine and run:

```
docker-compose up -d
```

The default is to run the rails server on port 3000 of the docker machine.

- Rails Server: [http://192.168.99.100:3000/]()
- Solr: [http://192.168.99.100:8983/solr/]()
- FCREPO: [http://192.168.99.100:8984/fcrepo/]()
- CAS: [http://192.168.99.100:8080/]()

## Hyrax Configuration

See the `default_config` directory for default config files.

Requires the `pg` gem. Add `gem 'pg'` to `Gemfile`.

Set the `fits_path` in `config/initializers/hyrax.rb`:

```rb
  # Path to the file characterization tool
  config.fits_path = '/opt/fits/fits.sh'
```

The `worker` container requires Sidekiq. Follow the Hyrax guide for [Using Sidekiq with Hyrax](https://github.com/samvera/hyrax/wiki/Using-Sidekiq-with-Hyrax). If containers are already running restart after adding sidekiq, `docker-compose restart`.

## Help

### Running Rails Commands

All rails commands should be run on the `web` container. This just requires prefixing the commands with `docker-compose run --rm web`. For example to run DB migrations you could do this:

```
docker-compose run --rm web bundle exec rake db:migrate
```

### Cleaning FCREPO, Solr, and DB

The following command clears all data, including downloaded gems.

```
docker-compose down -v
```

To ensure a faster startup after cleaning the data use the following commands, which do not delete the volume that stores the ruby gems. Note, you may need to replace the `hyrax_` volume prefix with the name of your project directory.

```
docker-compose down
docker volume rm hyrax_fcrepo hyrax_pgdata hyrax_solr hyrax_redis hyrax_fcrepo_db
```

### Running Tests

The `web` container provides an entry point for running tests:

```bash
# For All Tests
docker-compose run --rm web test

# For a Single Test File
docker-compose run --rm web test spec/models/work_spec.rb
```
