# Shopify Store Ops

Low-stock reorders, where-is-my-order replies, daily sales digests and catalogue imports.

An MCP server with **12 workflows** across Shopify, Google Sheets, Gmail, Slack, Firecrawl, Linear and Stripe. Each workflow is a prompt your agent runs as a slash command, over the 26 tools it needs and no others.

```bash
uv tool install https://github.com/r28ai/shopify-ops-mcp/releases/download/v0.1.0/shopify_ops_mcp-0.1.0-py3-none-any.whl
claude mcp add shop -- shopify-ops-mcp
```

It installs with [uv](https://docs.astral.sh/uv/) from this repository's release, with no git and nothing to build; nothing but Charter and the libraries it uses comes from PyPI. To update, run the install line from the [latest release](https://github.com/r28ai/shopify-ops-mcp/releases/latest). If a desktop app cannot find `shopify-ops-mcp`, give it the full path from `which shopify-ops-mcp` (`where shopify-ops-mcp` on Windows).

Then ask your agent to **connect your apps**, or run `/mcp__shop__setup`.

## Connect your apps

Ask the agent to connect one ("connect Linear"). It tells you where to get that app's key and the command that stores it, and the next call works, with no restart. The agent never asks for a key in the chat.

Or connect everything this server uses from a terminal:

```bash
shopify-ops-mcp login            # each app in turn
shopify-ops-mcp login shopify    # just one
shopify-ops-mcp status           # what is connected
```

Tokens and keys go to your operating system's keychain (macOS Keychain, Windows Credential Manager, the Secret Service on Linux), and are checked with one read-only call to the app's own API before they are kept. Every key, token and OAuth client is yours: we register no app with any of these services, and nothing passes through a server of ours, because there isn't one.

| App | How it connects | Or set |
|---|---|---|
| Shopify | Your own key ([get one](https://dev.shopify.com/dashboard)), entered once. | `SHOPIFY_SHOP`, `SHOPIFY_CLIENT_ID`, `SHOPIFY_CLIENT_SECRET` |
| Google | Browser sign-in, over your own OAuth client ([make one](https://docs.r28.ai/charter/auth/setup/google)). | `GOOGLE_CLIENT_ID`, `GOOGLE_CLIENT_SECRET` |
| Slack | Your own key ([get one](https://docs.r28.ai/charter/auth/setup/slack)), entered once. A bot token from your own Slack app, which the guide sets up in about three minutes. | `SLACK_BOT_TOKEN` |
| Firecrawl | Your own key ([get one](https://www.firecrawl.dev/app/api-keys)), entered once. | `FIRECRAWL_API_KEY` |
| Linear | Your own key ([get one](https://linear.app/settings/account/security)), entered once. | `LINEAR_API_KEY` |
| Stripe | Your own key ([get one](https://dashboard.stripe.com/apikeys)), entered once. | `STRIPE_API_KEY` |

A variable set in your client's config always wins over the keychain.

## Workflows

| Workflow | What you get | Apps |
|---|---|---|
| **Low stock → supplier PO draft** <br>`low_stock_to_supplier_po_draft` | Reorders drafted before a bestseller goes out of stock. | Shopify, Google Sheets, Gmail |
| **Daily sales digest** <br>`daily_sales_digest` | Yesterday's orders, revenue and top products, posted and logged. | Shopify, Google Sheets, Slack |
| **Where-is-my-order replies** <br>`where_is_my_order_replies` | The commonest support email answered with the actual fulfillment status. | Gmail, Shopify |
| **Competitor product price watch** <br>`competitor_product_price_watch` | A competitor undercuts a SKU and you see both prices side by side. | Firecrawl, Shopify, Slack |
| **Supplier sheet → new products** <br>`supplier_sheet_to_new_products` | A season's catalogue goes from spreadsheet to store draft in one run. | Google Sheets, Shopify, Slack |
| **Product copy from the supplier's page** <br>`product_copy_from_the_supplier_s_page` | Specs and materials pulled from the manufacturer, written as your listing. | Firecrawl, Shopify |
| **Wholesale order by email → draft order** <br>`wholesale_order_by_email_to_draft_order` | B2B buyers email a list and get an invoice link back. | Gmail, Shopify |
| **Cancellation request handled** <br>`cancellation_request_handled` | Unfulfilled orders cancelled on request with the confirmation drafted. | Gmail, Shopify |
| **VIP customer outreach** <br>`vip_customer_outreach` | Top spenders get a personal note before a launch, not a blast. | Shopify, Google Sheets, Gmail |
| **Fulfillment exceptions** <br>`fulfillment_exceptions` | Orders unfulfilled after 48 hours become an ops issue with the order attached. | Shopify, Linear, Slack |
| **Stock count from a sheet** <br>`stock_count_from_a_sheet` | The warehouse's count becomes the store's inventory without manual edits. | Google Sheets, Shopify |
| **Shopify + Stripe revenue in one sheet** <br>`shopify_and_stripe_revenue_in_one_sheet` | Stores selling in two places see one revenue number. | Shopify, Stripe, Google Sheets |

Every prompt takes one optional argument, `details`: the repo, team, channel, customer or date range you mean, so the agent does not have to ask. In Claude Code, put it in quotes, or only its first word arrives:

```
/mcp__shop__low_stock_to_supplier_po_draft "anything under 10 units, supplier sheet 'POs'"
```

Reads run without asking. Before anything that creates, sends, changes or deletes, the prompt tells the agent to show you the call and wait.

3 of the 12 workflows need no Google or Granola credential.

## Other clients

**Claude Desktop**: install [uv](https://docs.astral.sh/uv/getting-started/installation/) if you have not, since Claude Desktop starts the server with it, then open the `.mcpb` from the [latest release](https://github.com/r28ai/shopify-ops-mcp/releases/latest). Claude asks for any keys in its own settings and keeps them in your keychain. The first start takes a few seconds longer, while uv installs it.

**VS Code** (`.vscode/mcp.json`): VS Code asks for each key the first time the server starts and stores it securely. Leave out any you stored with `login`.

```json
{
  "inputs": [
    {
      "type": "promptString",
      "id": "shopify-client-secret",
      "description": "Shopify: App client secret",
      "password": true
    },
    {
      "type": "promptString",
      "id": "google-client-secret",
      "description": "Google: OAuth client secret",
      "password": true
    },
    {
      "type": "promptString",
      "id": "slack-bot-token",
      "description": "Slack: Bot token (xoxb-\u2026)",
      "password": true
    },
    {
      "type": "promptString",
      "id": "firecrawl-api-key",
      "description": "Firecrawl: API key",
      "password": true
    },
    {
      "type": "promptString",
      "id": "linear-api-key",
      "description": "Linear: Personal API key",
      "password": true
    },
    {
      "type": "promptString",
      "id": "stripe-api-key",
      "description": "Stripe: Secret or restricted key",
      "password": true
    }
  ],
  "servers": {
    "shop": {
      "type": "stdio",
      "command": "shopify-ops-mcp",
      "env": {
        "SHOPIFY_CLIENT_SECRET": "${input:shopify-client-secret}",
        "GOOGLE_CLIENT_SECRET": "${input:google-client-secret}",
        "SLACK_BOT_TOKEN": "${input:slack-bot-token}",
        "FIRECRAWL_API_KEY": "${input:firecrawl-api-key}",
        "LINEAR_API_KEY": "${input:linear-api-key}",
        "STRIPE_API_KEY": "${input:stripe-api-key}",
        "SHOPIFY_SHOP": "",
        "SHOPIFY_CLIENT_ID": "",
        "GOOGLE_CLIENT_ID": ""
      }
    }
  }
}
```

**Cursor** (`.cursor/mcp.json`) starts it the same way:

```json
{
  "mcpServers": {
    "shop": {
      "command": "shopify-ops-mcp"
    }
  }
}
```

**Codex** (`~/.codex/config.toml`) starts a turn without waiting for a server unless it is `required`, and then the agent has none of its tools. `required = true` makes the session wait for it, and `startup_readiness = "catalog"` waits for its tool list rather than just its connection:

```toml
[mcp_servers.shop]
command = "shopify-ops-mcp"
required = true
startup_readiness = "catalog"
startup_timeout_sec = 30
```

Name the server `shop`. A host builds each tool's name from that key, and a longer one can push a tool past the 64 characters a function name allows.

## Built with Charter

Every tool here is a [Charter](https://github.com/r28ai/charter) declaration: a Pydantic schema saying where each field goes on the wire. Charter's runtime builds the request, attaches and refreshes the credential, and trims the response before the model reads it. It runs in your process, with no proxy and no telemetry.

The 26 tool schemas come to 25,389 tokens.

The same tools work in your own agent, without MCP:

```python
from charter.adapters.openai import to_openai_tools
from charter_packs_mcp import FAMILIES

tools = FAMILIES["commerce"].tools()
definitions = to_openai_tools(tools)   # or charter.adapters.langchain
```

Need an API that isn't here? [Write a pack](https://docs.r28.ai/charter/start/coding-agents): your coding agent writes the declarations, and Charter's conformance suite checks them.

<details>
<summary>All 26 tools</summary>

- **Shopify**: `shopify_products_list`, `shopify_variant_inventory_level`, `shopify_orders_list`, `shopify_order_fulfillment_orders`, `shopify_product_get`, `shopify_product_create`, `shopify_product_variants_bulk_create`, `shopify_product_update`, `shopify_customers_list`, `shopify_draft_order_create`, `shopify_order_get`, `shopify_order_cancel`, `shopify_locations_list`, `shopify_inventory_adjust_quantities`
- **Google Sheets**: `gsheets_spreadsheets_values_append`, `gsheets_spreadsheets_values_get`, `gsheets_spreadsheets_values_update`
- **Gmail**: `gmail_drafts_create`, `gmail_threads_list`, `gmail_threads_get`
- **Slack**: `slack_chat_post_message`
- **Firecrawl**: `firecrawl_monitor_create`, `firecrawl_extract`, `firecrawl_scrape`
- **Linear**: `linear_issue_create`
- **Stripe**: `stripe_balance_transactions_list`

</details>

## License

Apache 2.0.
