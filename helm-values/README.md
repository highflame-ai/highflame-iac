# Highflame Helm charts Values file

This folder contains the Helm charts values files for different Kubernetes services.
You can refer to these files and patch them with your customizations.

## Steps to install the highflame Charts

* Update the helm values for respective microservices

* Add highflame chart repo to local

```bash
helm repo add highflame-charts "https://highflame-ai.github.io/charts
helm repo update
helm search repo highflame-charts
```

* Set the default variables such as charts version and namespace

```bash
export HIGHFLAME_NAMESPACE="highflame-dev"
export HIGHFLAME_GENERIC_VER="1.0.3"
export HIGHFLAME_REDTEAM_VER="1.0.5"
export HIGHFLAME_INGRESS_VER="1.0.0"
```

* Setting up the docker registry secret

```bash
kubectl --namespace ${HIGHFLAME_NAMESPACE} create secret \
  docker-registry highflame-registry-secret \
  --docker-server="ghcr.io" \
  --docker-username="username" \
  --docker-password="<<REGISTRY_SECRET_HERE>>" \
  --docker-email="username@example.com"
```

* Highflame service secrets

    * `Highflame license`

        ```bash
        kubectl --namespace ${HIGHFLAME_NAMESPACE} create secret \
            generic highflame-license \
            --from-file=license.jwt --from-file=public.pem \
            --dry-run=client -o yaml | kubectl apply -f -
        ```

    * `Redis cacert (optional)`

        ```bash
        kubectl --namespace ${HIGHFLAME_NAMESPACE} create secret \
            generic highflame-redis-cert \
            --from-file=redis-ca.pem \
            --dry-run=client -o yaml | kubectl apply -f -
        ```

    * `GCP credential`

        ```bash
        kubectl --namespace ${HIGHFLAME_NAMESPACE} create secret \
            generic highflame-gcp-cred \
            --from-file=gcp-credential.json \
            --dry-run=client -o yaml | kubectl apply -f -
        ```

    * `Feature flag config`

        ```bash
        kubectl --namespace ${HIGHFLAME_NAMESPACE} create secret \
            generic highflame-goff \
            --from-file=goff.yaml \
            --dry-run=client -o yaml | kubectl apply -f -
        ```

    * `Authz signing keys`

        ```bash
        kubectl --namespace ${HIGHFLAME_NAMESPACE} create secret \
            generic highflame-signing-keys \
            --from-file=./authz-signing-keys \
            --dry-run=client -o yaml | kubectl apply -f -
        ```

    * `JWT keys`

        ```bash
        kubectl --namespace ${HIGHFLAME_NAMESPACE} create secret \
            generic highflame-jwt-keys \
            --from-file=./jwt \
            --dry-run=client -o yaml | kubectl apply -f -
        ```

