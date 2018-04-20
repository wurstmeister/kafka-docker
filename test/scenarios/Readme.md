Scenarios (end-to-end tests)
============================

These tests are supposed to test the configuration of indivdiual features

TODO:
-----

-	SSL (Client + Broker)
-	Security

Done:
-----

-	JMX

Executing tests
---------------

These tests should spin up required containers for full end-to-end testing and exercise required code paths, returing zero exit code for success and non-zero exit code for failure.

### JMX

```
cd test/scenarios
./runJmxScenario.sh
```
