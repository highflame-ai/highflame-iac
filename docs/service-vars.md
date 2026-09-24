## Module Specific Environment Variables

### highflame-admin

Variable Name | Variable Value | Default Value | Acceptable Value
--------------|--------------|--------------|--------------
`DB_USERNAME` | Postgres username | nil | -
`DB_PASSWORD` | Postgres password | nil | -
`DB_HOST` | Postgres host | nil | -
`DB_NAME` | Postgres database | `highflame_data` | -
`DB_PORT` | Postgres port | `5432` | -
`DB_SSL_MODE` | Postgres sslmode | `disable` | `disable` or `require`
`AWS_KMS_KEY` | AWS KMS Key for secret manager enc | nil | optional
`AWS_SECRET_REPLICATION_REGION` | AWS replication region | nil | optional
`AWS_REPLICATION_KMS_KEY` | AWS KMS Key for secret manager enc in replication region | nil | optional
`K8S_NAMESPACE` | Kubernetes namespace | `Deployed K8s namespace` | -
`REDTEAM_DB_NAME` | Postgres database | `highflame_redteam` | -
`GUARDIAN_DB_NAME` | Guardian database | `highflame_guardian` | -
`HIGHFLAME_FF_URL` | highflame flag url | `http://highflame-flag:1031/` | -
`HIGHFLAME_REDTEAM_URL` | highflame redteam url | `http://highflame-redteam:8001/v1` | -
`HIGHFLAME_AUTHZ_URL` | highflame authz url | `http://highflame-authz:8050` | -
`HIGHFLAME_AUTHN_URL` | highflame authn url | `http://highflame-authn:8051` | -
`HIGHFLAME_SHIELD_URL` | highflame shield url | `http://highflame-shield:8070/v1/shield` | -
`HIGHFLAME_CERBERUS_URL` | highflame cerberus url | `http://highflame-cerberus:8082/v1/cerberus` | -
`HIGHFLAME_DISCOVERY_URL` | highflame discovery url | `http://highflame-discovery:8095` | -
`HIGHFLAME_TENANCY_DEFAULT_ORG_TIER` | Tenancy default org tier | `free` | `free` or `paid`
`HIGHFLAME_TENANCY_TIER_MANAGEMENT_ENABLED` | Tenancy default enabled | `true` | `true` or `false`
`HIGHFLAME_TENANCY_BOOTSTRAP_SUPER_ADMINS` | Tenancy bootstrap super admins | `""` | Optional
`MARKETPLACE_JWT_SECRET` | Highflame Marketplace secret | nil | Only for SaaS
`HIGHFLAME_APP_URL` | Endpoint for studio service | nil | -
`CLERK_PROXY_URL` | Highflame clerk proxy url - match with `NEXT_PUBLIC_CLERK_PROXY_URL` | nil | Only for SaaS : `https://<<studio_domain_name>>/__clerk`
`HIGHFLAME_SCIM_EXTERNAL_BASE_URL` | Next public scim url - must match with `NEXT_PUBLIC_SCIM_BASE_URL` from studio | nil | `https://<<control_domain_name>>/scim/v2`
`ACCOUNT_ID` | Account ID | nil | _Will be shared by a Highflame representative_
`HIGHFLAME_INTERNAL_SERVICE_SECRET` | Highflame Internal communication secret | nil | _Will be shared by a Highflame representative_
`HIGHFLAME_AUTH_PROVIDERS_CLERK_CONFIG_SECRET` | Clerk secret key | nil | _Will be shared by a Highflame representative_
`HIGHFLAME_AUTH_JWT_SECRET_KEY` | JWT Secret key | nil | _Will be shared by a Highflame representative_

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
`HIGHFLAME_ADMIN_URL` | highflame admin url | `http://highflame-admin:8040` | -
`OTEL_EXPORTER_OTLP_ENDPOINT` | OTEL endpoint | `http://highflame-collector:4317` | -
`HIGHFLAME_ISSUER` | Highflame issuer | nil | `https://<<auth_domain_name>>`
`HIGHFLAME_WIMSE_DOMAIN` | Root every agent/workload identity issued in the environment, no domain setup required. | nil | `<<root_domain_name>> or <<unique_name-root_domain_name>>`
`HIGHFLAME_RSA_PRIVATE_KEY_PATH` | highflame rsa private key path | `/app/keys/jwt-private.pem` | -
`HIGHFLAME_SECRETS_BACKEND` | Highflame secrets store | `kubernetes` | -
`HIGHFLAME_AUTH_ASSERTION_RESOLVER_AUDIENCE` | authn assertion resolver | `highflame-authn` | -
`HIGHFLAME_AUTH_ASSERTION_RESOLVER_TRUSTED_ISSUERS` | authn assertion resolver trusted issuers | `[{"issuer":"highflame-studio","jwks_url":"http://highflame-studio:3000/.well-known/jwks.json"}]` | -
`HIGHFLAME_ALLOW_UNSAFE_DEV_STUB` | enable / disable the unsafe dev attestation stub | `false` | `true` or `false`
`HIGHFLAME_DEVICE_AUTH_VERIFICATION_URI` | Studio's /device consent screen | nil | `'https://<<studio_domain_name>>/device'`
`HIGHFLAME_CIMD_ENABLED` | Regression suite's CIMD coverage | nil | `true` or `false`
`HIGHFLAME_INTERNAL_SERVICE_SECRET` | Highflame Internal communication secret | nil | _Will be shared by a Highflame representative_
`HIGHFLAME_AUTH_JWT_SECRET_KEY` | JWT Secret key | nil | _Will be shared by a Highflame representative_
`HIGHFLAME_TOKEN_ENCRYPTION_KEY` | Token encryption key | nil | A unique enc key like `hf-token-encryption-key-32b!`

