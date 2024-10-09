# Use your existing Kafka Connect image as the base
FROM 237489059256.dkr.ecr.us-west-2.amazonaws.com/cricut-kafka-connect-elasticsearch:14.1.1-rhel8.3

# Switch to root user to install jq
USER root

# Install jq
RUN yum install -y jq

# Switch back to appuser (default user of the base image)
USER appuser
