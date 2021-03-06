# Usage: ./scripts/create-bosh.sh [access-key-id] [secret-access-key]
# Example: ./scripts/create-bosh.sh $ACCESS_KEY_ID $SECRET_ACCESS_KEY

rm ./generated/bosh/state.json
rm ./generated/bosh/creds.yml

bosh create-env ./local-cache/bosh-deployment/bosh.yml \
    --state=./generated/bosh/state.json \
    --vars-store=./generated/bosh/creds.yml \
    -o ./local-cache/bosh-deployment/aws/cpi.yml \
    -o ./local-cache/bosh-deployment/external-ip-with-registry-not-recommended.yml \
    -o ./local-cache/bosh-deployment/jumpbox-user.yml \
    -l vars/bosh-director-params.yml \
    -v access_key_id=$1 \
    -v secret_access_key=$2 \
    --var-file private_key=~/Downloads/bosh.pem \
