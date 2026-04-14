![[Marlin.png]]
# Marlin (akaTX3 or L2+), ReefShark3302 SoC
```
Cores
	Up to 24 ARM Neoverse Perseus cores; Up to 2.5GHz/Core 
	Out-of-Order execution; Fully Virtualized
	1MB per-CPU L2 Cache

 Memory Subsystem
	Up to 48MB Shared Last Level Cache
	Up to 6x 32b+ECC DDR5/4 

Connectivity + Switching
	Up to 16 lanes 56G ETH Serdes with Integrated Switching
	Up to 8 lanes Gen5 PCIe (up to 3 controllers EP/RC)
 
HW Acceleration
	Highly-virtualized, software-friendly NIC
	Packet Processing, QoS, Hierarchical queues w/ shaper & WDRR scheduler
	Very flexible packet parsing
	Schedule, Synch., & Ordering
	Security (IPSec, Air Interface) Nitrox V
	ML/AI accelerator

Performance
	SPECINT: 17/GHz per Core
	120G Crypto (total Air + IPSec)
```

# ReefShark3302 Highlights (Marlin)
```
Octeon TX3 SoC provides a heterogeneous multiprocessor C-language programmable Multi-Radio Base Station solution with Nokia BTS connectivity support. 
BTS Applications
	Multi-RAT
	Radio L2 user plane GTP, PDCP, RLC, MAC protocols 
	Radio L3 Control plane and O&M applications
	Transport application (Fast path IP stack)
Application acceleration
	HW event scheduler / ODP scheduler
	ML/AI accelerator
Connectivity & Networking
	NIX packet processor
	Ethernet / IP transport connectivity
	Integrated switch
Security
	Security offload
	Air interface encryption (3GPP crypto)
	Public key acceleration (Asymmetric cryptography)
	Transport IPsec (AES-GCM…)
	MACsec on switch ports
Synchronization
	IEEE 1588 PTP HW timestamping
	Synchronous Ethernet
```

# SoC Features
```
ReefShark3302 Highlights (Marlin)
16 – 24 ARM v9.0 CPU cores @2.1 GHz (1.2 - 2.5 GHz) <60W
24 MB L2 cache and 48 MB Last Level cache on 24 core variant
6x 40b DDR5 @Up to 5200MT/s
	Up to 6x 32b+ECC DDR5/4
Native EM/ODP HW scheduler (SSO)
Ethernet interfaces, 16x 56G SerDes, supporting
	1GE, 2.5GE, 5GE, 10GE, 25GE, 40GE, 50GE, 100GE
	All interfaces w/ MACsec
Integrated Ethernet switch
	Upto 800 Gbps switching capacity
100 Gbps bulk packet processing capacity
	Mobile backhaul transport processing with 8 cores upto 50 Gbps (with IPsec)
100 Gbps bulk 3GPP and IPsec crypto processing
6x PCIe Gen5
Group of standard IO control and data interfaces
	6x PCIe Gen5, USB 3.1
	GPIO, I2C, SPI/QSPI, eMMC, UART, MDIO/MDC, JTAG
```

# Technology
```
TSMC 5nm N5P technology
SKU variants: 16 core 40W to 24 core 90W @2.5GHz. Main SKU option <60W.
Silicon junction temperature from -40C to 110C
Based on Marvell Octeon TX3 (ASSP, standard product)
```