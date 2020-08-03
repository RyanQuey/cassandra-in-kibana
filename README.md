# Setup

```bash
# actually sets for docker container as well
sudo sysctl -w vm.max_map_count=262144
docker-compose up
```

See [here](https://elk-docker.readthedocs.io/#installation) for more info on how it works.

## Test that it is working
Add a dummy log (see instructions [here](https://elk-docker.readthedocs.io/#usage))
```
# start logstash cli session in docker container
sudo docker exec -it es_elk_1 /opt/logstash/bin/logstash --path.data /tmp/logstash/data \
    -e 'input { stdin { } } output { elasticsearch { hosts => ["localhost"] } }'
```
Wait for something like `The stdin plugin is now waiting for input:`. Then add some logs. Whatever you type becomes a log in logstash.
```
demo log entry
```

Check that it shows up in ES by hitting `http://localhost:9200/_search?pretty&size=1000`. It should show up somewhere in one of the entries

## 

# Forward logs from filebeat
Following [these instructions](https://elk-docker.readthedocs.io/#forwarding-logs-filebeat). 
