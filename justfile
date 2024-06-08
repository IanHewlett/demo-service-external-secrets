#!/usr/bin/env just --justfile

@_default:
  just --list

get-vars instance:
  @vault kv get -format=json -namespace=admin secret/svc/env-values/{{instance}} | jq -r '.data.data."{{instance}}"' | yq -p json -o yaml > inputs.yaml

test-spec instance: (get-vars instance)
  inspec exec spec --tags=spec --input-file inputs.yaml

ready-check-crds:
  #!/usr/bin/env bash
  set -eo pipefail

  app="vault-admin"
  namespace="kube-system"
  until [[ $(kubectl get clustersecretstores.external-secrets.io "$app" -n "$namespace" -o jsonpath="{.status.conditions[?(@.type=='Ready')]}" | jq -r .status) == "True" ]]
  do
    echo $app not ready
    sleep 10
  done
  echo "$app reconciled"

  app="registry-credential"
  until [[ $(kubectl get externalsecrets.external-secrets.io "$app" -n "$namespace" -o jsonpath="{.status.conditions[?(@.type=='Ready')]}" | jq -r .status) == "True" ]]
  do
    echo $app not ready
    sleep 10
  done
  echo "$app reconciled"
