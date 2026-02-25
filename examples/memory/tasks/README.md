# Task Memory Index

Use this layer to store result-only task cards for sub-agent work.

Principles:
- Keep raw execution traces in isolated session history.
- Persist only reusable outcomes to reduce token noise.
- Promote stable conclusions to `MEMORY.md` during weekly tidy.

Path convention:
- `memory/tasks/YYYY-MM-DD.md`

Suggested fields per card:
- Goal
- Boundary/Constraints
- Acceptance Criteria
- Key Actions
- Artifact Paths
- Final Status
- Next Step
