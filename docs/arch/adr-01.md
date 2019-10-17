# ADR 1: Choosing JSON:API for resource representation and the library to implement it.

October 17, 2019

## Context

We need to serialize resources in a consistent manner for RESTful APIs.
In the past we've chosen [JSON:API](https://jsonapi.org/) to represent these resources, e.g. [Panoptes API](https://github.com/zooniverse/panoptes), [Talk API](https://github.com/zooniverse/talk-api) use an older version of the JSON:API spec.
Both of the above use [RestPack Serializer](https://github.com/RestPack/restpack_serializer) to handle the mechanisms for conforming to an early 
Other projects like the [Education API](https://github.com/zooniverse/education-api) used Active Model Serializers to implement the JSON:API spec.

## Decision

We will implement JSON:API for resource represenation in this API. 
We will use the https://github.com/stas/jsonapi.rb library to implement JSON:API, as outlined in https://github.com/zooniverse/tove/pull/8

Some other alternatives were considered, https://github.com/rails-api/active_model_serializers#alternatives

Specifically `JSON::Resources` was [ruled out](https://github.com/zooniverse/tove/pull/8#issuecomment-542755779) due to heavy use of DSLs and boilerplate code. 
Other alternatives like http://jsonapi-rb.org/ may have been considered

## Status

Accepted and implemented in https://github.com/zooniverse/tove/pull/8

## Consequences

Adopting this library comes with [some risk](https://github.com/zooniverse/tove/pull/8#pullrequestreview-302580084) for long term maintenance.
It is a new library without broad adoption in the community (unlike `jsonapi-rb`).
However new the library has a fairly small footprint and wraps other bigger more stable and maintained libaries, [Fast JSON API](https://github.com/Netflix/fast_jsonapi) and [Ransack](https://github.com/activerecord-hackery/ransack).
