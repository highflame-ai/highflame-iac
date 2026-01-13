## Module Specific Environment Variables

### highflame-admin

Variable Name | Variable Value | Default Value | Acceptable Value
--------------|--------------|--------------|--------------
`ACCOUNT_ID` | Account ID | nil | -
`DB_USERNAME` | Postgres username | nil | -
`DB_PASSWORD` | Postgres password | nil | -
`DB_HOST` | Postgres host | nil | -
`DB_NAME` | Postgres database | nil | -
`REDIS_HOST` | Redis host | nil | -
`REDIS_USER` | Redis username | nil | -
`REDIS_PASS` | Redis password | nil | -
`AWS_KMS_KEY` | AWS KMS Key for secret manager enc | nil | optional
`AWS_SECRET_REPLICATION_REGION` | AWS replication region | nil | optional
`AWS_REPLICATION_KMS_KEY` | AWS KMS Key for secret manager enc in replication region | nil | optional
`REDIS_PORT` | Redis port | `6379` | -
`REDIS_TLS` | Redis TLS | `false` | `true` or `false`
`REDIS_CACERT` | Redis CA Cert | `""` | -
`K8S_NAMESPACE` | Kubernetes namespace | `Deployed K8s namespace` | -
`DB_PORT` | Postgres port | `5432` | -
`DB_SSL_MODE` | Postgres sslmode | `disable` | `disable` or `require`
`REDTEAM_DB_NAME` | Postgres database | `javelin_redteam` | -
`HIGHFLAME_FF_URL` | highflame flag url | `http://highflame-flag:1031/` | -
`HIGHFLAME_REDTEAM_URL` | highflame redteam url | `http://highflame-redteam:8001/v1` | -

### highflame-core

Variable Name | Variable Value | Default Value | Acceptable Value
--------------|--------------|--------------|--------------
`ACCOUNT_ID` | Account ID | nil | -
`LLAMA_GUARD_URL` | Llama gaurd url | nil | optional
`LLAMA_GUARD_API_KEY` | Llama gaurd api key | nil | optional
`REDIS_HOST` | Redis host | nil | -
`REDIS_USER` | Redis username | nil | -
`REDIS_PASS` | Redis password | nil | -
`UNKEY_ROOT_KEY` | Unkey Root Key | nil | optional
`UNKEY_API_ID` | Unkey api id | nil | optional
`MODEL_ARMOR_LOCATION` | Model armor location | nil | -
`MODEL_ARMOR_TEMPLATE` | Model armor template | nil | -
`REDIS_PORT` | Redis port | `6379` | -
`REDIS_TLS` | Redis TLS | `false` | `true` or `false`
`REDIS_CACERT` | Redis CA Cert | `""` | -
`DEPLOY_TYPE` | Deploy type | `dev` | `dev` or `prod`
`K8S_NAMESPACE` | Kubernetes namespace | `Deployed K8s namespace` | `Deployed K8s namespace`
`HIGHFLAME_ADMIN_URL` | highflame admin url | `http://highflame-admin:8040` | -
`HIGHFLAME_EVAL_URL` | highflame eval url | `http://highflame-eval:8009` | -
`HIGHFLAME_DLP_URL` | highflame dlp url | `http://highflame-dlp:8888` | -
`HIGHFLAME_FF_URL` | highflame flag url | `http://highflame-flag:1031/` | -
`HIGHFLAME_GUARD_URL` | highflame guard url | `http://highflame-guard:8013` | -
`HIGHFLAME_GUARD_CM_URL` | highflame guard cm url | `http://highflame-guard-cm:8014` | -
`HIGHFLAME_GUARD_HALLUCINATION_URL` | highflame guard hallucination url | `http://highflame-guard-hallucination:8015` | -
`HIGHFLAME_GUARD_PLI_URL` | highflame guard pli url | `http://highflame-guard-pli:8016` | -
`HIGHFLAME_GUARD_LANGUAGE_URL` | highflame guard language url | `http://highflame-guard-lang:8020` | -
`HIGHFLAME_GUARD_FACTCHECK_URL` | highflame guard factual url | `http://highflame-guard-fact:8018` | -
`HIGHFLAME_GUARD_SENTIMENT_URL` | highflame guard sentiment url | `http://highflame-guard-sentiment:8021` | -
`HIGHFLAME_CHECKPHISH_BUCKET_NAME` | highflame checkphish bucket name | `javelin-saas-bloom-filter-store` | -
`HIGHFLAME_CHECKPHISH_OBJECT_NAME` | highflame checkphish object name | `bloom_filter_url.gob` | -
`REFRESH_SECRETS_ON_401` | Refresh secrets on 401 | `true` | `true` or `false`
`BYPASS_GUARDRAILS` | Bypass guardrails for streaming | `true` | `true` or `false`
`AUTO_PROVISION_APPLICATION` | Auto provision the application | `true` | `true` or `false`
`GOOGLE_CLOUD_PROJECT` | GCP project id | `javelin-saas` | -
`GOOGLE_APPLICATION_CREDENTIALS` | GCP json cred path | `/app/config/gcp-credential.json` | -
`AWS_ACCESS_KEY_ID` | AWS Access Key | `""` | optional
`AWS_SECRET_ACCESS_KEY` | AWS Secret Key | `""` | optional
`AWS_REGION` | AWS Region | `""` | optional
`ENABLE_SENTRY` | Sentry dsn | `false` | `true` or `false`
`SENTRY_DSN` | Sentry dsn | `""` | optional
`OTEL_EXPORTER_OTLP_TRACES_ENDPOINT` | OTEL exporter endpoint | `http://highflame-collector:4318/api/public/otel/v1/traces` | optional
`OTEL_EXPORTER_OTLP_HEADERS` | OTEL exporter headers | `""` | optional