### highflame-authz

Variable Name | Variable Value | Default Value | Acceptable Value
--------------|--------------|--------------|--------------
`DB_USERNAME` | Postgres username | nil | -
`DB_PASSWORD` | Postgres password | nil | -
`DB_HOST` | Postgres host | nil | -
`DB_PORT` | Postgres port | `5432` | -
`DB_SSL_MODE` | Postgres sslmode | `disable` | `disable` or `require`
`AUTHZ_DB_NAME` | Postgres database | `highflame_data` | -
`HIGHFLAME_INTERNAL_SERVICE_SECRET` | Highflame Internal communication secret | nil | _Will be shared by a Highflame representative_

### highflame-cerberus

Variable Name | Variable Value | Default Value | Acceptable Value
--------------|--------------|--------------|--------------
`HIGHFLAME_ADMIN_URL` | Highflame Admin URL | `http://highflame-admin:8040`| -
`HIGHFLAME_SHEILD_URL` | Highflame Sheild URL | `http://highflame-shield:8070/v1/shield`| -
`HIGHFLAME_COLLECTOR_URL` | Highflame Collector URL | `highflame-collector:4317`| -
`HIGHFLAME_AUTH_JWT_PUBLIC_KEY` | Highflame JWTpublic key | `/app/config/jwt/jwt-public.pem` | -

### highflame-collector

Variable Name | Variable Value | Default Value | Acceptable Value
--------------|--------------|--------------|--------------
`CLICKHOUSE_ENDPOINT` | Clickhouse Endpoint | `tcp://clickhouse-ch.clickhouse.svc.cluster.local:9000` | -
`CLICKHOUSE_DATABASE` | Clickhouse Database | `highflame` | -
`CLICKHOUSE_USERNAME` | Clickhouse Username | nil | -
`CLICKHOUSE_PASSWORD` | Clickhouse Password | nil | -

### highflame-discovery

Variable Name | Variable Value | Default Value | Acceptable Value
--------------|--------------|--------------|--------------
`DB_USERNAME` | Postgres username | nil | -
`DB_PASSWORD` | Postgres password | nil | -
`DB_HOST` | Postgres host | nil | -
`DB_PORT` | Postgres port | `5432` | -
`DB_SSL_MODE` | Postgres sslmode | `disable` | `disable` or `require`
`DISCOVERY_DB_NAME` | Postgres database | `highflame_discovery` | -
`HIGHFLAME_AUTH_JWKS_URL` | Highflame JWKS URL | `http://highflame-authn:8051/.well-known/jwks.json` | -
`OTEL_ENABLED` | Enable OTEL | `true` | -
`OTEL_EXPORTER_OTLP_ENDPOINT` | OTEL endpoint | `http://highflame-collector:4317` | -
`HIGHFLAME_ZEROID_BASE_URL` | Highflame zeriod base url | `http://highflame-authn:8051` | -
`HIGHFLAME_SYNC_ENABLED` | Highflame sync enabled or disabled | `true` | `true` or `false`
`HIGHFLAME_SYNC_TICK_SECONDS` | Highflame sync tick interval | `86400` | -
`HIGHFLAME_AUTH_JWT_ISSUER`| Highflame JWT Issuer | nil | `https://<<auth_domain_name>>`
`HIGHFLAME_SECRETS_BACKEND`| Highflame secrets store | `kubernetes` | -
`HIGHFLAME_ADMIN_BASE_URL`| Highflame admin base url | `http://highflame-admin:8040` | -

