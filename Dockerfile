# Glama starts the server in this image to list its tools and prompts. People
# install it with uv instead (see the README); nothing here is needed for that.
FROM ghcr.io/astral-sh/uv:python3.13-bookworm-slim
RUN uv tool install https://github.com/r28ai/shopify-ops-mcp/releases/download/v0.1.0/shopify_ops_mcp-0.1.0-py3-none-any.whl
ENV PATH="/root/.local/bin:$PATH"
ENTRYPOINT ["shopify-ops-mcp"]
