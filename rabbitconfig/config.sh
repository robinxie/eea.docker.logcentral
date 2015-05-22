#!/bin/sh

# Wait for the broker API
while ! curl --silent --max-time 3 "${BROKER}:15672/api"; do sleep 3; done

# Delete any old exchange
curl -XDELETE --silent -u 'guest:guest' \
    "${BROKER}:15672/api/exchanges/%2F/logging.gelf"

# Create the exchange logging.gelf exchange
curl -XPUT --silent -H 'content-type:application/json' -u 'guest:guest' \
    "${BROKER}:15672/api/exchanges/%2F/logging.gelf" \
    -d '{"type": "fanout", "durable": true}'
echo "Created exchange"

# Bind it to the log-messages queue
curl -XPOST --silent -H 'content-type:application/json' -u 'guest:guest' \
    "${BROKER}:15672/api/bindings/%2F/e/logging.gelf/q/log-messages/" \
    -d '{"routing_key":"#", "arguments":{}}'
echo "Created binding"
