#!/bin/bash

# Start Kafka Connect in the background
/etc/confluent/docker/run & 
KAFKA_CONNECT_PID=$!  # Capture the process ID of the Kafka Connect task

# Use environment variables to construct the Kafka Connect URL
CONNECT_URL="http://${CONNECT_REST_ADVERTISED_HOST_NAME}:${CONNECT_REST_PORT}"

echo "Waiting for Kafka Connect to start listening on $CONNECT_URL ⏳"
while [ $(curl -s -o /dev/null -w %{http_code} $CONNECT_URL/connectors) -eq 000 ]; do 
  echo -e $(date) " Kafka Connect listener HTTP state: " $(curl -s -o /dev/null -w %{http_code} $CONNECT_URL/connectors) " (waiting for 200)"
  sleep 5 
done;

echo "Kafka Connect is up! Registering Elasticsearch sink connectors..."

echo "Registering connector with configuration: $ELASTICSEARCH_SINK_CONFIGS"
echo "$ELASTICSEARCH_SINK_CONFIGS" | jq -c '.[]' | while read -r SINK; do
  echo "Registering $SINK"
  curl -X POST -H "Content-Type: application/json" --data "$SINK" $CONNECT_URL/connectors
done

# Now bring Kafka Connect back to the foreground
wait $KAFKA_CONNECT_PID
