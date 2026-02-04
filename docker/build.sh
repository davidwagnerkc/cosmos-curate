REPO_ROOT=$HOME/git/cosmos-curate
docker build \
  --ulimit nofile=65536 \
  --progress=auto \
  --network=host \
  -f $REPO_ROOT/docker/cosmos-curate.Dockerfile \
  -t cosmos-curate:1.0.0 \
  $REPO_ROOT
