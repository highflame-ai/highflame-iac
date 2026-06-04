## Module Specific Environment Variables

### highflame-admin

Variable Name | Variable Value | Default Value | Acceptable Value
--------------|--------------|--------------|--------------
`ACCOUNT_ID` | Account ID | nil | -
`DB_USERNAME` | Postgres username | nil | -
`DB_PASSWORD` | Postgres password | nil | -
`DB_HOST` | Postgres host | nil | -
`DB_NAME` | Postgres database | `javelin_data` | -
`REDIS_HOST` | Redis host | nil | -
`REDIS_PORT` | Redis port | `6379` | -
`REDIS_TLS` | Redis TLS | `false` | `true` or `false`
`REDIS_USER` | Redis username | nil | -
`REDIS_PASS` | Redis password | nil | -
`REDIS_CACERT` | Redis cacert | `""` | -
`AWS_KMS_KEY` | AWS KMS Key for secret manager enc | nil | optional
`AWS_SECRET_REPLICATION_REGION` | AWS replication region | nil | optional
`AWS_REPLICATION_KMS_KEY` | AWS KMS Key for secret manager enc in replication region | nil | optional
`HIGHFLAME_AUTH_PROVIDERS_CLERK_CONFIG_SECRET` | Clerk secret key | nil | -
`HIGHFLAME_AUTH_JWT_SECRET_KEY` | JWT Secret key | nil | -
`REDIS_CACERT` | Redis CA Cert | `""` | -
`K8S_NAMESPACE` | Kubernetes namespace | `Deployed K8s namespace` | -
`DB_PORT` | Postgres port | `5432` | -
`DB_SSL_MODE` | Postgres sslmode | `disable` | `disable` or `require`
`REDTEAM_DB_NAME` | Postgres database | `javelin_redteam` | -
`GUARDIAN_DB_NAME` | Guardian database | `highflame_guardian` | -
`HIGHFLAME_FF_URL` | highflame flag url | `http://highflame-flag:1031/` | -
`HIGHFLAME_REDTEAM_URL` | highflame redteam url | `http://highflame-redteam:8001/v1` | -
`HIGHFLAME_AUTHZ_URL` | highflame authz url | `http://highflame-authz:8050` | -
`HIGHFLAME_AUTHN_URL` | highflame authn url | `http://highflame-authn:8051` | -
`HIGHFLAME_SHIELD_URL` | highflame shield url | `http://highflame-shield:8070/v1/shield` | -
`HIGHFLAME_AUTH_JWT_PRIVATE_KEY` | JWT PEM RSA private key, signs RS256 access tokens | `/app/config/jwt/jwt-private.pem` | -
`HIGHFLAME_AUTH_JWT_PUBLIC_KEY` | JWT PEM RSA public key, verifies RS256 access tokens | `/app/config/jwt/jwt-public.pem` | -
`HIGHFLAME_TENANCY_DEFAULT_ORG_TIER` | Tenancy default org tier | `free` | `free` or `paid`
`HIGHFLAME_TENANCY_TIER_MANAGEMENT_ENABLED` | Tenancy default enabled | `true` | `true` or `false`
`HIGHFLAME_TENANCY_BOOTSTRAP_SUPER_ADMINS` | Tenancy bootstrap super admins | `""` | -
`HIGHFLAME_INTERNAL_SERVICE_SECRET` | Highflame Internal communication secret | nil | -
`MARKETPLACE_JWT_SECRET` | Highflame Marketplace secret | nil | -
`HIGHFLAME_APP_URL` | Endpoint for studio service | nil | -

### highflame-authn

Variable Name | Variable Value | Default Value | Acceptable Value
--------------|--------------|--------------|--------------
`DB_USERNAME` | Postgres username | nil | -
`DB_PASSWORD` | Postgres password | nil | -
`DB_HOST` | Postgres host | nil | -
`DB_PORT` | Postgres port | `5432` | -
`DB_SSL_MODE` | Postgres sslmode | `disable` | `disable` or `require`
`AUTHN_DB_NAME` | Postgres database | `highflame_authn` | -
`REDIS_HOST` | Redis host | nil | -
`REDIS_PORT` | Redis port | `6379` | -
`REDIS_TLS` | Redis TLS | `false` | `true` or `false`
`REDIS_USER` | Redis username | nil | -
`REDIS_PASS` | Redis password | nil | -
`REDIS_CACERT` | Redis cacert | `""` | -
`OTEL_ENABLED` | Enable OTEL | `true` | -
`OTEL_EXPORTER_OTLP_ENDPOINT` | OTEL endpoint | `http://highflame-collector:4317` | -
`HIGHFLAME_INTERNAL_SERVICE_SECRET` | Highflame Internal communication secret | nil | -
`HIGHFLAME_AUTH_JWT_SECRET_KEY` | JWT Secret key | nil | -
`HIGHFLAME_ISSUER` | Highflame issuer | nil | -
`HIGHFLAME_BASE_URL` | Highflame auth base endpoint | nil | -
`HIGHFLAMW_WIMSE_DOMAIN` | Highflame WIMSE domain name | nil | -
`HIGHFLAME_RSA_PRIVATE_KEY_PATH` | highflame rsa private key path | `/app/keys/jwt-private.pem` | -
`HIGHFLAME_TOKEN_ENCRYPTION_KEY` | Token encryption key | nil | -
`HIGHFLAME_WIMSE_DOMAIN` | Whitelisting the domain | nil | -