### highflame-webapp

Variable Name | Variable Value | Default Value | Acceptable Value
--------------|--------------|--------------|--------------
`CLERK_SECRET_KEY` | Clerk secret key | nil | -
`NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY` | Clerk publishable key | nil | -
`NEXT_PUBLIC_POSTHOG_KEY` | Posthog key | nil | optional
`NEXT_PUBLIC_DEFAULT_USER_ROLE` | Default user role | nil | -
`NEXT_PUBLIC_PRESTRINGS` | Filter prestrings for user roles | nil | -
`NEXT_PUBLIC_REDIRECT_URI` | Redirect url | nil | -
`NEXT_PUBLIC_USER_ROLES` | json formatted user roles | nil | -
`REDIRECT_URI` | Redirect url | nil | -
`NEXT_PUBLIC_BUID_CLUSTER_MAP` | json formatted buid cluser map | nil | -
`NEXT_PUBLIC_HA_PAIRS` | json formatted HA pair | nil | -
`SUPPORT_SMTP_PASSKEY` | SMTP Credential | `` | -
`SUPPORT_SMTP_FROM_EMAIL` | SMTP from mail | `noreply@support.highflame.com` | -
`SUPPORT_SMTP_SERVICE` | SMTP Service type | `Gmail` | -
`NEXT_PUBLIC_SECRET_STORE` | Secret Store | `kubernetes` | `kubernetes` or `aws` or combination (`kubernetes,aws`)
`NEXT_PUBLIC_CORE_INT_URL` | Highflame core internal url | `http://highflame-core:8000/` | -
`NEXT_PUBLIC_CLERK_SIGN_IN_URL` | Clerk sign in url | `/sign-in` | -
`NEXT_PUBLIC_CLERK_SIGN_UP_URL` | Clerk sign up url | `/signup` | -
`NEXT_PUBLIC_POSTHOG_HOST` | Posthog url | `https://us.i.posthog.com` | -
`NEXT_PUBLIC_SUPPORT_SMTP_TO_EMAIL` | SMTP to mail | `support@highflame.com` | -
`NEXT_PUBLIC_SAAS_SERVICE` | Showcase the SaaS services in the UI | `FALSE` | `TRUE` or `FALSE`
`NEXT_PUBLIC_CLERK_SIGNUP` | Enable clerk sign up | `visible` | `visible` or `hidden`
`NEXT_PUBLIC_BUID_MAX_GATEWAYS` | Max number of gateway | `2` | -
`NEXT_PUBLIC_DEFAULT_USAGE_PLAN_ID` | Highflame usage plan id | `d1jy0v` | -
`NEXT_PUBLIC_DEPLOYED_TARGET` | Deployed target env | `main` | `main` or `experimental`
`NEXT_PUBLIC_ONBOARDING_ENABLED` | Enable Onboarding | `false` | `true` or `false`
`OTEL_ADMIN_EMAIL` | OTEL admin username | `` | -
`OTEL_ADMIN_PASSWORD` | OTEL admin password | `` | -
`NEXT_PUBLIC_REDTEAM_STATIC_PROMPTS` | Enable Redteam static prompts | `false` | `true` or `false`
`NEXT_PUBLIC_REDTEAM_TEMPLATE_SEED` | Enable Redteam template seed | `true` | `true` or `false`

