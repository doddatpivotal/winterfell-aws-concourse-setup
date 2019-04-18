source scripts/bosh-env.sh

bosh -e bosh-concourse-aws delete-deployment -d concourse --non-interactive