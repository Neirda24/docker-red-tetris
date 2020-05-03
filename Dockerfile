FROM alpine/git as git

ARG SSH_PRIVATE_KEY
ARG CLONE_REPOSITORY="git@github.com:cepalle/red-tetris.git"

RUN apk add perl && \
    mkdir /root/.ssh/ && \
    echo "${SSH_PRIVATE_KEY}" > /root/.ssh/id_rsa && \
    chmod 600 /root/.ssh/id_rsa && \
    touch /root/.ssh/known_hosts && \
    ssh-keyscan $(echo "${CLONE_REPOSITORY:?}" | perl -pe 's#^[^@]*@([^:]*):.*$#$1#') >> /root/.ssh/known_hosts

WORKDIR /

RUN git clone --single-branch ${CLONE_REPOSITORY:?} /project

# -----------------
# Base node
# -----------------
FROM node:13 as base_node

USER node

WORKDIR /home/node

# -----------------
# Build assets
# -----------------
FROM base_node as build

COPY --from=git --chown=node:node /project ./

ARG PUBLIC_URL

RUN npm install

RUN cat ./src/client/redux/reducer.ts | \
        perl -pe "s#(const\sSOCKET_URL\s*=\s*')[^']*('.*;)#\$1${PUBLIC_URL:?}\$2#" \
    > temp.ts

RUN mv ./temp.ts ./src/client/redux/reducer.ts

# -----------------
# Tetris APP
# -----------------
FROM base_node as app

COPY --from=build --chown=node:node /home/node ./

VOLUME ./
