echo "inside entrypoint file"

# Files for which configuration needs to change
SERVER_DIR=janusgraph-0.4.0-hadoop2/
PROPS=${SERVER_DIR}/conf/gremlin-server/janusgraph-cassandra.properties
GREMLIN_CONF=${SERVER_DIR}/conf/gremlin-server/gremlin-server.yaml

export JAVA_OPTIONS=${JAVA_OPTIONS:- -Xms512m -Xmx1400m}
echo "Proceeding with JAVA_OPTIONS=$JAVA_OPTIONS"

if [ -n "$REST" -o "$REST" == "1" ]; then
    echo "replace channelizer as http"
    sed -i.bckp 's#channelizer: .*#channelizer: org.apache.tinkerpop.gremlin.server.channel.HttpChannelizer#' ${GREMLIN_CONF}
fi

echo "replace graph property"
sed -i.bckp 's#conf/gremlin-server/janusgraph-cql-es-server.properties#conf/gremlin-server/janusgraph-cassandra.properties#' ${GREMLIN_CONF}

if [ -n "$CASSANDRA_SERVICE" ]; then
    sed -i.bckp 's#storage.hostname=.*#storage.hostname='${CASSANDRA_SERVICE}'#' ${PROPS}
fi

cd ${SERVER_DIR}

exec bin/gremlin-server.sh conf/gremlin-server/gremlin-server.yaml