### highflame-firehog

Variable Name | Variable Value | Default Value | Acceptable Value
--------------|--------------|--------------|--------------
`HIGHFLAME_SHIELD_URL` | highflame shield url | `http://highflame-shield:8070/v1/shield` | -
`HIGHFLAME_ADMIN_URL` | highflame admin url | `http://highflame-admin:8040` | -
`HIGHFLAME_AUTHN_URL` | highflame authn url | `http://highflame-authn:8051` | -
`HIGHFLAME_JWT_ISSUER` | highflame jwt issuer | `highflame-admin` | -
`HIGHFLAME_FIREHOG_URL` | highflame firehog url | nil | `https://<<gateway_domain_name>>`
`OAUTH_AUTHORIZATION_SERVER` | Highflame Authorization server URL | nil | `https://<<studio_domain_name>>`
`FIREHOG_SHIELD_SCAN_SCOPE` | LLM ingress scan scope | `full` | -
`OAUTH_CIMD_SUPPORTED` | CIMD disabled or enabled | `false` | `true` or `false`
`QUOTA_ENABLED` | Quota RPM/TPM enforcement | `true` | `true` or `false`
`HIGHFLAME_INTERNAL_SERVICE_SECRET` | Highflame Internal communication secret | nil | _Will be shared by a Highflame representative_

### highflame-guard-*

Variable Name | Variable Value | Default Value | Acceptable Value
--------------|--------------|--------------|--------------
`HF_HUB_ENABLE_HF_TRANSFER` | Enable huggingface transfer | `1` | -
`WORKERS` | Number of workers | `2` | -
`MAX_BATCH_TOKENS` | Maximum batch tokens | `16384` | -
`GPU_MEMORY_BUDGET_MB` | GPU memory allocation | `2100` | -
`HIGHFLAME_MODELS_SECRET` | Highflame model secret | nil | _Will be shared by a Highflame representative_

### highflame-observatory

Variable Name | Variable Value | Default Value | Acceptable Value
--------------|--------------|--------------|--------------
`CLICKHOUSE_HOST` | Clickhouse Host | `clickhouse-ch.clickhouse.svc.cluster.local` | -
`CLICKHOUSE_DATABASE` | Clickhouse Database | `highflame` | -
`CLICKHOUSE_USERNAME` | Clickhouse Username | nil | -
`CLICKHOUSE_PASSWORD` | Clickhouse Password | nil | -
`HIGHFLAME_AUTH_JWT_ISSUER`| Highflame JWT Issuer | nil | `https://<<auth_domain_name>>`
`HIGHFLAME_AUTH_JWKS_URL` | Highflame JWKS URL | `http://highflame-authn:8051/.well-known/jwks.json` | -
`HIGHFLAME_RECEIPT_AUTHN_JWKS_URL` | Highflame receipt authn JWKS URL | `http://highflame-authn:8051/v1/auth/.well-known/highflame-receipt-keys` | -
`HIGHFLAME_RAMPARTS_URL` | Highflame ramparts server | `http://highflame-ramparts-server:8080` | -
`HIGHFLAME_INTERNAL_SERVICE_SECRET` | Highflame Internal service secrets | nil | _Will be shared by a Highflame representative_

### highflame-redteam

