#!/bin/bash -eux

if [ "$BASH" != "/bin/bash" ]; then
  echo "Please do ./$0"
  exit 1
fi

scripts_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
project_path=$scripts_path/..

# rebuild only filebeat container from scratch, leaving elk container alone. 
# Nukes the logs that were in the container though, so will have to add logs back in if we want to test our new config. 
# (Does not remove records from ES though)
cd $project_path && \
docker-compose up --build -d filebeat 

# this copies sample logs over
docker cp $project_path/example-logs/ filebeat:/var/log/cassandra/
# copy cassandra logs over instead
docker cp /var/log/cassandra/ filebeat:/var/log/cassandra/

# follow logs without appending (though appending provides nice colors!)
docker logs -f filebeat