### highflame-authz

Variable Name | Variable Value | Default Value | Acceptable Value
--------------|--------------|--------------|--------------
`DB_USERNAME` | Postgres username | nil | -
`DB_PASSWORD` | Postgres password | nil | -
`DB_HOST` | Postgres host | nil | -
`DB_PORT` | Postgres port | `5432` | -
`DB_SSL_MODE` | Postgres sslmode | `disable` | `disable` or `require`
`AUTHZ_DB_NAME` | Postgres database | `javelin_data` | -
`HIGHFLAME_INTERNAL_SERVICE_SECRET` | Highflame Internal communication secret | nil | -

### highflame-cerberus

Variable Name | Variable Value | Default Value | Acceptable Value
--------------|--------------|--------------|--------------
`HIGHFLAME_ADMIN_URL` | Highflame Admin URL | `http://highflame-admin:8040`| -
`HIGHFLAME_SHEILD_URL` | Highflame Sheild URL | `http://highflame-shield:8070/v1/shield`| -
`HIGHFLAME_COLLECTOR_URL` | Highflame Collector URL | `highflame-collector:4317`| -
`HIGHFLAME_AUTH_JWT_PUBLIC_KEY` | Highflame JWTpublic key | `/app/config/jwt/jwt-public.pem` | -

### highflame-dlp

Variable Name | Variable Value | Default Value | Acceptable Value
--------------|--------------|--------------|--------------
`HAPROXY_CFG` | HAProxy config file path | `/app/haproxy.cfg` | -
`SVC_PORT` | Service serving port | `8009` | -
`CORS_ALLOWED_ORIGINS` | CORS allowed origins | `*` | -
`CORS_ALLOWED_METHODS` | CORS allowed methods | `POST,GET,OPTIONS` | -
`CORS_ALLOWED_HEADERS` | CORS allowed headers | `Authorization,Content-Type,x-api-key,x-javelin-user,x-javelin-userrole` | -

### highflame-firehog

Variable Name | Variable Value | Default Value | Acceptable Value
--------------|--------------|--------------|--------------
`HIGHFLAME_SHIELD_URL` | highflame shield url | `http://highflame-shield:8070/v1/shield` | -
`HIGHFLAME_ADMIN_URL` | highflame admin url | `http://highflame-admin:8040` | -
`HIGHFLAME_AUTHN_URL` | highflame authn url | `http://highflame-authn:8051` | -
`HIGHFLAME_JWT_ISSUER` | highflame jwt issuer | `highflame-admin` | -
`HIGHFLAME_FIREHOG_URL` | highflame firehog url | nil | -
`HIGHFLAME_INTERNAL_SERVICE_SECRET` | Highflame Internal communication secret | nil | -
`OAUTH_AUTHORIZATION_SERVER` | Highflame Authorization server URL | nil | -

### highflame-redteam

