bosh alias-env bosh-concourse-aws -e $(terraform output -state=terraforming-concourse/terraform.tfstate bosh_ip) --ca-cert <(bosh int generated/bosh/creds.yml --path /director_ssl/ca)

export BOSH_CLIENT=admin
export BOSH_CLIENT_SECRET=`bosh int generated/bosh/creds.yml --path /admin_password`
