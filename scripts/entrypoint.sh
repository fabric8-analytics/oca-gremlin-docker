echo "inside entrypoint file"

# Files for which configuration needs to change
SERVER_DIR=janusgraph-0.4.0-hadoop2/
PROPS=${SERVER_DIR}/conf/gremlin-server/janusgraph-cassandra.properties
GREMLIN_CONF=${SERVER_DIR}/conf/gremlin-server/gremlin-server.yaml

export JAVA_OPTIONS=${JAVA_OPTIONS:- -Xms512m -Xmx1400m}
echo "Proceeding with JAVA_OPTIONS=$JAVA_OPTIONS"

sed -i.bckp 's#consoleReporter: .*#consoleReporter: {enabled: false}, #' ${GREMLIN_CONF}
sed -i.bckp 's#csvReporter: .*#csvReporter: {enabled: false}, #' ${GREMLIN_CONF}
sed -i.bckp 's#jmxReporter: .*#jmxReporter: {enabled: false}, #' ${GREMLIN_CONF}
sed -i.bckp 's#slf4jReporter: .*#slf4jReporter: {enabled: false}, #' ${GREMLIN_CONF}
sed -i.bckp 's#gangliaReporter: .*#gangliaReporter: {enabled: false}, #' ${GREMLIN_CONF}
sed -i.bckp 's#graphiteReporter: .*#graphiteReporter: {enabled: false}} #' ${GREMLIN_CONF}

if [ -n "$REST" -o "$REST" == "1" ]; then
    echo "replace channelizer as http"
    sed -i.bckp 's#channelizer: .*#channelizer: org.apache.tinkerpop.gremlin.server.channel.HttpChannelizer#' ${GREMLIN_CONF}
fi

echo "replace graph property"
sed -i.bckp 's#conf/gremlin-server/janusgraph-cql-es-server.properties#conf/gremlin-server/janusgraph-cassandra.properties#' ${GREMLIN_CONF}

if [ -n "$CASSANDRA_SERVICE" ]; then
    sed -i.bckp 's#storage.hostname=.*#storage.hostname='${CASSANDRA_SERVICE}'#' ${PROPS}
fi

if [ -n "$CASSANDRA_REPLICATION_FACTOR" ]; then
    sed -i.bckp 's#storage.cql.replication-factor=.*#storage.cql.replication-factor='${CASSANDRA_REPLICATION_FACTOR}'#' ${PROPS}
fi

if [ -n "$RESPONSE_TIMEOUT" ]; then
    sed -i.bckp 's#serializedResponseTimeout: .*#serializedResponseTimeout: '${RESPONSE_TIMEOUT}'#' ${GREMLIN_CONF}
fi

if [ -n "$SCRIPT_EVALUATION_TIMEOUT" ]; then
    sed -i.bckp 's#scriptEvaluationTimeout: .*#scriptEvaluationTimeout: '${SCRIPT_EVALUATION_TIMEOUT}'#' ${GREMLIN_CONF}
fi

if [ -n "$GREMLIN_POOL" ]; then
    sed -i.bckp 's#gremlinPool: .*#gremlinPool: '${GREMLIN_POOL}'#' ${GREMLIN_CONF}
fi

if [ -n "$THREAD_POOL" ]; then
    sed -i.bckp 's#threadPoolWorker: .*#threadPoolWorker: '${THREAD_POOL}'#' ${GREMLIN_CONF}
fi

cd ${SERVER_DIR}

exec bin/gremlin-server.sh conf/gremlin-server/gremlin-server.yaml