Variable Name | Variable Value | Default Value | Acceptable Value
--------------|--------------|--------------|--------------
`REDTEAM_SEEDER_DATASET` | Redteam seeder dataset name | nil | -
`REDTEAM_SEEDER_DATASET_VER` | Redteam seeder dataset version | nil | -
`REDTEAM_SEEDER_ARGS` | Redteam seeder command args | nil | `--force`
`HF_TOKEN` | HF token | nil | -
`OPENAI_API_KEY` | OpenAI api key | nil | conflict with variables `AZURE_*`
`DB_USERNAME` | Postgres username | nil | -
`DB_PASSWORD` | Postgres password | nil | -
`DB_HOST` | Postgres host | nil | -
`XAI_API_KEY` | Xai api key | nil | optional
`REDIS_CONN_STR` | Redis connection string | nil | -
`REDIS_CACERT` | Redis CA Cert | `""` | -
`REDIS_PROGRESS_TTL_SECONDS` | Redis progress TTL seconds | `86400` | -
`AZURE_API_KEY` | Azure OpenAI api key | nil | -
`AZURE_API_BASE` | Azure OpenAI API base | nil | -
`AZURE_API_VERSION` | Azure OpenAI version | `2024-02-15-preview` | -
`DB_PORT` | Postgres port | `5432` | -
`DB_SSL_MODE` | Postgres sslmode | `disable` | `disable` or `require`
`REDTEAM_DB_NAME` | Postgres database | `javelin_redteam` | -
`HIGHFLAME_ADMIN_URL` | Highflame admin url | `http://highflame-admin:8040` | -
`MODEL_HIGH_END` | Provider high model name | `gpt-4o` | -
`MODEL_LOW_END` | Provider low model name | `gpt35` | -
`EMBEDDING_MODEL` | Embedding model name | `text-embedding-3-small` | -
`GROK_MODEL` | Grok model name | `grok-2` | -
`ATTACK_GEN_MODEL` | Xai model name | `xai/grok-3` | -
`DEFAULT_PROVIDER` | Default provider | `openai` | `openai` or `bedrock` or `azure` or `local`
`OTEL_EXPORTER_OTLP_ENDPOINT` | Highflame collector URL | `highflame-collector:4317` | -
`OTEL_SERVICE_NAME` | Highflame collector service | `redteam-scanner` | -


### highflame-redteam-lab1

Variable Name | Variable Value | Default Value | Acceptable Value
--------------|--------------|--------------|--------------
`MODEL_NAME` | Provider model | nil | -
`LOCAL_MODEL_NAME` | Local Provider model | nil | -
`AZURE_API_KEY` | Azure OpenAI api key | nil | for `DEFAULT_PROVIDER=azure`
`AZURE_API_BASE` | Azure OpenAI API base | nil | for `DEFAULT_PROVIDER=azure`
`AZURE_API_VERSION` | Azure OpenAI version | nil | for `DEFAULT_PROVIDER=azure`
`BEDROCK_REGION` | Bedrock region | nil | for `DEFAULT_PROVIDER=bedrock`
`BEDROCK_BEARER_TOKEN` | Bedrock bearer token | nil | for `DEFAULT_PROVIDER=bedrock`
`BEDROCK_ACCESS_KEY` | Bedrock access key | nil | for `DEFAULT_PROVIDER=bedrock`
`BEDROCK_SECRET_KEY` | Bedrock secret key | nil | for `DEFAULT_PROVIDER=bedrock`
`OPENAI_API_KEY` | OpenAi api key | nil | for `DEFAULT_PROVIDER=openai`
`OPENAI_API_KEY_1` | OpenAi api key | nil | for `DEFAULT_PROVIDER=openai` and need rotational key for model access
`OPENAI_API_KEY_2` | OpenAi api key | nil | for `DEFAULT_PROVIDER=openai` and need rotational key for model access
`OPENAI_API_KEY_3` | OpenAi api key | nil | for `DEFAULT_PROVIDER=openai` and need rotational key for model access
`LOCAL_API_BASE` | Local API base | `http://highflame-chat-tester:8080` | for `DEFAULT_PROVIDER=local`
`LOCAL_API_KEY` | Local api key | nil | for `DEFAULT_PROVIDER=local`
`DEFAULT_PROVIDER` | Default provider | nil | `openai` or `bedrock` or `azure` or `local` 

### highflame-shield

