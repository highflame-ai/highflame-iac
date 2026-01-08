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
export HIGHFLAME_NAMESPACE="javelin-dev"
export HIGHFLAME_GENERIC_VER="1.0.1"
export HIGHFLAME_REDTEAM_VER="1.0.1"
export HIGHFLAME_INGRESS_VER="1.0.0"
```

* Service level setup and deployment

    * `highflame-admin`

        ```bash
        kubectl --namespace ${HIGHFLAME_NAMESPACE} create secret generic highflame-admin-license --from-file=license.jwt --from-file=public.pem
        kubectl --namespace ${HIGHFLAME_NAMESPACE} create secret generic highflame-admin-redis-cert --from-file=redis-ca.pem # optional

        helm upgrade --install highflame-admin highflame-charts/highflame-generic \
            --namespace ${HIGHFLAME_NAMESPACE} \
            --version ${HIGHFLAME_GENERIC_VER} \
            -f highflame-admin-helm-values-tmpl.yml --timeout=15m

        kubectl --namespace ${HIGHFLAME_NAMESPACE} get deployment highflame-admin
        ```

    * `highflame-core`

        ```bash
        kubectl --namespace ${HIGHFLAME_NAMESPACE} create secret generic highflame-core-file --from-file=gcp-credential.json
        kubectl --namespace ${HIGHFLAME_NAMESPACE} create secret generic highflame-core-redis-cert --from-file=redis-ca.pem # optional

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

    * `highflame-flag`

        ```bash
        kubectl --namespace ${HIGHFLAME_NAMESPACE} create secret generic highflame-flag-file --from-file=goff.yaml

        helm upgrade --install highflame-flag highflame-charts/highflame-generic \
            --namespace ${HIGHFLAME_NAMESPACE} \
            --version ${HIGHFLAME_GENERIC_VER} \
            -f highflame-flag-helm-values-tmpl.yml --timeout=15m

        kubectl --namespace ${HIGHFLAME_NAMESPACE} get deployment highflame-flag
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

    * `highflame-guard`

        ```bash
        helm upgrade --install highflame-guard highflame-charts/highflame-generic \
            --namespace ${HIGHFLAME_NAMESPACE} \
            --version ${HIGHFLAME_GENERIC_VER} \
            -f highflame-guard-helm-values-tmpl.yml --timeout=15m

        kubectl --namespace ${HIGHFLAME_NAMESPACE} get deployment highflame-guard
        ```

    * `highflame-guard-lang`

        ```bash
        helm upgrade --install highflame-guard-lang highflame-charts/highflame-generic \
            --namespace ${HIGHFLAME_NAMESPACE} \
            --version ${HIGHFLAME_GENERIC_VER} \
            -f highflame-guard-lang-helm-values-tmpl.yml --timeout=15m

        kubectl --namespace ${HIGHFLAME_NAMESPACE} get deployment highflame-guard-lang
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
        kubectl --namespace ${HIGHFLAME_NAMESPACE} create secret generic highflame-redteam-redis-cert --from-file=redis-ca.pem # optional

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