* Service level setup and deployment

    * `highflame-flag`

        ```bash
        helm upgrade --install highflame-flag highflame-charts/highflame-generic \
            --namespace ${HIGHFLAME_NAMESPACE} \
            --version ${HIGHFLAME_GENERIC_VER} \
            -f highflame-flag-helm-values-tmpl.yml --timeout=15m

        kubectl --namespace ${HIGHFLAME_NAMESPACE} get deployment highflame-flag
        ```

    * `highflame-admin`

        ```bash
        helm upgrade --install highflame-admin highflame-charts/highflame-generic \
            --namespace ${HIGHFLAME_NAMESPACE} \
            --version ${HIGHFLAME_GENERIC_VER} \
            -f highflame-admin-helm-values-tmpl.yml --timeout=15m

        kubectl --namespace ${HIGHFLAME_NAMESPACE} get deployment highflame-admin
        ```

    * `highflame-authz`

        ```bash
        helm upgrade --install highflame-authz highflame-charts/highflame-generic \
            --namespace ${HIGHFLAME_NAMESPACE} \
            --version ${HIGHFLAME_GENERIC_VER} \
            -f highflame-authz-helm-values-tmpl.yml --timeout=15m

        kubectl --namespace ${HIGHFLAME_NAMESPACE} get deployment highflame-authz
        ```

    * `highflame-core`

        ```bash
        helm upgrade --install highflame-core highflame-charts/highflame-generic \
            --namespace ${HIGHFLAME_NAMESPACE} \
            --version ${HIGHFLAME_GENERIC_VER} \
            -f highflame-core-helm-values-tmpl.yml --timeout=15m

        kubectl --namespace ${HIGHFLAME_NAMESPACE} get deployment highflame-core
        ```

    * `highflame-dlp`

        ```bash
        helm upgrade --install highflame-dlp highflame-charts/highflame-generic \
            --namespace ${HIGHFLAME_NAMESPACE} \
            --version ${HIGHFLAME_GENERIC_VER} \
            -f highflame-dlp-helm-values-tmpl.yml --timeout=15m

        kubectl --namespace ${HIGHFLAME_NAMESPACE} get deployment highflame-dlp
        ```

    * `highflame-eval`

        ```bash
        helm upgrade --install highflame-eval highflame-charts/highflame-generic \
            --namespace ${HIGHFLAME_NAMESPACE} \
            --version ${HIGHFLAME_GENERIC_VER} \
            -f highflame-eval-helm-values-tmpl.yml --timeout=15m

        kubectl --namespace ${HIGHFLAME_NAMESPACE} get deployment highflame-eval
        ```

    * `highflame-guard`

        ```bash
        helm upgrade --install highflame-guard highflame-charts/highflame-generic \
            --namespace ${HIGHFLAME_NAMESPACE} \
            --version ${HIGHFLAME_GENERIC_VER} \
            -f highflame-guard-helm-values-tmpl.yml --timeout=15m

        kubectl --namespace ${HIGHFLAME_NAMESPACE} get deployment highflame-guard
        ```

    * `highflame-guard-cm`

        ```bash
        helm upgrade --install highflame-guard-cm highflame-charts/highflame-generic \
            --namespace ${HIGHFLAME_NAMESPACE} \
            --version ${HIGHFLAME_GENERIC_VER} \
            -f highflame-guard-cm-helm-values-tmpl.yml --timeout=15m

        kubectl --namespace ${HIGHFLAME_NAMESPACE} get deployment highflame-guard-cm
        ```

    * `highflame-guard-hallucination`

        ```bash
        helm upgrade --install highflame-guard-hallucination highflame-charts/highflame-generic \
            --namespace ${HIGHFLAME_NAMESPACE} \
            --version ${HIGHFLAME_GENERIC_VER} \
            -f highflame-guard-hallucination-helm-values-tmpl.yml --timeout=15m

        kubectl --namespace ${HIGHFLAME_NAMESPACE} get deployment highflame-guard-hallucination
        ```

    * `highflame-guard-lang`

        ```bash
        helm upgrade --install highflame-guard-lang highflame-charts/highflame-generic \
            --namespace ${HIGHFLAME_NAMESPACE} \
            --version ${HIGHFLAME_GENERIC_VER} \
            -f highflame-guard-lang-helm-values-tmpl.yml --timeout=15m

        kubectl --namespace ${HIGHFLAME_NAMESPACE} get deployment highflame-guard-lang
        ```

    * `highflame-guard-deep`

        ```bash
        helm upgrade --install highflame-guard-deep highflame-charts/highflame-generic \
            --namespace ${HIGHFLAME_NAMESPACE} \
            --version ${HIGHFLAME_GENERIC_VER} \
            -f highflame-guard-deep-helm-values-tmpl.yml --timeout=15m

        kubectl --namespace ${HIGHFLAME_NAMESPACE} get deployment highflame-guard-deep
        ```

    * `highflame-ramparts-server`

        ```bash
        helm upgrade --install highflame-ramparts-server highflame-charts/highflame-generic \
            --namespace ${HIGHFLAME_NAMESPACE} \
            --version ${HIGHFLAME_GENERIC_VER} \
            -f highflame-ramparts-server-helm-values-tmpl.yml --timeout=15m

        kubectl --namespace ${HIGHFLAME_NAMESPACE} get deployment highflame-ramparts-server
        ```

    * `highflame-redteam`

        ```bash
        helm upgrade --install highflame-redteam highflame-charts/highflame-redteam \
            --namespace ${HIGHFLAME_NAMESPACE} \
            --version ${HIGHFLAME_REDTEAM_VER} \
            -f highflame-redteam-helm-values-tmpl.yml --timeout=15m

        kubectl --namespace ${HIGHFLAME_NAMESPACE} get deployment highflame-redteam
        ```

    * `highflame-redteam-lab1`

        ```bash
        helm upgrade --install highflame-redteam-lab1 highflame-charts/highflame-redteam \
            --namespace ${HIGHFLAME_NAMESPACE} \
            --version ${HIGHFLAME_REDTEAM_VER} \
            -f highflame-redteam-lab1-helm-values-tmpl.yml --timeout=15m

        kubectl --namespace ${HIGHFLAME_NAMESPACE} get deployment highflame-redteam-lab1
        ```

    * `highflame-scout`

        ```bash
        helm upgrade --install highflame-scout highflame-charts/highflame-generic \
            --namespace ${HIGHFLAME_NAMESPACE} \
            --version ${HIGHFLAME_GENERIC_VER} \
            -f highflame-scout-helm-values-tmpl.yml --timeout=15m

        kubectl --namespace ${HIGHFLAME_NAMESPACE} get daemonsets highflame-scout
        ```

    * `highflame-webapp`

        ```bash
        helm upgrade --install highflame-webapp highflame-charts/highflame-generic \
            --namespace ${HIGHFLAME_NAMESPACE} \
            --version ${HIGHFLAME_GENERIC_VER} \
            -f highflame-webapp-helm-values-tmpl.yml --timeout=15m

        kubectl --namespace ${HIGHFLAME_NAMESPACE} get deployment highflame-webapp
        ```

    * `highflame-shield`

        ```bash
        helm upgrade --install highflame-shield highflame-charts/highflame-generic \
            --namespace ${HIGHFLAME_NAMESPACE} \
            --version ${HIGHFLAME_GENERIC_VER} \
            -f highflame-shield-helm-values-tmpl.yml --timeout=15m

        kubectl --namespace ${HIGHFLAME_NAMESPACE} get deployment highflame-shield
        ```