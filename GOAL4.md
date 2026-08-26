# Generated BumbleTree Report

- **Authored By:** <enter your name>
- **Generation Timestamp:** 2026-08-27 04:57:01 (UTC+08:00)
- **Mission Topic / Stream:** bluerov torpedo (`/bluerov_torpedo_mission_tree/tree_snapshot`)
- **Total Mission Span:** 259.00s (259 ticks | Max Depth: Level 12)
- **Total Profiled Tree Nodes:** 143
- **Active Display Mode:** Tick Intervals
- **Annotated Comments:** 2

## Run Summary

### Overall Execution Status Breakdown

| Execution Status | Node Count | Ratio | Summary Description |
| :--- | :--- | :--- | :--- |
| **SUCCESS** | 73 | 51.0% | Successfully executed behaviors and branches |
| **FAILURE** | 9 | 6.3% | Behaviors returning failure or failing retry cycles |
| **RUNNING** | 0 | 0.0% | Active async behaviors at snapshot capture |
| **UNVISITED / INACTIVE** | 61 | 42.7% | Unreached subtrees or bypassed selector branches |
| **Total Nodes** | **143** | **100.0%** | Complete behavior tree execution graph |

### Top Time-Consuming Behaviors (Bottleneck Analysis)

| Node Name | Behavioral Type | Status | Self Time | Span Time | Span Ticks | Retries |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `Goto torpedo vicinity` | Action / Leaf | `SUCCESS` | 52.00s | 52.00s | 52t | - |
| `Fire first torpedo` | Action / Leaf | `SUCCESS` | 36.00s | 36.00s | 36t | - |
| `Fire second torpedo` | Action / Leaf | `SUCCESS` | 36.00s | 36.00s | 36t | - |
| `arm_and_set_mode` | Action / Leaf | `SUCCESS` | 31.00s | 31.00s | 31t | - |
| `Go back to centre` | Action / Leaf | `SUCCESS` | 27.00s | 27.00s | 27t | - |
| `Settle before template match` | Action / Leaf | `SUCCESS` | 25.00s | 25.00s | 25t | - |
| `Wait after fire` | Action / Leaf | `SUCCESS` | 17.00s | 17.00s | 17t | - |
| `Wait after fire` | Action / Leaf | `SUCCESS` | 16.00s | 16.00s | 16t | - |

### Retries & Failure Details

| Node Name | Status | Attempts / Retries | Feedback / Error Description |
| :--- | :--- | :--- | :--- |
| `Retry start vision` | `SUCCESS` | 1/3 | "succeeded" |
| `Cluster and goto centre` | `FAILURE` | 1 attempt | - |
| `Retry Cluster Torp (initial)` | `FAILURE` | 4/3 | "final failure" |
| `Cluster torp poses (initial)` | `FAILURE` | 1 attempt | "goal rejected" |
| `Retry` | `UNVISITED` | 0/2 | - |
| `Retry Cluster Torp (centre check)` | `UNVISITED` | 0/3 | - |
| `Try template 1` | `SUCCESS` | 1/100 | "succeeded" |
| `Retry enable detections` | `SUCCESS` | 1/3 | "succeeded" |
| `Try template 2` | `SUCCESS` | 1/100 | "succeeded" |
| `Retry enable detections` | `SUCCESS` | 1/3 | "succeeded" |
| `retry enable correct srv` | `SUCCESS` | 1/3 | "succeeded" |
| `cluster_and_goto` | `FAILURE` | 1 attempt | - |
| `Retry cluster node` | `FAILURE` | 4/3 | "final failure" |
| `Cluster the transforms before first shot` | `FAILURE` | 1 attempt | "goal rejected" |
| `Retry` | `UNVISITED` | 0/5 | - |
| `Retry cluster node check` | `UNVISITED` | 0/3 | - |
| `cluster_and_goto` | `FAILURE` | 1 attempt | - |
| `Retry cluster node` | `FAILURE` | 4/3 | "final failure" |
| `Cluster the transforms before second shot` | `FAILURE` | 1 attempt | "goal rejected" |
| `Retry` | `UNVISITED` | 0/5 | - |
| `Retry cluster node check` | `UNVISITED` | 0/3 | - |
| `Retry Disable Detections` | `SUCCESS` | 1/3 | "succeeded" |
| `Retry End Vision` | `SUCCESS` | 1/3 | "succeeded" |

## Results

### Finding 1: Retry Cluster Torp (initial) (88.00s – 97.00s)

| Encompassed Node | Type | Status | Span (Time / Ticks) | Self Time | Attempts | Feedback |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `Cluster torp poses (initial)` | Action / Leaf | `FAILURE` | 6.00s (6t) | 6.00s | 1 | "goal rejected" |
| `Retry Cluster Torp (initial)` | Retry / Decorator | `FAILURE` | 9.00s (9t (3t 6t)) | 3.00s | 4/3 | "final failure" |
| `Cluster and move sequence` | Composite / Branch | `UNVISITED` | 1.00s (0t (0t 0t)) | 0.00s | 1 | - |
| `Retry` | Retry / Decorator | `UNVISITED` | 1.00s (0t (0t 0t)) | 0.00s | 0/2 | - |

We observe that the 1st Attempt of Cluster torp poses takes 2 ticks 
and so do the other 2 attempts

**Cluster and move sequence**
We observe that the 1st Attempt of Cluster torp poses takes 2 ticks 
and so do the other 2 attempts

### Finding 2: Retry cluster node (133.00s – 139.00s)

| Encompassed Node | Type | Status | Span (Time / Ticks) | Self Time | Attempts | Feedback |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `Cluster the transforms before first shot` | Action / Leaf | `FAILURE` | 6.00s (6t) | 6.00s | 1 | "goal rejected" |
| `Retry cluster node` | Retry / Decorator | `FAILURE` | 9.00s (9t (3t 6t)) | 3.00s | 4/3 | "final failure" |
| `Fire first torpedo` | Action / Leaf | `SUCCESS` | 36.00s (36t) | 36.00s | 1 | "... connected to service server" |

We observe that Retry cluster node #0 took 2 ticks, but #1 took 3 ticks

**Cluster the transforms before first shot**
We observe that Retry cluster node #0 took 2 ticks, but #1 took 3 ticks
