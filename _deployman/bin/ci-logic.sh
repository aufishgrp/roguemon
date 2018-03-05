#!/usr/bin/env bash

DEPLOYMAN_COMMIT_TAG=${DEPLOYMAN_COMMIT_TAG:-"`cat _deployman/etc/commit-tag`"}

APP_VERSION=`_deployman/bin/commands.sh app-version`
LAST_VERSION=`git describe --tags --abbrev=0`

if [ "`git rev-list ${APP_VERSION} 2>/dev/null`" ]; then
    NEW_VERSION="false"
else
    NEW_VERSION="true"
fi

echo "Version history ${LAST_VERSION} | ${APP_VERSION} | ${NEW_VERSION}"

function create_release_notes(){
  RELEASE_NOTES=`git log ${LAST_VERSION}.. --pretty=format:"<li><a href='http://github.com/${GITHUB_DOMAIN}/${APP_NAME}/commit/%H'>view commit &bull;</a>%s</li>" --reverse --no-merges -i --invert-grep --grep="${DEPLOYMAN_COMMIT_TAG}"`
}

function create_release_notes_json(){
  create_release_notes
  RELEASE_NOTES_JSON="{\"tag_name\":\"${APP_VERSION}\", \"name\":\"${APP_VERSION}\", \"target_commitish\":\"master\", \"draft\":false, \"prerelease\":false, \"body\":\"${RELEASE_NOTES}\"}"
}

function create_tag(){
  echo "Creating release ${APP_VERSION}"

  create_release_notes_json
  echo ${RELEASE_NOTES_JSON} | http POST https://api.github.com/repos/${GITHUB_DOMAIN}/${APP_NAME}/releases Authorization:"token ${GITHUB_KEY}"
  if [ $? -ne 0 ]; then
    exit 1
  fi
}

function reconcile_dev(){
    # When reconciling we need to
    #   1: Update the version file.
    #   2: Commit the result to master and update dev with master
    #   3: Push
    git remote add ci-build https://${GITHUB_KEY}@github.com/${GITHUB_DOMAIN}/${APP_NAME}.git > /dev/null 2>&1 && \
    git checkout master && \
    git pull && \
    echo ${APP_VERSION} > APP_VERSION && \
    git add APP_VERSION && \
    git commit -m "${DEPLOYMAN_COMMIT_TAG} - Update version" && \
    git push --quiet --set-upstream ci-build master && \
    git pull && \
    git checkout dev && \
    git pull && \
    git merge master && \
    git push --quiet --set-upstream ci-build dev && \
    git checkout master

    if [ $? -ne 0 ]; then
      exit 1
    fi
}

if [ "${TRAVIS_PULL_REQUEST}" == "false" ]; then
  ## Always publish
  
  make publish
  if [ $? -ne 0 ]; then
    echo "Failed to publish"
    exit 1
  fi

  if [ "${TRAVIS_BRANCH}" == "master" ]; then
    if [ "${NEW_VERSION}" == "true" ]; then
      # When the branch is master and the version has changed we need to
      #   1: Reconcile master with dev
      #   2: Create a new release tag
      reconcile_dev && create_tag
    else
      echo "Version unchanged: No publication actions taken."
    fi
  elif [ "${DEPLOYMAN_COMMIT_TAG}" ]; then
    # When a tag is detected then we've successfully built master as a new version and
    # published the resulting code blob. Run make deploy to trigger a deployment.
    make deploy
  fi
else
  echo "Pull request: No ci actions taken."
fi
