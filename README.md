# Configure

## Understand the variables

* `PUBLIC_URL`: Public URL of the exposed container
* `CLONE_REPOSITORY`: Repository ssh URL to clone
* `SSH_PRIVATE_KEY`: Content of the private key to use when cloning the repository (recommended to not set it here but using the export command. See below).

## Create the `.env` file

Either create a `.env` file with the following variables:
```.dotenv
PUBLIC_URL=http://localhost:44433/
CLONE_REPOSITORY=git@github.com:RocIT-tech/red-tetris.git
```

or copy the default one:
```bash
$ cp ./.env.dist ./.env
```

# Build

Simply run the following:

```bash
$ export SSH_PRIVATE_KEY=$(cat ~/.ssh/id_rsa)
$ docker-compose build
```

# Misc

## List all images that were built
*REQUIRES `jq`, `yq`*

```bash
# List all images built.
$ docker-compose config | yq . | jq --raw-output ".services | [. | to_entries[].value | select(.build != null) | .image] | unique | .[]"
```
