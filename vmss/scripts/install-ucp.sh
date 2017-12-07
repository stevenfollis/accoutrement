# Install UCP
docker run \
  --rm \
  --name ucp \
  -v /var/run/docker.sock:/var/run/docker.sock \
  docker/ucp:latest install \
  --admin-username "admin" \
  --admin-password "Docker123!" \
  --san ucp.ishmael.in dtr.ishmael.in apps.ishmael.in

# Store join tokens
MANAGER_TOKEN=$(docker swarm join-token manager -q)
WORKER_TOKEN=$(docker swarm join-token worker -q)
TOKENS="{\"tokens\": { \"manager\": \"$MANAGER_TOKEN\", \"worker\": \"$WORKER_TOKEN \" } }"

echo "Installed UCP"
echo "@@@"
echo $TOKENS
echo "@@@"