### What you built

* `cluster_and_goto_centre` held the tree for 412 ticks / 41 s across 3 attempts; `Goto torpedo vicinity` took 88 s of a 15-minute run.
- [x] Per-stage tick and time accounting — how long did `cluster_and_goto_centre` hold the tree, and where did the mission's total time go?"
- [x] Useful output looks like: *`cluster_and_goto_centre` held the tree for 412 ticks / 41 s across 3 attempts; `Goto torpedo vicinity` took 88 s of a 15-minute run.*
- [x] There is no built-in notion of a "stage." You decide how a subtree gets named and scoped for accounting — and how nested stages roll up without double-counting.
- [x] `Retry` and `FailureIsSuccess` re-enter stages. Separate *occupancy* from *attempts*, or the numbers lie. (waste 20s failing vs take another 40s to retry)
- [x] `memory=True` sequences skip completed children, so tick counts are not proportional to position in the tree.
- [x] Respect `use_sim_time`. Everything runs under simulated time and Gazebo does not run at real-time factor 1. Mission-duration numbers belong on the sim clock; your tooling's own overhead belongs on the wall clock. Mixing them silently produces plausible-looking nonsense.
- [x] Do not change mission behaviour. Your tooling must be opt-in (visitor, decorator, handler), and every tree must run identically with it disabled.
- [x] hide irrelevant nodes (display_only_visited_behaviours)
- [x] when double click on row, show sentence-form explanation of the node results.
- [x] You are to parse the data into a tabular form, with info on the indent for displaying as a tree. Information needed to parse the data is available in the ros2 code. 
  - [x] The parser should make as few assumptions as possible about the structure of the data. For instance, the example data above may not encompass all node type labels. Ensure you are aware of other possible assumptions. 
- [x] The data will be displayed as a tree in a compact display analogous to the ascii tree produced by pytree.
- [x] The tree parents should be collapsible
- [x] copy paste string (button to turn gui into ascii tree) / copy string into gui (turns into gui)
- [x] currently running nodes have a highlighted background for easier viewing
- [x] Fast updates to the table (in terms of the gui implementation, do not worry about ros2 at this time) are a must
- [x] Per-stage tick and time accounting — how long did cluster_and_goto_centre hold the tree, and where did the mission's total time go?
- [x] `and how nested stages roll up without double-counting.`
- [x] Collapse and expand subtrees; auto-collapse whatever finished long ago
- [x] Search and jump to a node by name
- [x] Add when click on the x[0-n] button, ability to switch between the different retries, and sum.
- [x] Add a breadcrumb element that replaces the column name "Tree" of the table on hover, persists on click row, shows where we are in the tree, goes to respective node when clicking on part of the breadcrumb
- [x] make it so that on expanding node parent, the node parent doesn't jump upward to make way for child nodes, rather the child nodes push downwards
- [x] Verify meausured time is sim time rather than wall time: oh yeah ticks are not aligned again smh figure that one out
- [x] On editing a comment, we fail to update the Node Execution Details to be able to display the details of each node that is selected by the comment area. 
- [x] Change the Edit Timeline Annotation / Edit Message gui to have a left sidebar displaying the nodes selected by the message in a tree format similar to how it is done in Node Execution Details. Left clicking and releasing on a node option will allow us to set a different message for each node. 
- [x] Then, add a Generate Report button between start recording and seconds / ticks button of the profiler panel, which will generate a markdown report from the messages, preview it to the user in a dialog, and allow the user to edit it before copying it to clipboard. 
  - [x] The markdown report should follow the following schema:
  - [x] The final markdown report dialog is too tall: it should shrink to fit within the panel when the panel is resized.
  - [x] Rename "Comment 1, ""Comment 2" to "Finding 1", "Finding 2"
  - [x] If a selected region does not have a singular root node to obtain the name in "Finding n: <name> ..." from, search further up the tree to find a common root node, and use that name
  - [x] Put general observation body text as normal text, not in a callout. Also remove the general observation: and Node Observations: headers.
  - [x] Format the names of node observations as follows:
- [x] Remove the useless stuff in the sidebar
- [x] Update Schema docs
- [x] Make collapse/expand state of nodes, current selected node of the profiler panel sync with the tree panel and vice-versa: In particular, collapsing/expanding a node in either panel will reflect in the other, and for current selected node, the tree will jump to the selected node when selected in profiler (we already have a jump to node functionality). You may use https://docs.foxglove.dev/docs/extensions/extension-api/type-aliases/RenderState#sharedpanelstate to help you implement the shared state.
- [x] Fake tree to use in the interview -> function to progressively yield more data every tick that is fake. 
- [x] Verify that `FailureIsSuccess decorators, Retry decorators, top-level fallback selector that fires both torpedoes blind if anything upstream fails` are indicated in the foxglove panel when they happen, and don't mess with the ticks
- [x] sunburst chart
- [x] Cache (latched) success/failure, do not turn into unvisited due to memory=true.
- [x] show a message icon in the tree panel, on the first node that overlaps with the selected message, after the node name. clicking it will bring up the dialog to edit the message. 
- [x] The copiable text is meant to be human readable (it is not right now, clogged with too much info smh)
- [x] Currently, individual retries are visible on the profiler at all zoom sizes, and the node name is a transluscent overlay at the top left. Instead, we would like to display the node as a contiguous block with the node name label when zoomed out, and the individual retries when zoomed in, without the node name label. 
- [x] Replace the Collapse Finished Button with a Expand all Button that expands all nodes. 
- [x] The tree view in Node Execution Results should be changed to show only the immediate children. 
- [x] We would like to rework timeline annotation/commenting. Instead of producing verbose, paragraph form markdown, we would like the information to be displayed in the "Node Execution Details" accordion item of the sidebar, which is expanded when editing a message. The comment textbox will be left blank. More information on how this changes the Node Execution Details accordion item is listed below:
  - [x] At the top center of the Node Execution Details accordion item, add a dropdown, and left and right arrows to the left and right of the dropdown. This will allow us to choose the node that is being displayed. This is also equivalent to the selected node.
  - [x] Below the dropdown and arrows, display the status of the node, followed by the time-related details of the node, as well as the type of node. 
  - [x] below the time related details, display in an row-based hierarchical tree layout, the node and its children. double clicking on the children will change the selected 
  - [x] If left click and release on a bar in the profiler, we will select that node, and display it as if a message area selected only that node (but do not actually create a new message area when left click and release). If we were in the process editing a message, show a dialog asking if you would like to save the message first, before clearing the dropdown of the nodes selected by the messagearea, and adding the singular node that was left clicked and released to the dropdown and displaying it. 
- [x] The sidebar needs to be more compact. In particular,
  - [x] the sidebar width should be smaller
  - [x] the accordion item headers should be thinner, about the same width as the buttons
  - [x] Remove all HUD metrics except Node Status Breakdown and Longest Self-Execution. to the right of the "Node Status Breakdown: " text, add a similar text element that displays the current total duration in format: "23 ticks / 2.30s"
  - [x] change the header of the node details item in the accordion to have the title "Node Execution Details"
  - [x] Remove the "Sidebar" text from the button that collapses the sidebar. Also remove the redundant first header in the accordion that also collapses the sidebar
