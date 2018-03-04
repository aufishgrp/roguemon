# Deployman
---
## Config options
All configuration options are specified as environment variables. 

### APP_NAME
The name of the application. Defaults the basename of the working directory.

### DOCKER_DOMAIN
The user/group that owns the dockerhub account.

### DOCKER_USERNAME
The user with access to the dockerhub account.

### DOCKER_PASSWORD
The docker usesrs password.

### GITHUB_DOMAIN
The user/group that owns the github account for this app.

### GITHUB_KEY
The github key to use when publishing tags to github.

### DEPLOYMAN_COMMIT_TAG
Prefix to use when making automated commits. Commits that contain with this value are excluded when determining the app version. Highly reccomended that this value not change once set. Defaults to the contents of _deployman/etc/travis-tag.