### highflame-eval

Variable Name | Variable Value | Default Value | Acceptable Value
--------------|--------------|--------------|--------------
`CORS_ALLOWED_ORIGINS` | CORS allowed origins | `*` | -
`CORS_ALLOWED_METHODS` | CORS allowed methods | `POST,GET,OPTIONS` | -
`CORS_ALLOWED_HEADERS` | CORS allowed headers | `Authorization,Content-Type,x-api-key,x-javelin-user,x-javelin-userrole` | -

### highflame-dlp

Variable Name | Variable Value | Default Value | Acceptable Value
--------------|--------------|--------------|--------------
`CORS_ALLOWED_ORIGINS` | CORS allowed origins | `*` | -
`CORS_ALLOWED_METHODS` | CORS allowed methods | `POST,GET,OPTIONS` | -
`CORS_ALLOWED_HEADERS` | CORS allowed headers | `Authorization,Content-Type,x-api-key,x-javelin-user,x-javelin-userrole` | -

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
`Highflame_ADMIN_URL` | Highflame admin url | `http://highflame-admin:8040` | -
`MODEL_HIGH_END` | Provider high model name | `gpt-4o` | -
`MODEL_LOW_END` | Provider low model name | `gpt35` | -
`EMBEDDING_MODEL` | Embedding model name | `text-embedding-3-small` | -
`GROK_MODEL` | Grok model name | `grok-2` | -
`DEFAULT_PROVIDER` | Default provider | `openai` | `openai` or `bedrock` or `azure` or `local` 

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

### highflame-ramparts-server

Variable Name | Variable Value | Default Value | Acceptable Value
--------------|--------------|--------------|--------------
`LLM_PROVIDER` | Provider name | nil | -
`LLM_MODEL` | Model name | nil | -
`LLM_URL` | LLM complete URL | nil | -
`LLM_API_KEY` | LLM API Key | nil | -

### highflame-scout

Variable Name | Variable Value | Default Value | Acceptable Value
--------------|--------------|--------------|--------------
`HIGHFLAME_URL` | Highflame API URL | nil | -
`HIGHFLAME_API_KEY` | Highflame API Key | nil | -

### highflame-cerberus

Variable Name | Variable Value | Default Value | Acceptable Value
--------------|--------------|--------------|--------------
`HIGHFLAME_URL` | Highflame API URL | `http://highflame-core:8000` | -
`HIGHFLAME_API_KEY` | Highflame API Key | nil | -
`LANGFUSE_API_URL` | Langfuse endpoint | `http://langfuse-web:3000` | -

### highflame-collector

Variable Name | Variable Value | Default Value | Acceptable Value
--------------|--------------|--------------|--------------
`CERBERUS_HTTP_ENDPOINT` | Cerberus http endpoint | `http://highflame-cerberus:8080` | -
`LANGFUSE_OTLP_ENDPOINT` | Langfuse otlp endpoint | `http://langfuse-web:3000` | -