#!/bin/bash -eux

if [ "$BASH" != "/bin/bash" ]; then
  echo "Please do ./$0"
  exit 1
fi

scripts_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
project_path=$scripts_path/..
kibana_dashboards_path=$project_path/kibana-dashboards

mkdir -p $kibana_dashboards_path

# export, saving config to file 
# relies on the dashboard ID assigned by kibana. However, since we are saving to version control, and will import this dashboard from version control, the ID will stay the same
# https://www.elastic.co/guide/en/kibana/7.8/dashboard-api-export.html
curl "http://localhost:5601/api/kibana/dashboards/export?dashboard=0f78a7c0-d698-11ea-b119-2f546fb0a0d6" > $kibana_dashboards_path/dashboard_0f78a7c0-d698-11ea-b119-2f546fb0a0d6.json

# export all index-patterns
# (not sure how necessary it is, but might as well)
# https://www.elastic.co/guide/en/kibana/7.8/saved-objects-api-export.html#ssaved-objects-api-create-example
curl -X POST http://localhost:5601/api/saved_objects/_export -H 'kbn-xsrf: true' -H 'Content-Type: application/json' -d '
{
  "type": "index-pattern"
}' > $kibana_dashboards_path/index-patterns.json
