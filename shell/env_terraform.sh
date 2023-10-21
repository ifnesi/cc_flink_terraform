#!/bin/bash
set -e

# Output JSON result with all internal variables set
CREDIT_CARD_SCHEMA=`cat ./schemas/credit_card_timestamp.avsc`
printf '{
    "MONGODB_ATLAS_PROJECT_ID": "%s",
    "MONGODB_ATLAS_PUBLIC_IP_ADDRESS": "%s",
    "CONFLUENT_CLOUD_API_KEY": "%s",
    "CONFLUENT_CLOUD_API_SECRET": "%s",
    "CREDIT_CARD_SCHEMA": "%s"
}' "$MONGODB_ATLAS_PROJECT_ID" "$MONGODB_ATLAS_PUBLIC_IP_ADDRESS" "$CONFLUENT_CLOUD_API_KEY" "$CONFLUENT_CLOUD_API_SECRET" "$CREDIT_CARD_SCHEMA"
