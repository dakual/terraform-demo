import sys, ssl, os, time, datetime
import logging, traceback
import paho.mqtt.client as mqtt
import certifi

endpoint = os.getenv('AWS_IOT_ENDPOINT')
clientid = "myDevice1"
topic    = "topic/test"

ca       = "./certs/cacert.pem" 
cert     = "./certs/certificate.pem.crt"
private  = "./certs/private.pem.key"

logger = logging.getLogger()
logger.setLevel(logging.DEBUG)
handler = logging.StreamHandler(sys.stdout)
log_format = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
handler.setFormatter(log_format)
logger.addHandler(handler)

def ssl_alpn():
    try:
        logger.info("open ssl version:{}".format(ssl.OPENSSL_VERSION))
        ssl_context = ssl.create_default_context()
        ssl_context.set_alpn_protocols(["x-amzn-mqtt-ca"])
        ssl_context.load_verify_locations(cafile=ca)
        ssl_context.load_cert_chain(certfile=cert, keyfile=private)

        return  ssl_context
    except Exception as e:
        print("exception ssl_alpn()")
        raise e

if __name__ == '__main__':
    try:
        mqttc = mqtt.Client(clientid)
        ssl_context = ssl_alpn()
        mqttc.tls_set_context(context=ssl_context)
        logger.info("Connecting...")
        mqttc.connect(endpoint, port=8883)
        logger.info("Successfully connected!")
        mqttc.loop_start()

        while True:
            now = datetime.datetime.now().strftime('%Y-%m-%dT%H:%M:%S')
            logger.info("try to publish:{}".format(now))
            mqttc.publish(topic, now)
            time.sleep(1)

    except Exception as e:
        traceback.print_exc(file=sys.stdout)