Variable Name | Variable Value | Default Value | Acceptable Value
--------------|--------------|--------------|--------------
`REDTEAM_SEEDER_DATASET` | Redteam seeder dataset name | nil | `highflame/highflame-red5-with-embeddings`
`REDTEAM_SEEDER_DATASET_VER` | Redteam seeder dataset version | nil | `hf_v1`
`REDTEAM_SEEDER_ARGS` | Redteam seeder command args | nil | `--force`
`DB_USERNAME` | Postgres username | nil | -
`DB_PASSWORD` | Postgres password | nil | -
`DB_HOST` | Postgres host | nil | -
`DB_PORT` | Postgres port | `5432` | -
`DB_SSL_MODE` | Postgres sslmode | `disable` | `disable` or `require`
`REDIS_HOST` | Redis host | nil | -
`REDIS_PORT` | Redis port | `6379` | -
`REDIS_TLS` | Redis TLS | `false` | `true` or `false`
`REDIS_USER` | Redis username | nil | -
`REDIS_PASS` | Redis password | nil | -
`REDIS_CACERT` | Redis CA Cert | `""` | -
`REDIS_PROGRESS_TTL_SECONDS` | Redis progress TTL seconds | `86400` | -
`OPENAI_API_KEY` | OpenAI api key | nil | Conflict with other providers
`XAI_API_KEY` | Xai api key | nil | Conflict with other providers
`AZURE_API_KEY` | Azure OpenAI api key | nil | Conflict with other providers
`AZURE_API_BASE` | Azure OpenAI API base | nil | Conflict with other providers
`AZURE_API_VERSION` | Azure OpenAI version | `2024-02-15-preview` | -
`REDTEAM_DB_NAME` | Postgres database | `highflame_redteam` | -
`HIGHFLAME_ADMIN_URL` | Highflame admin url | `http://highflame-admin:8040` | -
`MODEL_HIGH_END` | Provider high model name | `gpt-4o` | -
`MODEL_LOW_END` | Provider low model name | `gpt35` | -
`EMBEDDING_MODEL` | Embedding model name | `text-embedding-3-small` | -
`GROK_MODEL` | Grok model name | `grok-2` | Conflict with other providers
`ATTACK_GEN_MODEL` | Xai model name | `xai/grok-3` | Conflict with other providers
`DEFAULT_PROVIDER` | Default provider | `openai` | `openai` or `bedrock` or `azure` or `local`
`OTEL_EXPORTER_OTLP_ENDPOINT` | Highflame collector URL | `http://highflame-collector:4317` | -
`OTEL_SERVICE_NAME` | Highflame collector service | `redteam-scanner` | -
`HIGHFLAME_INTERNAL_SERVICE_SECRET` | Highflame Internal communication secret | nil | _Will be shared by a Highflame representative_
`HF_TOKEN` | HF token | nil | _Will be shared by a Highflame representative_

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
`OPENAI_API_KEY_1` | OpenAi api key | nil | Optional - for `DEFAULT_PROVIDER=openai` and need rotational key for model access
`OPENAI_API_KEY_2` | OpenAi api key | nil | Optional - for `DEFAULT_PROVIDER=openai` and need rotational key for model access
`OPENAI_API_KEY_3` | OpenAi api key | nil | Optional - for `DEFAULT_PROVIDER=openai` and need rotational key for model access
`LOCAL_API_BASE` | Local API base | `http://highflame-chat-tester:8080` | for `DEFAULT_PROVIDER=local`
`LOCAL_API_KEY` | Local api key | nil | for `DEFAULT_PROVIDER=local`
`DEFAULT_PROVIDER` | Default provider | nil | `openai` or `bedrock` or `azure` or `local` 

### highflame-shield