Variable Name | Variable Value | Default Value | Acceptable Value
--------------|--------------|--------------|--------------
`ACCOUNT_ID` | Account ID | nil | -
`REDIS_HOST` | Redis host | nil | -
`REDIS_PORT` | Redis port | `6379` | -
`REDIS_TLS` | Redis TLS | `false` | `true` or `false`
`REDIS_USER` | Redis username | nil | -
`REDIS_PASS` | Redis password | nil | -
`REDIS_CACERT` | Redis cacert | `""` | -
`UNKEY_ROOT_KEY` | Unkey Root Key | nil | optional
`UNKEY_API_ID` | Unkey api id | nil | optional
`MODEL_ARMOR_TEMPLATE` | Model armor template | nil | -
`MODEL_ARMOR_LOCATION` | Model armor location | nil | -
`HIGHFLAME_INTERNAL_SERVICE_SECRET` | Highflame Internal communication secret | nil | -
`HIGHFLAME_AUTH_JWT_PUBLIC_KEY` | JWT PEM RSA public key, verifies RS256 access tokens | `/app/config/jwt/jwt-public.pem` | -
`CLOUD_ARCHIVE_TYPE` | Cloud archive type | nil | `s3` or `gcs` or `azure-blob`
`CLOUD_ARCHIVE_BUCKET` | Cloud archive bucket name | nil | optional
`REDIS_CACERT` | Redis CA Cert | `""` | -
`HIGHFLAME_DEPLOYMENT_TYPE` | Deploy type | `prod` | `dev` or `prod`
`K8S_NAMESPACE` | Kubernetes namespace | `Deployed K8s namespace` | `Deployed K8s namespace`
`HIGHFLAME_GCP_DLP_ENDPOINT` | highflame dlp url | `http://highflame-dlp:8888` | -
`HIGHFLAME_ADMIN_URL` | highflame admin url | `http://highflame-admin:8040` | -
`HIGHFLAME_AUTHZ_URL` | highflame authz url | `http://highflame-authz:8050` | -
`HIGHFLAME_DLP_URL` | highflame dlp url | `http://highflame-dlp:8888` | -
`HIGHFLAME_FF_URL` | highflame flag url | `http://highflame-flag:1031/` | -
`HIGHFLAME_GUARD_URL` | highflame guard url | `http://highflame-guard:8013` | -
`HIGHFLAME_GUARD_CM_URL` | highflame guard cm url | `http://highflame-guard-cm:8014` | -
`HIGHFLAME_GUARD_PII_URL` | highflame guard pii url | `http://highflame-guard-pii:8018` | -
`HIGHFLAME_GUARD_DEEPCONTEXT_URL` | highflame guard deepcontext url | `http://highflame-guard-deep:8022` | -
`HIGHFLAME_CHECKPHISH_BUCKET_NAME` | highflame checkphish bucket name | `javelin-saas-bloom-filter-store` | -
`HIGHFLAME_CHECKPHISH_OBJECT_NAME` | highflame checkphish object name | `bloom_filter_url.gob` | -
`REFRESH_SECRETS_ON_401` | Refresh secrets on 401 | `true` | `true` or `false`
`BYPASS_GUARDRAILS` | Bypass guardrails for streaming | `true` | `true` or `false`
`AUTO_PROVISION_APPLICATION` | Auto provision the application | `true` | `true` or `false`
`GOOGLE_CLOUD_PROJECT` | GCP project id | `javelin-saas` | -
`GOOGLE_APPLICATION_CREDENTIALS` | GCP json cred path | `/app/config/gcp-credential.json` | -
`ENABLE_SENTRY` | Sentry dsn | `false` | `true` or `false`
`SENTRY_DSN` | Sentry dsn | `""` | optional
`CLOUD_ARCHIVE_ENABLED` | Cloud archive enabled | `false` | `true` or `false`
`CLOUD_ARCHIVE_PREFIX` | Cloud archive prefix in the storage | `shield/sessions/` | optional
`AWS_ACCESS_KEY_ID` | AWS Access Key | `""` | for `CLOUD_ARCHIVE_TYPE=s3`
`AWS_SECRET_ACCESS_KEY` | AWS Secret Key | `""` | for `CLOUD_ARCHIVE_TYPE=s3`
`AWS_REGION` | AWS Region | `""` | for `AWS deployment`
`HIGHFLAME_SCAN_STORAGE_BUCKET`| Highflame scan s3 bucket name | nil | -
`HIGHFLAME_MODELS_SECRET` | Highflame model secret | nil | -
`HIGHFLAME_AUTH_JWT_ISSUER`| Highflame JWT Issuer | nil | -
`HIGHFLAME_AUTH_JWKS_URL` | Highflame JWKS URL | `http://highflame-authn:8051/.well-known/jwks.json` | -

### highflame-guard-*

Variable Name | Variable Value | Default Value | Acceptable Value
--------------|--------------|--------------|--------------
`HIGHFLAME_MODELS_SECRET` | Highflame model secret | nil | -
`HF_HUB_ENABLE_HF_TRANSFER` | Enable huggingface transfer | `1` | -

### highflame-studio

