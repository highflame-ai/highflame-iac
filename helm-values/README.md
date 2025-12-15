# Javelin Helm charts Values file

This folder contains the Helm charts values files for different Kubernetes services.
You can refer to these files and patch them with your customizations.

## Steps to install the Javelin Charts

* Update the helm values for respective microservices

* Add Javelin repo to local

```bash
helm repo add javelin-charts "https://highflame-ai.github.io/charts
helm repo update
helm search repo javelin-charts
```

* Set the default variables such as charts version and namespace

```bash
export JAVELIN_NAMESPACE="javelin-dev"
export JAVELIN_GENERIC_VER="1.0.6"
export JAVELIN_REDTEAM_VER="1.0.24"
export JAVELIN_INGRESS_VER="1.0.22"
```

* Service level setup and deployment

    * `javelin-admin`

        ```bash
        kubectl --namespace ${JAVELIN_NAMESPACE} create secret generic javelin-admin-license --from-file=license.jwt --from-file=public.pem
        kubectl --namespace ${JAVELIN_NAMESPACE} create secret generic javelin-admin-redis-cert --from-file=redis-ca.pem # optional

        helm upgrade --install javelin-admin javelin-charts/javelin-generic \
            --namespace ${JAVELIN_NAMESPACE} \
            --version ${JAVELIN_GENERIC_VER} \
            -f javelin-admin-helm-values-tmpl.yml --timeout=15m

        kubectl --namespace ${JAVELIN_NAMESPACE} get deployment javelin-admin
        ```

    * `javelin-core`

        ```bash
        kubectl --namespace ${JAVELIN_NAMESPACE} create secret generic javelin-core-file --from-file=javelin-gcpjson.json
        kubectl --namespace ${JAVELIN_NAMESPACE} create secret generic javelin-core-redis-cert --from-file=redis-ca.pem # optional

        helm upgrade --install javelin-core javelin-charts/javelin-generic \
            --namespace ${JAVELIN_NAMESPACE} \
            --version ${JAVELIN_GENERIC_VER} \
            -f javelin-core-helm-values-tmpl.yml --timeout=15m

        kubectl --namespace ${JAVELIN_NAMESPACE} get deployment javelin-core
        ```

    * `javelin-dlp`

        ```bash
        helm upgrade --install javelin-dlp javelin-charts/javelin-generic \
            --namespace ${JAVELIN_NAMESPACE} \
            --version ${JAVELIN_GENERIC_VER} \
            -f javelin-dlp-helm-values-tmpl.yml --timeout=15m

        kubectl --namespace ${JAVELIN_NAMESPACE} get deployment javelin-dlp
        ```

    * `javelin-eval`

        ```bash
        helm upgrade --install javelin-eval javelin-charts/javelin-generic \
            --namespace ${JAVELIN_NAMESPACE} \
            --version ${JAVELIN_GENERIC_VER} \
            -f javelin-eval-helm-values-tmpl.yml --timeout=15m

        kubectl --namespace ${JAVELIN_NAMESPACE} get deployment javelin-eval
        ```

    * `javelin-flag`

        ```bash
        kubectl --namespace ${JAVELIN_NAMESPACE} create secret generic javelin-flag-file --from-file=javelin.goff.yaml

        helm upgrade --install javelin-flag javelin-charts/javelin-generic \
            --namespace ${JAVELIN_NAMESPACE} \
            --version ${JAVELIN_GENERIC_VER} \
            -f javelin-flag-helm-values-tmpl.yml --timeout=15m

        kubectl --namespace ${JAVELIN_NAMESPACE} get deployment javelin-flag
        ```

    * `javelin-guard`

        ```bash
        helm upgrade --install javelin-guard javelin-charts/javelin-generic \
            --namespace ${JAVELIN_NAMESPACE} \
            --version ${JAVELIN_GENERIC_VER} \
            -f javelin-guard-helm-values-tmpl.yml --timeout=15m

        kubectl --namespace ${JAVELIN_NAMESPACE} get deployment javelin-guard
        ```

    * `javelin-guard-cm`

        ```bash
        helm upgrade --install javelin-guard-cm javelin-charts/javelin-generic \
            --namespace ${JAVELIN_NAMESPACE} \
            --version ${JAVELIN_GENERIC_VER} \
            -f javelin-guard-cm-helm-values-tmpl.yml --timeout=15m

        kubectl --namespace ${JAVELIN_NAMESPACE} get deployment javelin-guard-cm
        ```

    * `javelin-guard-hallucination`

        ```bash
        helm upgrade --install javelin-guard-hallucination javelin-charts/javelin-generic \
            --namespace ${JAVELIN_NAMESPACE} \
            --version ${JAVELIN_GENERIC_VER} \
            -f javelin-guard-hallucination-helm-values-tmpl.yml --timeout=15m

        kubectl --namespace ${JAVELIN_NAMESPACE} get deployment javelin-guard-hallucination
        ```

    * `javelin-guard`

        ```bash
        helm upgrade --install javelin-guard javelin-charts/javelin-generic \
            --namespace ${JAVELIN_NAMESPACE} \
            --version ${JAVELIN_GENERIC_VER} \
            -f javelin-guard-helm-values-tmpl.yml --timeout=15m

        kubectl --namespace ${JAVELIN_NAMESPACE} get deployment javelin-guard
        ```

    * `javelin-guard-lang`

        ```bash
        helm upgrade --install javelin-guard-lang javelin-charts/javelin-generic \
            --namespace ${JAVELIN_NAMESPACE} \
            --version ${JAVELIN_GENERIC_VER} \
            -f javelin-guard-lang-helm-values-tmpl.yml --timeout=15m

        kubectl --namespace ${JAVELIN_NAMESPACE} get deployment javelin-guard-lang
        ```

    * `javelin-ramparts-server`

        ```bash
        helm upgrade --install javelin-ramparts-server javelin-charts/javelin-generic \
            --namespace ${JAVELIN_NAMESPACE} \
            --version ${JAVELIN_GENERIC_VER} \
            -f javelin-ramparts-server-helm-values-tmpl.yml --timeout=15m

        kubectl --namespace ${JAVELIN_NAMESPACE} get deployment javelin-ramparts-server
        ```

    * `javelin-redteam`

        ```bash
        kubectl --namespace ${JAVELIN_NAMESPACE} create secret generic javelin-redteam-redis-cert --from-file=redis-ca.pem # optional

        helm upgrade --install javelin-redteam javelin-charts/javelin-redteam \
            --namespace ${JAVELIN_NAMESPACE} \
            --version ${JAVELIN_REDTEAM_VER} \
            -f javelin-redteam-helm-values-tmpl.yml --timeout=15m

        kubectl --namespace ${JAVELIN_NAMESPACE} get deployment javelin-redteam
        ```

    * `javelin-redteam-lab1`

        ```bash
        helm upgrade --install javelin-redteam-lab1 javelin-charts/javelin-redteam \
            --namespace ${JAVELIN_NAMESPACE} \
            --version ${JAVELIN_REDTEAM_VER} \
            -f javelin-redteam-lab1-helm-values-tmpl.yml --timeout=15m

        kubectl --namespace ${JAVELIN_NAMESPACE} get deployment javelin-redteam-lab1
        ```

    * `javelin-scout`

        ```bash
        helm upgrade --install javelin-scout javelin-charts/javelin-generic \
            --namespace ${JAVELIN_NAMESPACE} \
            --version ${JAVELIN_GENERIC_VER} \
            -f javelin-scout-helm-values-tmpl.yml --timeout=15m

        kubectl --namespace ${JAVELIN_NAMESPACE} get daemonsets javelin-scout
        ```

    * `javelin-webapp`

        ```bash
        helm upgrade --install javelin-webapp javelin-charts/javelin-generic \
            --namespace ${JAVELIN_NAMESPACE} \
            --version ${JAVELIN_GENERIC_VER} \
            -f javelin-webapp-helm-values-tmpl.yml --timeout=15m

        kubectl --namespace ${JAVELIN_NAMESPACE} get deployment javelin-webapp
        ```