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
sudo docker exec -it elk /opt/logstash/bin/logstash --path.data /tmp/logstash/data \
    -e 'input { stdin { } } output { elasticsearch { hosts => ["localhost"] } }'
```
Wait for something like `The stdin plugin is now waiting for input:`. Then add some logs. Whatever you type becomes a log in logstash.
```
demo log entry
```

Check that it shows up in ES by hitting `http://localhost:9200/logstash-*/_search?pretty&size=1000`. It should show up somewhere in one of the entries. (This will get records from indices that start with logstash-*).

## Setup Filebeat

### Container directory organization
#### elk container
- logstash configs (e.g., beats-input.conf): `/etc/logstash/conf.d`
- logstash binaries: /opt/logstash/bin/

#### filebeat container
- `filebeat.yml` lives at `/usr/share/filebeat/filebeat.yml`

Note that the filebeat host and port have to be set on both the filebeat.yml in the filebeat container as well as in the logstash conf `beats-input.conf` file in the `elk` container, or else will get:
- Port where logstash is listening for beats input is set in `beats-input.conf`
- Port where beats is sending it to is set in filebeat.yml
```
Failed to connect to backoff(async(tcp://filebeat:5044)): dial tcp 172.23.0.3:5044: connect: connection refused
```
This will appear in filebeat logs.

### Instructions/References
- Following [these instructions](https://elk-docker.readthedocs.io/#forwarding-logs-filebeat) might be helpful. But using the official ES filebeat image for now.
- Could do a [volume based config system](https://www.elastic.co/guide/en/beats/filebeat/current/running-on-docker.html#_volume_mounted_configuration), but we want to be consistent across envs without any additional setup, so do it within docker

### Sample Scripts
#### Throw it some C* logs from host
```
docker cp /var/log/cassandra/ filebeat:/var/log/cassandra/
```

### Change the config and restart
Easiest right now is just to rebuild
```
docker-compose up --build -d
```
Then will need to throw it some logs again, since everything else was reset. See that `docker cp` script above for how

#### NOTE: Can't just copy in a new yml and restart
This WON'T work, since need to change permissions (see the `Dockerfile.filebeat` example of what needs to be ran for the proper permissions to be set on the filebeat.yml file)
```
docker cp filebeat.yml filebeat:/usr/share/filebeat/filebeat.yml
docker restart filebeat
```