Variable Name | Variable Value | Default Value | Acceptable Value
--------------|--------------|--------------|--------------
`CLERK_SECRET_KEY` | Clerk secret key | nil | -
`NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY` | Clerk publishable key | nil | -
`CLERK_WEBHOOK_SECRET` | Clerk webhook secret | nil | -
`NEXT_PUBLIC_ADMIN_API_URL` | Next public admin api url | nil | -
`NEXT_PUBLIC_APP_URL` | Endpoint for studio service | nil | -
`NEXT_PUBLIC_FIREHOG_URL` | Endpoint for firehog service | nil | -
`NEXT_PUBLIC_CLERK_SIGN_IN_URL` | Clerk sign in url | `/sign-in` | -
`NEXT_PUBLIC_CLERK_SIGN_UP_URL` | Clerk sign up url | `/sign-up` | -
`NODE_ENV` | Nodejs env | `production` | `development` or `production`
`NEXT_TELEMETRY_DISABLED` | Telemetry option | `1` | `0` or `1`
`HIGHFLAME_ADMIN_URL` |  Admin api url | `http://highflame-admin:8040` | -
`HIGHFLAME_SHIELD_URL` |  shield api url | `http://highflame-shield:8070/v1/shield` | -
`HIGHFLAME_AUTHN_URL` |  authn api url | `http://highflame-authn:8051` | -
`HIGHFLAME_OBSERVATORY_URL` |  observatory api url | `http://highflame-observatory:8090` | -
`HIGHFLAME_REDTEAM_LAB_URL` |  redteam lab api url | `http://highflame-redteam-lab1:8002` | -
`HIGHFLAME_AUTH_JWT_SECRET_KEY` | JWT Secret key | nil | -
`HOSTNAME` | Service hostname | `0.0.0.0` | -
`PORT` | Service port | `3000` | -
`DEFAULT_PROVIDER` | Default provider | nil | `openai` or `bedrock` or `azure`
`OPENAI_API_KEY` | OpenAI api key | nil | for `DEFAULT_PROVIDER=openai`
`AZURE_API_KEY` | Azure OpenAI api key | nil | for `DEFAULT_PROVIDER=azure`
`AZURE_API_BASE` | Azure OpenAI API base | nil | for `DEFAULT_PROVIDER=azure`
`AZURE_API_VERSION` | Azure OpenAI version | nil | for `DEFAULT_PROVIDER=azure`
`SUPPORT_SMTP_PASSKEY` | SMTP Credential | nil | -
`MARKETPLACE_FROM_EMAIL` | SMTP from mail | nil | -
`MARKETPLACE_NOTIFY_EMAIL` | SMTP Notify mail | nil | -
`HIGHFLAME_JWT_ISSUER` | highflame jwt issuer | `highflame-admin` | -
`HIGHFLAME_RSA_PRIVATE_KEY_PATH` | highflame rsa private key path | `/app/keys/jwt-private.pem` | -
`HIGHFLAME_TOKEN_ENCRYPTION_KEY` | Token encryption key | nil | -
`NEXT_PUBLIC_POSTHOG_HOST` | Posthog host | `https://us.i.posthog.com` | -
`NEXT_PUBLIC_POSTHOG_KEY` | Posthog key | nil | -
`NEXT_PUBLIC_AUTHN_URL` | highflame authn endpoint | nil | -
`HIGHFLAME_INTERNAL_SERVICE_SECRET` | Highflame Internal service secrets | nil | -

### highflame-collector

Variable Name | Variable Value | Default Value | Acceptable Value
--------------|--------------|--------------|--------------
`CLICKHOUSE_ENDPOINT` | Clickhouse Endpoint | `tcp://clickhouse-javelin-ch.clickhouse.svc.cluster.local:9000` | -
`CLICKHOUSE_DATABASE` | Clickhouse Database | `highflame` | -
`CLICKHOUSE_USERNAME` | Clickhouse Username | nil | -
`CLICKHOUSE_PASSWORD` | Clickhouse Password | nil | -

### highflame-observatory

Variable Name | Variable Value | Default Value | Acceptable Value
--------------|--------------|--------------|--------------
`HIGHFLAME_AUTH_JWT_PUBLIC_KEY` | Highflame JWTpublic key | `/app/config/jwt/jwt-public.pem` | -
`CLICKHOUSE_HOST` | Clickhouse Host | `clickhouse-javelin-ch.clickhouse.svc.cluster.local` | -
`CLICKHOUSE_DATABASE` | Clickhouse Database | `highflame` | -
`CLICKHOUSE_USERNAME` | Clickhouse Username | nil | -
`CLICKHOUSE_PASSWORD` | Clickhouse Password | nil | -
`HIGHFLAME_INTERNAL_SERVICE_SECRET` | Highflame Internal service secrets | nil | -
`HIGHFLAME_AUTH_JWT_ISSUER`| Highflame JWT Issuer | nil | -
`HIGHFLAME_AUTH_JWKS_URL` | Highflame JWKS URL | `http://highflame-authn:8051/.well-known/jwks.json` | -
`HIGHFLAME_RECEIPT_AUTHN_JWKS_URL` | Highflame receipt authn JWKS URL | `http://highflame-authn:8051/v1/auth/.well-known/highflame-receipt-keys` | -