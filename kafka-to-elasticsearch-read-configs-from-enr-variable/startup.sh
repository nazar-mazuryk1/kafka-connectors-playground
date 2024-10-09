#!/bin/bash

/etc/confluent/docker/run &
KAFKA_CONNECT_PID=$!

echo "Kafka Connect is running with PID: $KAFKA_CONNECT_PID"

echo "Waiting for Kafka Connect to start listening on kafka-connect ⏳"
while [ $(curl -s -o /dev/null -w %{http_code} http://localhost:8083/connectors) -eq 000 ]; do 
  echo -e $(date) " Kafka Connect listener HTTP state: " $(curl -s -o /dev/null -w %{http_code} http://localhost:8083/connectors) " (waiting for 200)"
  sleep 5 
done;

echo 'Kafka Connect is up! Registering Elasticsearch sink connectors...'
echo "Registering connector with configuration: $ELASTICSEARCH_SINK_CONFIGS"

echo "$ELASTICSEARCH_SINK_CONFIGS" | jq -c '.[]' | while read -r SINK; do
  echo "Registering $SINK"
  curl -X POST -H "Content-Type: application/json" --data "$SINK" http://localhost:8083/connectors
done

# Now bring Kafka Connect back to the foreground
wait $KAFKA_CONNECT_PID
