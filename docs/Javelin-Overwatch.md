# Javelin Overwatch

`Javelin Overwatch` is a powerful command-line tool that leverages eBPF (Extended Berkeley Packet Filter) technology to monitor Model Context Protocol (MCP) communication at the kernel level. It provides real-time visibility into JSON-RPC 2.0 messages exchanged between MCP clients and servers by hooking into low-level system calls.

The Model Context Protocol supports three transport protocols for communication:

* Stdio: Communication over standard input/output streams

* Streamable HTTP: Direct HTTP request/response communication with server-sent events

## K8s Deployment

* Download and update the `javelin-charts` into local

```bash
helm repo add javelin-charts "https://highflame-ai.github.io/charts"
helm repo update javelin-charts && helm search repo javelin-charts
```

* Create a `value.yaml` file for the helm deployment

```code
image:
  repository: "ghcr.io/highflame-ai/release-javelin-overwatch"
  pullPolicy: Always
  # Overrides the image tag with a specific version.
  tag: "latest"

imagePullSecrets:
  - name: javelin-registry-secret

secrets:
  enabled: true
  secretData:
    JAVELIN_URL: 'https://be-domain/v1'
    JAVELIN_API_KEY: '${JAVELIN_API_KEY}'
```

* Deploy the `javelin-overwatch` to the kubernetes cluster

```bash
kubectl create ns javelin-overwatch
helm upgrade --install javelin-overwatch javelin-charts/javelin-overwatch \
    --namespace javelin-overwatch \
    -f value.yaml --timeout=10m
```

## 🚀 Bare Metal Deployment Guide : `javelin-overwatch`

This guide explains how to install and run **javelin-overwatch** on a bare metal machine or VM.  
It is designed for first-time users of Javelin, just follow the steps in order.  

---

### 1. Download the Artifact

The **javelin-overwatch** service is distributed as a prebuilt binary. You need to download the correct binary for your system architecture.  

