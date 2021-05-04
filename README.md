# Kokuwa IoT Mock Server

## What is in

This is a little helper for mocking REST Apis provided by IoT devices that are discoverable 
via mDNS. 
So it is a combination of an mDNS server [Avahi](https://avahi.org) and [MockServer](https://www.mock-server.com/), that simulates REST based services for testing purposes.
It is provided as a docker image that can be used in various integration test scenarios.

## Why

The main use case behind is the simulation of IoT devices that provides APIs and can be discovered via mDNS in integration tests.

## How to use

### Concept

The idea behind is simple: 
1. Configure the mDNS as your device will do 
1. Give an OpenAPI file that describes the API of your device
1. Run the simulator

For doing so there is one volume where you can put your configurations in. 

To try it out you can change this via environment to Petstore:
```shell
docker pull ghcr.io/kokuwaio/iot-mock:0.2
docker run -it --rm -e "MOCKDATA_PATH=/petstore" ghcr.io/kokuwaio/iot-mock:0.2
```
So we will offer the [PetStore](https://github.com/OAI/OpenAPI-Specification/blob/main/examples/v3.0/petstore.yaml) example from OpenAPI.

To put your custom definitions in, simply mount a folder with two files to /mockdata like:
```shell
docker pull ghcr.io/kokuwaio/iot-mock:0.2
docker run -it --rm -v `pwd`/mockdata:/mockdata ghcr.io/kokuwaio/iot-mock:0.2
```
The folder should contain two files, like:

* mockdata/
  * ```mdns.service``` - The [Avahi service](https://linux.die.net/man/5/avahi.service) configuration.
  * ```openapi.yaml``` - The [OpenAPI](https://spec.openapis.org/) specification.

### In JUnit with Testcontainers

The main intention during developing this mock server was the usage inside of java integration tests with help of [Testcontainers](https://www.testcontainers.org/).
So how can it be used inside of integration tests?

```java
...
private static final String SERVICE_HOST_NAME = "petstore-001";
    
// Create new docker network to isolate test runs
private Network network = Network.newNetwork();

/**
 * Create a new docker container via testcontainers and the correct tag of this image.
 */
@Container
public GenericContainer iotMock = new GenericContainer<>("ghcr.io/kokuwaio/iot-mock:0.1")
    // Add our avahi service configuration to the container
    .withCopyFileToContainer(MountableFile.forClasspathResource("mdns.service"), "/mockdata/")
    // insert the openapi sec into the container
    .withClasspathResourceMapping("openapi.yaml", "/mockdata/openapi.yaml", BindMode.READ_ONLY)
    // attach to our dedicated network (optional)
    .withNetwork(network)
    // Set the containers hostname to our expected hostname (optional)
    .withCreateContainerCmdModifier(cmd -> cmd.withHostName(SERVICE_HOST_NAME))
    // set the network alias to the expected hostname (optional)
    .withNetworkAliases(SERVICE_HOST_NAME)
    // configure avahi with the expected host name 
    .withEnv("SERVER_HOST_NAME", SERVICE_HOST_NAME)
    // configure avahi with the expected domain (optional)
    .withEnv("SERVER_DOMAIN_NAME", "local")
    // Configure the port where mockserver should be available. Must fit to mDNS service configuration. (optional, default 8080)
    .withEnv("API_PORT", "8080");
```
Check the very good documentations of [Testcontainers](https://www.testcontainers.org/) and [MockServer](https://www.mock-server.com/) for further usage details.

Happy testing!