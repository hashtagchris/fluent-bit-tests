## azure_logs_ingestion output plugin

https://docs.fluentbit.io/manual/data-pipeline/outputs/azure_logs_ingestion

### Testing

#### Set up webhook.site running locally

```
gh repo clone webhooksite/webhook.site
cd webhook.site
docker compose up -d
open http://127.0.0.1:8084
```

#### Update dce_url

Grab the unique url from webhook.site (e.g. `http://127.0.0.1:8084/50ba9c8c-1969-4008-842c-c15c7eed250d`) and update dce_url to match.

#### Update client secret

Go to your Microsoft Entra App and create a new client secret. Copy the client secret into the config file where it says `REDACTED`.

Example URL: https://portal.azure.com/#view/Microsoft_AAD_RegisteredApps/ApplicationMenuBlade/~/Credentials/appId/0f072706-8adb-4344-b6f6-7431a0631fbc/objectId/1a3fea35-6fd1-40b5-a773-af683cfd8a8d/isMSAApp~/false/defaultBlade/Overview/appSignInAudience/AzureADMyOrg/servicePrincipalCreated~/true

#### Run the test

```
fluent-bit -c ./fluent-bit.yaml
```

#### Inspect the webhooks

### Results

```
POST http://127.0.0.1:8084/50ba9c8c-1969-4008-842c-c15c7eed250d/dataCollectionRules/cafecafe-0000-0000-0000-000000000000/streams/Custom-table_foo?api-version=2021-11-01-preview

[{"TimeGenerated":"2026-02-17T21:52:55.683Z","message":"custom dummy"}]
```

#### time_generated config setting

Based on testing, `time_generated: false` sends epoch second values:

```
[{"@timestamp":1771365703.171309,"message":"custom dummy"}]
```

And `time_generated: true` sends ISO 8601 values:

```
[{"@timestamp":"2026-02-17T22:02:18.552Z","message":"custom dummy"}]
```
