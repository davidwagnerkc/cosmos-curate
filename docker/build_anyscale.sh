TAG=${1:-2}
REPO_ROOT=$HOME/git/cosmos-curate
PROJECT_ID=troubleshootingorg-gcp-pub
REGION=us-central1
REPO=wagner-docker
IMAGE=anyscale-cosmos-curate

docker build \
  --ulimit nofile=65536 \
  --progress=auto \
  --network=host \
  -f $REPO_ROOT/docker/anyscale.Dockerfile \
  -t anyscale-cosmos-curate:$TAG \
  -t anyscale-cosmos-curate:latest \
  $REPO_ROOT

SRC=${IMAGE}:${TAG}
DST_BASE=${REGION}-docker.pkg.dev/${PROJECT_ID}/${REPO}/${IMAGE}
docker tag ${SRC} ${DST_BASE}:${TAG}
docker push ${DST_BASE}:${TAG}
docker tag ${SRC} ${DST_BASE}:latest
docker push ${DST_BASE}:latest
