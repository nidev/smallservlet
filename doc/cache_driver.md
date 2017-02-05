This document describes 'Cache driver' for ServletEngine.

# Concept
SmallServlet will dynamically execute Dart files when a request is made from clients.

Executing codes costs CPU times and makes response time longer. Thus, caching is required for speeding up response. SmallServlet stores reponse data based on request data. For example, if there is a request of which URL path is '/foo/bar/', the program will do two things.

1. Sends response to client
2. Stores response data to cache memory

By doing so, time for first responding is as same as usual, but next request will be responded very shortly. This caching model will be effective at RESTful GET request.

## Caching Pattern
Engine will consider:

1. URL
2. Path
3. Query string (parameters)

Engine will not consider:

1. Useragent
2. HTTP Session
3. Protocol (HTTP/HTTPS)

## Key-value storage
Cache driver can be backed with various key-value storage program. See [Redis](#redis) section for detail information.

## Lifetime
If lifetime of an item is expired, it becomes invalid item and execute servlet to obtain refreshed data. Lifetime control algorithm depends on implementation of each driver.

# Available drivers
SmallServlet provides two drivers for default installation.

## nocache
This is a very default driver. It does nothing. Every request makes new responses.

## redis<a name="redis"></a>
This driver is backed by Redis, with lifetime control. Simply it stores response data to Redis. When a request is repeated in same pattern, stored data are provided instead of excuting servlet.

Password authentication is supported.