Variable Name | Variable Value | Default Value | Acceptable Value
--------------|--------------|--------------|--------------
`REDIS_HOST` | Redis host | nil | -
`REDIS_PORT` | Redis port | `6379` | -
`REDIS_TLS` | Redis TLS | `false` | `true` or `false`
`REDIS_USER` | Redis username | nil | -
`REDIS_PASS` | Redis password | nil | -
`REDIS_CACERT` | Redis cacert | `""` | -
`CLOUD_ARCHIVE_TYPE` | Cloud archive type | nil | optional - `s3` or `gcs` or `azure-blob`
`CLOUD_ARCHIVE_BUCKET` | Cloud archive bucket name | nil | optional
`HIGHFLAME_DEPLOYMENT_TYPE` | Deploy type | `prod` | `dev` or `prod`
`K8S_NAMESPACE` | Kubernetes namespace | `Deployed K8s namespace` | `Deployed K8s namespace`
`HIGHFLAME_ADMIN_URL` | highflame admin url | `http://highflame-admin:8040` | -
`HIGHFLAME_AUTHZ_URL` | highflame authz url | `http://highflame-authz:8050` | -
`HIGHFLAME_GUARD_URL` | highflame guard url | `http://highflame-guard:8013` | -
`HIGHFLAME_GUARD_CM_URL` | highflame guard cm url | `http://highflame-guard-cm:8014` | -
`HIGHFLAME_GUARD_PII_URL` | highflame guard pii url | `http://highflame-guard-pii:8018` | -
`HIGHFLAME_GUARD_DEEPCONTEXT_URL` | highflame guard deepcontext url | `http://highflame-guard-deep:8022` | -
`HIGHFLAME_CHECKPHISH_BUCKET_NAME` | highflame checkphish bucket name | `javelin-prod-bloom-filter` | -
`HIGHFLAME_CHECKPHISH_OBJECT_NAME` | highflame checkphish object name | `bloom_filter_url.gob` | -
`HIGHFLAME_CHECKPHISH_OBJECT_URL` | highflame checkphish object url | `https://javelin-prod-bloom-filter.s3.us-east-1.amazonaws.com/bloom_filter_url.gob` | -
`HIGHFLAME_CHECKPHISH_STORAGE_TYPE` | highflame checkphish storage type | `url` | `url`, `s3`
`HIGHFLAME_CHECKPHISH_STORAGE_REGION` | highflame checkphish storage region | `us-east-1` | `for s3`
`HIGHFLAME_MODEL_ARMOR_TEMPLATE` | Model armor template | nil | optional
`HIGHFLAME_MODEL_ARMOR_LOCATION` | Model armor location | `us-central1` | optional
`HIGHFLAME_MODEL_ARMOR_PROJECT_ID` | Model armor GCP project id | `javelin-saas` | -
`GOOGLE_APPLICATION_CREDENTIALS` | Model armor GCP json cred path | `/app/config/gcp-credential.json` | optional
`CLOUD_ARCHIVE_ENABLED` | Cloud archive enabled | `false` | `true` or `false`
`CLOUD_ARCHIVE_PREFIX` | Cloud archive prefix in the storage | `shield/sessions/` | optional
`AWS_ACCESS_KEY_ID` | AWS Access Key | `""` | for `CLOUD_ARCHIVE_TYPE=s3`
`AWS_SECRET_ACCESS_KEY` | AWS Secret Key | `""` | for `CLOUD_ARCHIVE_TYPE=s3`
`HIGHFLAME_SCAN_STORAGE_BUCKET`| Highflame scan s3 bucket name | nil | optional
`AWS_SCAN_STORAGE_REGION` | Highflame scan s3 bucket Region | nil | optional
`HIGHFLAME_AUTH_JWT_ISSUER`| Highflame JWT Issuer | nil | `https://<<auth_domain_name>>`
`HIGHFLAME_AUTH_JWKS_URL` | Highflame JWKS URL | `http://highflame-authn:8051/.well-known/jwks.json` | -
`HIGHFLAME_RECEIPT_SIGNING_AUTHN_BASE_URL`| Highflame signin authn base url | `http://highflame-authn:8051` | -
`HIGHFLAME_RECEIPT_SIGNING_ENABLED`| Highflame signing enabled | nil | `true` or `false`
`HIGHFLAME_AUTHN_BASE_URL`| Highflame authn url | `http://highflame-authn:8051` | -
`HIGHFLAME_ENABLE_POLICY_SLICING`| Enable policy slicing | nil | `true` or `false`
`HIGHFLAME_INTERNAL_SERVICE_SECRET` | Highflame Internal communication secret | nil | _Will be shared by a Highflame representative_
`HIGHFLAME_MODELS_SECRET` | Highflame model secret | nil | _Will be shared by a Highflame representative_

### highflame-studio