- Visit the [javelin-overwatch releases page](https://github.com/highflame-ai/javelin-overwatch/releases).  
- Select the **latest release**.  
- Under **Assets**, you’ll find binaries for multiple architectures. Currently, we support:
  - `amd64` → For most Linux servers and VMs (AWS EC2, GCP, Azure, bare metal servers).  
  - `arm64` → For ARM-based systems (AWS Graviton, Raspberry Pi, ARM servers).  

#### Example: Download for `amd64`
```bash
# Replace VERSION with the release tag (e.g., v0.0.2)
wget https://github.com/highflame-ai/javelin-overwatch/releases/download/VERSION/javelin-overwatch-linux-amd64
```

1. If the above command fails (for example, if the repo is private), you can manually download the binary by clicking on the artifact in the GitHub release page from your local machine.

2. Once downloaded locally, transfer it to your VM using scp

```bash
scp javelin-overwatch-linux-amd64 ubuntu@<your-vm-ip>:/home/ubuntu/
```

#### Set executable permission

```bash
chmod +x javelin-overwatch-linux-amd64
sudo mv javelin-overwatch-linux-amd64 /usr/local/bin/javelin-overwatch
```

### 2. Install and Configure Supervisor 

#### 2.1 Install supervisor

```bash
sudo apt update
sudo apt install supervisor -y
```

#### 2.2 Create supervisor config

Create /etc/supervisor/conf.d/javelin-overwatch.conf:

```bash
[program:javelin-overwatch]
directory=/usr/local/bin                    ; path where binary will live
command=/usr/local/bin/javelin-overwatch --enable-javelin
autostart=true                              ; start on boot
autorestart=true                            ; restart if it crashes
stderr_logfile=/var/log/javelin-overwatch.err.log
stdout_logfile=/var/log/javelin-overwatch.out.log
environment=JAVELIN_URL="https://your-gateway-domain/v1",JAVELIN_API_KEY="your-gateway-api-key"
user=root                                   ; run as root (sudo equivalent)
```

Before running the service, configure the following environment variables:

**JAVELIN_URL** → Base URL of your Javelin Core deployment (typically ends with /v1).

**JAVELIN_API_KEY** → Your API Key for authenticating with the Javelin Gateway.

By default, javelin-overwatch will automatically provision an **MCP Overwatch application** (mcp_overwatch) in your Javelin Gateway when started if it doesn't already exist.


#### 2.3 Reload supervisor and start the service

```
sudo supervisorctl reread
sudo supervisorctl update
sudo supervisorctl start javelin-overwatch
```

### 3. Verify the deployment

1. Check service status (`sudo supervisorctl status javelin-overwatch`)
2. Verify the logs  (e.g. `tail -f /var/log/javelin-overwatch.out.log`)
3. Explore traffic live visibility on your gateway traces or in the application's chronicle tab. 


### 4. Setup: MCP client that calls DeepWiki

1. Below is a minimal Python client that calls the `read_wiki_structure` tool on the DeepWiki MCP. Save as deepwiki_call_read_structure.py (or a name you prefer).

2. `python deepwiki_call_read_structure.py --repo "highflame-ai/ramparts"` Use this command to run the deepwiki client/ 

```python
#!/usr/bin/env python3
"""
- Install python env
- Install httpx
- Install mcp 

Call read_wiki_structure on DeepWiki MCP (minimal, fixed factory)

Usage:
  python3 deepwiki_call_read_structure.py --repo "github.com/highflame-ai/ramparts" \
      [--bearer ABC123] [--transport http|sse]

Defaults:
  endpoint: https://mcp.deepwiki.com/mcp
  transport: http (streamable HTTP)
"""
import argparse
import asyncio
import json
import logging
from typing import Any, Dict, Optional

import httpx
from mcp import ClientSession
from mcp.client.sse import sse_client
from mcp.client.streamable_http import streamablehttp_client


ENDPOINT_DEFAULT = "https://mcp.deepwiki.com/mcp"
TOOL_NAME = "read_wiki_structure"


def httpx_client_factory_factory(bearer_from_cli: Optional[str] = None, verify_tls: bool = True):
    """
    Returns a factory function matching the signature expected by streamablehttp_client:
      factory(headers=None, timeout=None, auth=None, **kwargs) -> httpx.AsyncClient
    """

    def factory(headers: Optional[Dict[str, str]] = None, timeout: Optional[Any] = None, auth: Optional[Any] = None, **kwargs) -> httpx.AsyncClient:
        client_kwargs: Dict[str, Any] = {
            "follow_redirects": True,
            "verify": verify_tls,
        }

        # honor provided timeout (httpx.Timeout object or numeric); fallback to 30s
        client_kwargs["timeout"] = timeout if timeout is not None else 30.0

        # Merge headers: transport headers (if any) + bearer_from_cli header
        merged_headers: Dict[str, str] = {}
        if headers:
            merged_headers.update(headers)
        if bearer_from_cli:
            # only set Authorization if not already set by transport
            merged_headers.setdefault("Authorization", f"Bearer {bearer_from_cli}")
        if merged_headers:
            client_kwargs["headers"] = merged_headers

        if auth is not None:
            client_kwargs["auth"] = auth

        return httpx.AsyncClient(**client_kwargs)

    return factory


async def call_read_wiki_structure_over_http(endpoint: str, headers: Dict[str, str], factory, repo: str):
    async with streamablehttp_client(endpoint, httpx_client_factory=factory) as (read_stream, write_stream, _):
        async with ClientSession(read_stream, write_stream) as session:
            await session.initialize()
            result = await session.call_tool(TOOL_NAME, {"repoName": repo})
            return result


async def call_read_wiki_structure_over_sse(endpoint: str, repo: str):
    async with sse_client(endpoint) as (read_stream, write_stream):
        async with ClientSession(read_stream, write_stream) as session:
            await session.initialize()
            result = await session.call_tool(TOOL_NAME, {"repo": repo})
            return result


def pretty_print_result(result):
    try:
        # If Pydantic-like model with model_dump()
        print(json.dumps(result.model_dump(), indent=2))  # type: ignore[attr-defined]
    except Exception:
        # Fallback: let json try to serialize, else print repr
        try:
            print(json.dumps(result, default=str, indent=2))
        except Exception:
            print(repr(result))


async def main_async(args):
    endpoint = args.url
    repo = args.repo
    bearer = args.bearer
    transport = args.transport.lower()

    # Prepare factory that accepts (headers, timeout, auth, **kwargs)
    factory = httpx_client_factory_factory(bearer_from_cli=bearer, verify_tls=not args.insecure)

    if transport == "http":
        result = await call_read_wiki_structure_over_http(endpoint, {}, factory, repo)
    elif transport == "sse":
        result = await call_read_wiki_structure_over_sse(endpoint, repo)
    else:
        raise SystemExit("transport must be 'http' or 'sse'")

    pretty_print_result(result)


def parse_args():
    p = argparse.ArgumentParser(description="Call read_wiki_structure on DeepWiki MCP")
    p.add_argument("--url", default=ENDPOINT_DEFAULT, help="MCP endpoint (default: https://mcp.deepwiki.com/mcp)")
    p.add_argument("--repo", required=True, help="Repo identifier (e.g. github.com/org/repo)")
    p.add_argument("--bearer", help="Bearer token for Authorization header")
    p.add_argument("--transport", choices=["http", "sse"], default="http", help="Transport (http or sse)")
    p.add_argument("--insecure", action="store_true", help="Disable TLS verification (useful for self-signed certs)")
    return p.parse_args()


if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s", datefmt="%H:%M:%S")
    args = parse_args()
    try:
        asyncio.run(main_async(args))
    except Exception as exc:
        logging.exception("Error during MCP call: %s", exc)
        raise
```