- [x] replace the reset view button with a small textbox at the bottom right of the profiler that displays the current zoom, and can be edited to zoom to the requested value. To the immediate left of this textbox, add a button with a reset icon that resets the zoom.  
- [x] For reopening a message for editing, on hovering over the message area, replace the thought bubble icon with a pencil icon. Also, move the 'reopening a message for editing' topbar to be aligned to the top of the message area instead of the top of the timeline track. 
- [x] When adding a comment, prefill the text with information about the nodes that are encompassed by the message box in sentence, verbose form. The prefilled text should also be in markdown. 
- [x] Also make it not a dialog box, put it in the bottom pop up panel that is also used by node details. 
- [x] Display live HUD information about the run (decide for yourself what to display) within an item of a accordion within a collapsible left sidebar
- [x] replace the comments button that opens all comments within an item of a accordion within the same collapsible left sidebar showing the list of comments. to be edited/deleted. 
- [x] Move the node information on left click and release gui to an item on the same accordion panel. The header for this item will be collapsed by default, show "click a node to show detailed information" as a placeholder for when there is no node selected yet, and will expand when a node is selected.  
- [x] Allow selection of area to add a comment to have a y axis component. In particular, besides time, we also want selection of area to be able to drag along node level, which is vertically in the profiler panel. Selection of area along node level axis will always snap to the nearest node level.  
- [x] fix the profiler being distorted when we resize panel/left click on bar to open extra info. 
- [x] On left clicking a bar in the profiler, holding and dragging upwards, collapse the subnodes of the bar (bars below the bar), and parents of that bar as we drag our cursor further upwards
- [x] On left click and release, display more details about the bar (this is alrady implemented)
- [x] On right click (or right click and drag), open a dialog over the selected nodes that allows the user to add a comment to a section of the times in the profiler
- [x] On middle mouse double click, move the selected bar to the top row of the profiler (show the selected bar as the root of the profiler and its children below) (this is already implemented, but we want different keybinds)
- [x] Filter to the visited path, or to a single stage, and put everything else away
- [x] Figure out what this means `memory=True sequences skip completed children, so tick counts are not proportional to position in the tree.` (from comments on fixglove-py-trees-viewer: `latched SUCCESS so completed work stays visible under memory=True sequences`)
- [x] On middle mouse hold, pan across the profiler
- [x] On left click drag, sseslect zoom
- [x] on scroll, should zoom cenetered on mouse curosr
- [x] recticle showing current position in ticks. 
- [x] Rebase to my own forks of the repos
- [x] Make retry toggle button only exist on the first node. 
- [x] `Get structured, per-tick mission state` `the schema, the transport, or the update strategy`
  - [x] Schema - as in schema
  - [x] Transport - visitor? publish? action, service, etc.? how many?
  - [x] Update Strategy - maybe we don't need to send over the entire tree each tick? 
- [x] Document your schema. A short section in docs/; docs/architecture.md is the house style to match.
- [x] Make the 'on right click (or right click and drag) to add a comment functionality' snap to bar start/end. A larger bar will increase the distance at which it will snap, and vice versa. 
- [x] Add a way to reopen a added message and edit it with the dialog in the profiler. Also replace the clear all messages button with a button that opens a dialog showing all messages, with ability to open any of them to edit, delete any of them, or delete them all. 

---

### What you chose *not* to build

- [-] A history strip rather than only the present instant
- [-] some of the tree disappeared after I closed gazebo, investigate that
- [-] why is py_trees_ros snapshot stream not used in practice compared to serialized ascii tree publish to ros_out
  - [-] Bandwidth (publishing multiple channels, etc.)
  - [-] serializing every object is slow
  - [-] what if I want to monitor 2 trees in the same run? 
- [-] `how a subtree gets named and scoped for accounting` Might be impractical to make every node in the ascii tree a subsubsubsubnode?
- [o] May make more sense to have tabs for ticks and time at the top, I mean are we ever comparing the two?
- [o] Percentage time: show % time that the run took. Maybe show a colour-coded bar at the bottom that can be clicked on to redirect to corresponding node? OR put coloured dark bars in the background (better than a separate graph imo since less complex)
- [o] The bars on the panel jitter as time/ticks information gets added to the panel. We'd like you to fix this.
- [o] The current tick/time is currently aligned with the edge of the panel. We'd like for the current tick/time to start some distance from the edge of the panel. For instance, if the simulation has been running for 17 ticks, the profiler panel should display an axis up to 17 ticks + some buffer ticks, which will result in the bar not reaching the end of the panel.
- [o] Below each finding, divide the contents into 2 columns. The General Info occupies 2 columns, while each node info occupies 1 column. 
- Subtree time: "Subtree time isn't actually used since all the parent nodes took 0 ticks..."
- Subclassing py_trees_ros BehaviourTree / using py_trees_ros snapshot stream:
  - 1. behaviour tree creates a whole bunch of different topics which impact performance
  - py_trees_ros needed, whereas we custom implement in bumbletree so can't. Subclassing py_trees_ros.trees.BehaviourTree comes with a lot of implicit ROS lifecycle logic, action servers, and default topics