Variable Name | Variable Value | Default Value | Acceptable Value
--------------|--------------|--------------|--------------
`NEXT_PUBLIC_ADMIN_API_URL` | Next public admin api url | `""` | `https://<<control_domain_name>>`
`NEXT_PUBLIC_APP_URL` | Endpoint for studio service | nil | `https://<<studio_domain_name>>`
`NEXT_PUBLIC_FIREHOG_URL` | Endpoint for firehog service | nil | `https://<<gateway_domain_name>>`
`NEXT_PUBLIC_CLERK_SIGN_IN_URL` | Clerk sign in url | `/sign-in` | -
`NEXT_PUBLIC_CLERK_SIGN_UP_URL` | Clerk sign up url | `/sign-up` | -
`NODE_ENV` | Nodejs env | `production` | `development` or `production`
`NEXT_TELEMETRY_DISABLED` | Telemetry option | `1` | `0` or `1`
`HIGHFLAME_ADMIN_URL` |  Admin api url | `http://highflame-admin:8040` | -
`HIGHFLAME_SHIELD_URL` |  shield api url | `http://highflame-shield:8070/v1/shield` | -
`HIGHFLAME_AUTHN_URL` |  authn api url | `http://highflame-authn:8051` | -
`HIGHFLAME_OBSERVATORY_URL` |  observatory api url | `http://highflame-observatory:8090` | -
`HIGHFLAME_REDTEAM_LAB_URL` |  redteam lab api url | `http://highflame-redteam-lab1:8002` | -
`HOSTNAME` | Service hostname | `0.0.0.0` | -
`PORT` | Service port | `3000` | -
`SUPPORT_SMTP_PASSKEY` | SMTP Credential | nil | optional
`MARKETPLACE_FROM_EMAIL` | SMTP from mail | nil | Only for SaaS
`MARKETPLACE_NOTIFY_EMAIL` | SMTP Notify mail | nil | Only for SaaS
`HIGHFLAME_JWT_ISSUER` | highflame jwt issuer | `highflame-admin` | -
`HIGHFLAME_RSA_PRIVATE_KEY_PATH` | highflame rsa private key path | `/app/keys/auth/jwt-private.pem` | -
`NEXT_PUBLIC_POSTHOG_HOST` | Posthog host | `https://us.i.posthog.com` | Only for SaaS
`NEXT_PUBLIC_POSTHOG_KEY` | Posthog key | nil | Only for SaaS
`NEXT_PUBLIC_AUTHN_URL` | highflame authn endpoint | nil | `https://<<auth_domain_name>>`
`HIGHFLAME_OAUTH_SIGNING_KEY_ID` | Highflame oauth signing key ID | nil | A unique ID like `studio-poc-v1`
`HIGHFLAME_OAUTH_ASSERTION_AUDIENCE` | Highflame oauth assertion | `highflame-authn` | -
`HIGHFLAME_OAUTH_AUTHORIZE_URL` | Highflame oauth authorize url | `http://highflame-authn:8051/oauth2/authorize` | -
`HIGHFLAME_RAMPARTS_URL` | Highflame ramparts server | `http://highflame-ramparts-server:8080` | -
`NEXT_PUBLIC_CLERK_ALLOWED_REDIRECT_ORIGINS` | Highflame clerk redirect origins | nil | Only for SaaS
`NEXT_PUBLIC_CLERK_PROXY_URL` | Highflame clerk proxy url - match with `CLERK_PROXY_URL` | nil | Only for SaaS: `https://<<studio_domain_name>>/__clerk`
`NEXT_PUBLIC_FEATURE_AGENT_DISCOVERY` | enable / disable feature agent discovery | nil | `true` or `false`
`NEXT_PUBLIC_DISCOVERY_PRINCIPAL_ARN` | Pass the ARN principle for accessing the AWS bedrock connector | nil | optional
`NEXT_PUBLIC_SCIM_BASE_URL` | Next public scim url - must match with `HIGHFLAME_SCIM_EXTERNAL_BASE_URL` from admin | nil | `https://<<control_domain_name>>/scim/v2`
`HIGHFLAME_FORGE_URL` | Highflame firehog url | `http://highflame-forge:8100` | -
`HIGHFLAME_AUTH_PROVIDER` | Highflame auth provider | `clerk` | -
`HIGHFLAME_OAUTH_SIGNING_KEY_PATH` | Highflame oauth signing key path | `/app/keys/oauth/oauth-signing-key.pem` | -
`CLERK_SECRET_KEY` | Clerk secret key | nil | _Will be shared by a Highflame representative_
`NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY` | Clerk publishable key | nil | _Will be shared by a Highflame representative_
`HIGHFLAME_AUTH_JWT_SECRET_KEY` | JWT Secret key | nil | _Will be shared by a Highflame representative_
`HIGHFLAME_INTERNAL_SERVICE_SECRET` | Highflame Internal service secrets | nil | _Will be shared by a Highflame representative_

### highflame-ramparts-server

Variable Name | Variable Value | Default Value | Acceptable Value
--------------|--------------|--------------|--------------
`LLM_PROVIDER` | Provider name | nil | -
`LLM_MODEL` | Model name | nil | -
`LLM_URL` | LLM complete URL | nil | -
`LLM_API_KEY` | LLM API Key | nil | -
