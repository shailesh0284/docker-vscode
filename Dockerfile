# Set default values for build arguments
ARG NODE_VERSION=18.16.0
ARG ALPINE_VERSION=3.17.2

# Build Node.js stage
FROM node:${NODE_VERSION}-alpine AS node

# Build final image with Alpine Linux
FROM alpine:${ALPINE_VERSION}

# Copy Node.js binaries from the build stage
COPY --from=node /usr/lib /usr/lib
COPY --from=node /usr/local/lib /usr/local/lib
COPY --from=node /usr/local/include /usr/local/include
COPY --from=node /usr/local/bin /usr/local/bin

# Verify Node.js version
RUN node -v

# Install Yarn
RUN npm install -g yarn --force

# Install Git
RUN apk --no-cache add git

# Install Python and required dependencies
RUN apk --no-cache add build-base g++ libx11-dev libxkbfile-dev libsecret-dev krb5-dev python3

# Install fakeroot and rpm
RUN apk --no-cache add fakeroot rpm

# Clean up caches
RUN rm -rf ~/.cache/node-gyp

# Set working directory
WORKDIR /vscode

# Clone the VSCode repository
RUN git clone https://github.com/shailesh0284/vscode.git .

# Use the --mount option to mount the yarn cache with read-write permissions
RUN sh -c "yarn install"

EXPOSE 9888

# Use /bin/sh (Almquist shell) option
# CMD ["/bin/sh", "./scripts/code-server.sh", "--launch"]

# Alternatively, if you want to use Bash, uncomment the lines below:
# Install Bash
RUN apk add --no-cache bash

# Run VSCode build with Bash
CMD ["./scripts/code-server.sh", "--launch"]
