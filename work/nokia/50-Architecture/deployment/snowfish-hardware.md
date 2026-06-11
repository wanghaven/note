![[snowfish.png]]
# SnowFish 20cx and 24cx key features
```
20pcs (ABIN) and 24pcs (ABIO) x Atom Tremont 64-bit cores @2.2GHz
	4.5MB shared midlevel + 2.5MB last level cache per cluster (4 cores)
2 x 72-bit Memory controllers with DDR4-2933 support and 8-bit ECC
HW accelerators:
	HW Queue Manager (HQM)
	Network Interface and Scheduler, NIS (Columbia Park)
	Flexible Packet Processor and Switch, FPPS (Highland Park)
	Intel Quick Assist Technology (QAT) for cryptographic functions
20 x High-speed SERDES interfaces with integrated Ethernet switch, supports up to 16 x 25GE
Many peripheral interfaces (PCIe Gen2/3, USB2.0/3.0, SATA, I2C, SPI, UART, GPIOs, ..)
47.5x47.5mm package, Intel 10nm technology
SDP thermal power 
	LE 63…66W for 24cx @ 2.2GHz
	LE 56…60W for 20cx @ 2.2GHz
```

# SnowFish CPU Subsystem Overview
```
6 CPU clusters each with four Tremont cores
	–Total 24 Tremont atom cores
	–Each core running at 2.2GHz
	–Manufactured in custom Intel 10nm process technology
	–Each cluster has 4.5MB shared L2 cache running at the same frequency as CPU (2.2GHz)
	–~3-4 Watt per cluster at SpecIntactivity
	–~30% Instructions Per Cycle (IPC) gain over the previous Goldmontgeneration (Denverton)
Scalable Coherent Fabric (SCF)
	–Dual ring interconnect that connects different IP blocks
	–Provides cache coherency across CPU clusters and I/O masters
	–The SNR Uncoreis Xeon based
	–SCF is running at 1.6GHz to 1.8GHz
L3 Cache / Memory Subsystem
	–15MByte, non-inclusive, striped system cache utilizing randomized hashed access
	–Six slices; each slice 2.5Mbytes; 20-way set associative
	–Each L3 associated with a snoop filter
	–Non-inclusive L3 cache
	–Each slice snoop filter covers 9 MB of cache lines (8k set, 18 ways)
	–L3 cache and snoop filter together are inclusive of all CPU cache lines
	–One memory controller with two 72-bit DDR4 channels
Hardware Queue Manager (HQM)
	–Accelerated IP that provides packet scheduling among Tremont cores and NAC.
	–It iprovides up to 150M packets/sec when running at 800MHz
	–HQM is connected directly to SCF through a MS2IOSF Bridge.
	–It is seen as a PCIeendpoint by the software
	–MSI interrupts are routed through SCF to CPU cores
LocalAPIC
	–One per core
	–Local interrupts plus external interrupts coming from Ubox
CPUDieNorthCap
	–An x32 Rlinkinterface to CedarFork
	–An x8 PCIeGen3 interface
	–HQM (Hardware Queue Manager)
	–Power Control Unit (PCU) microcontroller
	–CGU (Clock Generation Unit)
	–Universal box (Ubox)
	–Interrupts, locks, communication between CPU cores and Side Band Fabric
	–CBDMA engine (8 channels)
MS2IDI
	BridgeconnectingTremontclustertomesh
MS2IOSF
	–Bridge connecting I/O agents to SCF
	–Provides cache coherent accesses (it is acting like a mini core)
	–5 MS2IOSF (CPK, CPM, PCIe, CBDMA/RLink, and HQM)
	–Includes IOMMU functionality (VT-d)
	–Posted interrupts
Intel Program Trace (Intel PT)
	–Enable multiprocessor instruction trace to memory subsystem
	–Compressed instruction trace per Tremont core
Instruction Trace Hub
	–Merging instruction trace with other software or hardware trace streams
Performance Monitor (perfmon)
	–Coreand Uncore
	–UncorePMON for Different IP blocks (CHA, MS2IOSF, PCIe, etc)
Power management
	–Core dynamic clock gating
	–MONITOR / MWAIT instructions to go to different C states
	–UMONITOR and UMWAIT to go to core C0.1 state
	–Dynamic CPU Cluster and interconnect voltage/frequecy scaling is not supported in SNR and it is fused-out
Virtualization
	–Support for Intel VT-x technology
Security
	–Intel Software Gurad Extensions (SGX is fused out in SNR base-station SKU)
	–Intel Trusted Execution Technology (TXT)
	–Boot Guard
Reliability, Availability, and Serciceability (RAS)
	–Hardware will keep track of poisson data to delay generation of uncorrectable machine check interrupts
Platform Cache QOS
	–Preventing noisy neighbors to disturb over utilize shared resources
```
