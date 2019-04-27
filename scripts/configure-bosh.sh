source scripts/bosh-env.sh

bosh -e bosh-concourse-aws log-in
bosh -e bosh-concourse-aws update-cloud-config bosh/cloud-config.yml -n