# Dev and Prod Orchestration Model

## Dev

Current recommendation:
- `Sitionix Infra` owns shared VM infrastructure and environment runbooks
- service repos may still keep temporary service-specific deploy logic during the transition
- environment-level smoke verification should converge here first

Reason:
- dev needs pragmatism and speed
- shared infra and shared contracts must still have one owner

## Prod later

Target direction:
- `Sitionix Infra` becomes the environment orchestration entry point
- service repos keep build artifacts and service runtime ownership
- prod rollout ordering, shared contracts and environment verification live here

Do not overengineer this now.
The current bootstrap should optimize for the existing VM-based dev stage while leaving a clean upgrade path.
