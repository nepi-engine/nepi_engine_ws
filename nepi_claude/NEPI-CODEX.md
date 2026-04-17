# NEPI ENGINE — CODEX


## IDENTITY

NEPI Engine — The edge-AI and automation platform that handles smart system infrastructure so engineering teams can focus on their actual product.

NEPI (Numurus Edge Platform Interface) is a plug-and-play software platform for building smart systems with sensors, AI models, automation, and data collection. It runs on NVIDIA Jetson and other embedded edge-compute hardware. It is open source, built on ROS and ROS 2, and field-deployed across subsea vehicles, autonomous surface vessels, commercial drones, industrial inspection systems, passenger ferries, and STEM education programs.

The platform exists because building a smart sensing system should not require building an entire infrastructure layer first. NEPI handles roughly 90% of what most smart systems need out of the box: hardware drivers, AI model management, event-driven automation, data collection, and a browser-based UI. Teams customize the remaining 10% for their specific application.


## PHILOSOPHY

NEPI is doing for smart systems what Windows did for computers. Before Windows, using a computer required real technical expertise — you had to understand how the hardware worked and write everything that made it function. Windows made computers accessible to anyone who needed one. NEPI removes the same barrier for smart systems. Any team that needs to build a robot, drone, sensor platform, or autonomous vehicle can now do it without first becoming an embedded systems infrastructure expert.

The platform was built in the context of genuinely difficult field environments: subsea vehicles, commercial fishing vessels, autonomous surface vessels in open water, and remote field systems where connectivity is unreliable and failure has real consequences. That context shapes every design decision. NEPI is not a lab platform. It is a field platform.

Open source is not a compromise and not a go-to-market tactic. It is a reflection of how the category should be built. Technical teams deserve to see what they are adopting before they commit. Researchers and educators deserve access without a procurement process. A platform that can be inspected, modified, and built on top of is more useful than one that cannot. The long-term vision is a partner-run marketplace of NEPI-compatible applications, drivers, and AI models — the same trajectory Microsoft followed after Windows.


## TARGET USER

PRIMARY — Hardware and robotics startups (pre-seed to Series B) building sensor-heavy systems under pressure to ship. They need to know: will this save us real engineering time, and has anyone like us used it?

PRIMARY — OEMs and systems integrators building hardware products that need a software layer to manage sensors, run AI, or collect data. They care about time-to-market, hardware compatibility, and long-term platform support.

PRIMARY — Ocean and subsea technology companies: ROV manufacturers, AUV developers, USV builders, ocean survey companies. NEPI has the strongest field track record in this vertical. VideoRay, OceanAero, WESMAR, and the UWT Ferry project are direct references.

SECONDARY — Research labs and universities. Defense and government contractors in connectivity-denied environments. STEM and robotics education programs.

USE CONTEXT — Teams are mid-project, under schedule pressure, facing sensor integration or AI pipeline work they did not budget for. They have accepted build-from-scratch as the only path. NEPI shows them there is another starting point.

WHAT THEY VALUE — Engineering time saved. Proof that it works in their environment. Hardware flexibility. Not being locked to a vendor or a cloud platform.


## FEATURE SET

Shipped:
- Hardware Abstraction Layer — Unified driver interface for cameras, sonar, lidar, pan-tilts, GPS, robots, and more. Applications work regardless of the specific hardware attached.
- AI Framework Integration — Load and run AI detection models at the edge. Framework-agnostic interfaces.
- Automation Manager — Event-driven automation scripting. NEPI auto scripts collection included.
- Data Collection System — Structured data collection from connected sensors and systems.
- Resident User Interface (RUI) — Browser-based UI hosted on the device. React frontend, Python backend.
- ROS and ROS 2 Interface — Custom messages and services via nepi_interfaces. Full ROS ecosystem compatibility.
- Driver Collection — nepi_drivers provides hardware abstraction for supported sensors and control devices.
- Application Collection — nepi_apps extends the base platform with additional capabilities.
- NEPI Connect — Edge-side connectivity components for remote management.

In Progress:
- See active development branches in nepi_engine_ws for current work.

Deferred:
- Partner-run application marketplace — Long-term platform vision. Requires ecosystem maturity.


## DESIGN DECISIONS

HARDWARE ABSTRACTION FIRST — The driver abstraction layer is the core architectural commitment. Downstream applications interact with hardware through NEPI standard interfaces without needing to know specific hardware details. This is intentional and must not be compromised by new driver implementations.

ROS-NATIVE — Built on ROS and ROS 2. This is not a legacy decision — it is the right foundation for the target audience. The entire ROS community can adopt NEPI without leaving behind existing code and knowledge.

BROWSER-BASED UI — The RUI is served from the device and accessed via browser. No installed client software. This is the right architecture for field systems that may be accessed remotely over limited connections.

SUBMODULE ARCHITECTURE — The superproject (nepi_engine_ws) organizes all components as independent git submodules. This enables components to be developed, versioned, and adopted independently. New features and drivers are added as submodules, not by growing a monolith.

OPEN SOURCE BY DEFAULT — All source code is public. This is a deliberate platform strategy, not a concession.

EDGE ONLY — No cloud dependency for core operation. The platform must function fully in connectivity-denied environments. Features that introduce cloud dependencies must degrade gracefully to full local operation.

PYTHON PRIMARY — ROS nodes are primarily Python. C++ is used where performance requires it. React and Node.js for the RUI frontend. New implementations should follow this language prioritization.


## RELATIONSHIP TO PORTFOLIO

NEPI Engine is the core platform. All other Numurus products and community contributions build on top of it. The nepi_engine_ws superproject is the authoritative source for the complete platform.

community.nepi.com is the community hub. github.com/nepi-engine is the authoritative source for all code.


## COMPETITIVE POSITION

AWS Greengrass and Azure IoT Edge are designed for IT teams managing enterprise device fleets. They require connectivity and are tied to their cloud ecosystems. NEPI operates fully at the edge with no cloud dependency.

NVIDIA Jetson ecosystem provides strong hardware with software support — but not a sensor integration or automation layer. NEPI runs on Jetson and provides the infrastructure layer teams would otherwise build themselves.

Custom-built infrastructure is the most common alternative. Teams spend months writing plumbing that has been built before. NEPI is the version they do not have to build themselves.


## OPEN QUESTIONS

- Versioning strategy for individual submodules vs. the superproject: should releases be coordinated or independent?
- Test infrastructure: what level of automated hardware-in-the-loop testing is feasible in CI?
- Community contribution workflow: how should Claude Code interact with external PRs?
