# 7 5G-L1-UL (Radio)

**7.0-1**  (ID: `11468957`)

5G-L1-UL (Radio)
11468957:
5G-L1-UL (Radio)
11468957:
5G-L1-UL (Radio)
11468957:
5G-L1-UL (Radio)
11468957:
5G-L1-UL (Radio)
11468957:
5G-L1-UL (Radio)
11468957:
5G-L1-UL (Radio)
11468957:
5G-L1-UL (Radio)
11468957:
5G-L1-UL (Radio)
11468957:
5G-L1-UL (Radio)
11468957:
5G-L1-UL (Radio)
11468957:
5G-L1-UL (Radio)
11468957:
5G-L1-UL (Radio)
11468957:
5G-L1-UL (Radio)
11468957:
5G-L1-UL (Radio)
11468957:
5G-L1-UL (Radio)
11468957:
5G-L1-UL (Radio)
11468957:
5G-L1-UL (Radio)
11468957:
5G-L1-UL (Radio)
11468957:
5G-L1-UL (Radio)
11468957:
5G-L1-UL (Radio)
eCPRI 7-2 e UL split focuses on splitting the receiver functionalities between L1 low and L1 high in which located in RU and DU, respectively. eCPRI 7-2 e UL split is shown in the figure down below and compared it with 7-2a split and CPRI 8 split.

Following changes take place in 7-2e UL split compared to 7-2a split:

PUSCH: IRC and DMR Chest is moved from L1 high to L1 Low.

SRS: For BF functionality, covariance calculation and Chest is moved from L1 high to L1 Low.

PRACH: No changes.

PUCCH: No changes.

Note: No changes for SU-MiMO SRS functionality.

[image-0][image\_desc]The image is a diagram illustrating the processing flow of different communication channels (PUSCH, PUCCH, SRS, PRACH) across different layers (L2Lo, L1Hi, L1Lo, RF). The diagram is organized into columns representing the channels and rows representing the layers and their respective processing steps.
Here's a breakdown of the diagram:
**Top Section (Channel Headers):**
\* **FH split F1:** This appears to be a label for the overall diagram or a specific configuration.
\* **PUSCH, PUCCH, SRS, PRACH:** These are the headers for the different communication channels.
**L2Lo Layer:**
\* Under PUSCH and PUCCH: **MAC**
\* Under SRS: **BF coeff calc** (Beamforming coefficient calculation)
\* Under PRACH: **MAC**
**L1Hi Layer:**
This layer shows a more detailed breakdown of processing steps for PUSCH and PUCCH.
\* **Under PUSCH:**
\* CRC
\* Decoding
\* HARQ Combine
\* Rate de-match
\* Descrambling
\* Demodulation
\* Equalization
\* **IRC + DMRS Chest** (This block is highlighted with a red border)
\* **Under PUCCH:**
\* CRC
\* Decoding
\* Rate de-match
\* Descrambling
\* Demodulation
\* Equalization
\* **IRC + DMRS Chest** (This block is highlighted with a red border)
\* **Under SRS:**
\* **Covariance Calc.** (This block is highlighted with a red border)
\* **Channel Estimation** (This block is highlighted with a red border)
\* **Under PRACH:**
\* **Detection**
\* **Correlation** (This block is highlighted with a red border)
\* **PE demap** (This block is highlighted with a red border)
**L1Lo Layer:**
\* Under PUSCH and PUCCH: **Beamforming**
\* Under SRS and PRACH: **Beamforming**
**RF Layer:**
\* **FFT** (Fast Fourier Transform)
\* **Analog to digital**
\* **Analog RF RX** (Analog Radio Frequency Receive)
**Visual Elements:**
\* Blue rectangles represent processing blocks.
\* Gray rectangles represent channel headers.
\* Red borders highlight specific processing blocks, likely indicating a particular area of interest or a combined function.
\* Horizontal lines (red and dashed green) seem to delineate different sections or interfaces.
The diagram visually represents the signal processing chain for different uplink channels in a cellular communication system, showing how data flows through various layers and processing stages.[/image\_desc][image\_path]https://storage.googleapis.com/dng\_files/images/HTML\_pukkola\_5G\_L1\_Entity\_Level\_file\_8173.001.png[/image\_path][/image-0]

---

## Sections

- [7.1 UL Carrier Management](7.1_UL_Carrier_Management.md)
- [7.2 PRACH](7.2_PRACH.md)
- [7.3 PUCCH](7.3_PUCCH.md)
- [7.4 PUSCH](7.4_PUSCH.md)
- [7.5 SRS](7.5_SRS.md)
- [7.6 RIM](7.6_RIM.md)