- Unimplemented future extensions:
  - futures: add integrations with other tools that support advanced profiling techniques
  - futures: this system can't tell you about changes to the tree at X time: only the state at the end

---

### The trade-offs you made

- **Transport Strategy / Message Format:**
  - DECISION: do not stream msg, just stream msg with single stringified JSON
    - Why 1: Ensure backwards compatibility with anything that depends on 
    - Why 2: Custom msg format -> introduce complexity to backend extension for no gain (logging is the same whether we actually use ROS2 Messages)
      - Why 2.1: Easier for integration outside foxglove
    - Why 3: If indeed we did built a message, it would need to cover arbitrary 
  - "What I did was any time I wanted to add data, I'd just append it to the ascii tree. Eventually it got too convoluted and it was replaced with actual ROS2 Messages. But the idea was that if someone on the Bumblebee team wanted to share results with someone there would be a (semi) readable string representation of the tree that could be copied out of the panel."
- **Snapshot Publishing Rate vs. Bandwidth:**
  - maybe we don't publish the snapshot stream to save bandwidth? also if decr publish rate to save more bandwidth, we might skip important ticks. yeah foxglove panels all are flickering when we publish like this.
  - Options:
    1. Implement Observer
    2. Hardcode "Important Events" that trigger publish
- **Time/Tick Accounting & Rollup Logic:**
  - BIG IDEA: sum of all child node ticks!=parent ticks
  - parallel nodes will take the max all all nodes
  - nodes that execute within the same tick will count as 1 tick to the parent
  - ok parallel is not really fully addressed but good enough
- **Simulation Time vs. Tooling Overhead:**
  - Mission-duration numbers belong on the sim clock; your tooling's own overhead belongs on the wall clock. Mixing them silently produces plausible-looking nonsense.
- **Tick-to-Time Synchronization:**
  - Another thing is that the way we sync time and ticks is by storing the interval it takes to execute 1 tick across the whole tree. This is not very accurate, as to my best knowledge nodes are ticked at different times in the tree within the same tick. As a result all our seconds are aligned to 0.10s...
- **Client-side Caching:**
  - We have now set show_only_visited on ros2, which means foxglove will not longer receive updates on completed elements of the tree. However, we can cache the previous updates (since they would not have changed) and display them for the user without inccuring additional bandwidth.
- **UI Paradigm:**
  - So initially on attaching LoggingSnapshotVisitor I intended to go for the profiler but then the features I added slowly turned it into the tree state task. I think it was mostly because I decided to put it all in a table. The idea behind the mission profiler tracking reminded me of the LiveSplit tool, so it became a table.

---

### What breaks first if we scale this up

- [ ] optimize (currently the snapshot taker runs on twice the frequency of our structured whatever)
  - [ ] send format on first packet, then only the reduced data afterwards
- [ ] The bug with 1t 0s nodes and double counting ticks every child node still exists, fix that
- [ ] Retry count is displaying incorrectly: e.g. for 5 retries Retry #0 to Retry #4, when zoomed out the contiguous block reads Retry (6/5)
- Tick-overlap race conditions: "One thing I have not yet solved (may solve within the next 24hrs) is that a node may start ticking on the same tick that a previous node has its last tick."
- Coarse time precision: "As a result all our seconds are aligned to 0.10s..."
- Performance and serialization overhead:
  - Bandwidth (publishing multiple channels, etc.)
  - serializing every object is slow
  - behaviour tree creates a whole bunch of different topics which impact performance
- Multi-tree scalability: "what if I want to monitor 2 trees in the same run?"
- Historical inspection limitation: "this system can't tell you about changes to the tree at X time: only the state at the end"