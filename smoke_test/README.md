# Smoke Test Setup & Usage

Follow these steps to set up and run the smoke test:

## 1. Move to Smoke Test Directory and Create Virtual Environment

```sh
cd smoke_test
```

**Windows:**
```sh
python -m venv venv
venv\Scripts\activate
```

**macOS/Linux:**
```sh
python3 -m venv venv
source venv/bin/activate
```

## 2. Install Dependencies

With your virtual environment activated, run:
```sh
pip install javelin-sdk rich
```

## 3. Configure API Keys and Backend Settings

Edit the `config.json` file and set your API keys and backend settings:
```json
{
    "x-api-key": "<your-javelin-api-key>",
    "llm_api_key": "<your-openai-api-key>",
    "base_url": "<your-backend-url>",
    "secrets_provider": "<your-secrets-provider>"
}
```

- `x-api-key`: Your Javelin API key.
- `llm_api_key`: Your Provider API key.
- `base_url`: The base URL of your backend (e.g., `http://your-backend-url.com`).
- `secrets_provider`: The secrets provider in use (e.g., `kubernetes`).

## 4. Run the Smoke Test

With your virtual environment activated and dependencies installed, run:
```sh
python smoke_test.py
```

---

## Troubleshooting
- Ensure your Python version is compatible (Python 3.8+ recommended).
- Double-check that your API keys are valid and correctly set in `config.json`.

---

## Gateway Processor Chain Configuration (for New Gateway Testing)

If you are testing on a new gateway, ensure you have set up the correct processors in both the request and response chains.

### Request Chain Example
```json
{
  "name": "sys-preprod-reqchain",
  "path": "request_chain",
  "version": "1.1.2",
  "workflow": {
    "exec_mode": "sequential",
    "processors": [
      {
        "exec_mode": "parallel",
        "processors": [
          {
            "name": "Rate Limiter",
            "reference": "ratelimit",
            "will_block": true
          },
          {
            "name": "Sensitive Data Protection",
            "reference": "dlp_gcp",
            "will_block": true
          },
          {
            "name": "Prompt Injection Detection",
            "inputs": {
              "engine": "javelin"
            },
            "reference": "promptinjectiondetection",
            "will_block": true
          },
          {
            "name": "Trust & Safety",
            "scope": "system",
            "inputs": {
              "engine": "javelin"
            },
            "reference": "trustsafety",
            "will_block": true
          }
        ]
      },
      {
        "exec_mode": "parallel",
        "processors": [
          {
            "name": "Archive",
            "reference": "archive",
            "will_block": false
          },
          {
            "name": "Secrets",
            "reference": "secrets",
            "will_block": true
          }
        ]
      }
    ]
  },
  "description": "Pre-production request processor chain"
}
```

### Response Chain Example
```json
{
  "name": "sys-preprod-respchain",
  "path": "response_chain",
  "version": "1.1.2",
  "workflow": {
    "exec_mode": "sequential",
    "processors": [
      {
        "name": "Trust & Safety",
        "reference": "trustsafety",
        "will_block": true,
        "inputs": {
          "engine": "lakera"
        }
      },
      {
        "name": "Security Filters Code Detection",
        "reference": "securityfilters",
        "will_block": true
      },
      {
        "name": "Response Telemetry",
        "reference": "response",
        "will_block": true
      },
      {
        "name": "Archive",
        "reference": "archive",
        "will_block": false
      }
    ]
  },
  "description": "Pre-production response processor chain"
}
```

---

**Note:**
- Adjust processor configurations as needed for your environment.
- Ensure both chains are properly set up before running the smoke test on a new gateway.

---

## Configuring Different LLM Providers and Models

To test different models or providers, update the provider configuration and route directly in the `smoke_test.py` script. Look for variables or configuration sections related to the provider and route, and modify them as needed for your use case.

For a list of supported LLMs and their configuration details, refer to the official Javelin documentation: [Supported Language Models](https://docs.getjavelin.io/docs/highflame-core/supported-llms)

---