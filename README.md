v2: Slide‑Free Virtual H&E Staining

An end‑to‑end virtual H&E staining pipeline using **label‑free back‑illumination interference tomography (BIT)** and **UVCGANv2** to digitally transform raw tissue images into histology‑like H&E images—without physical sectioning or staining.

---

## 🖼️ Example Results — Mouse Brain Tissue

<p align="center">
  <img width="2025" height="660" alt="vHE_BIT_MUSE_Figure_V5" src="https://github.com/user-attachments/assets/c97e35b8-93cc-4a91-811d-c0a5d113da1d" />
</p>


<p align="center">
    <img width="685" height="312" alt="Screenshot 2026-01-12 at 11 32 49 PM" src="https://github.com/user-attachments/assets/5e6445e1-6284-419e-94c2-4c806a956f13" />
</p>
**Left to right:** Fluorescence → BIT → Virtual H&E → Conventional FFPE H&E

<p align="center">    
    <img width="997" height="381" alt="Zoomed results" src="https://github.com/user-attachments/assets/1880d933-5da0-4097-b7f9-b27a0c98855c" />
</p>


---

## 📄 Publication

**Optica NTM 2025**  
Proceedings: https://opg.optica.org/abstract.cfm?URI=NTM-2025-NTh1C.3  
PDF available in this repository: `ntm-2025-nth1c.3.pdf`  

**Full manuscript in preparation.**

---

## 📦 Project Overview

This repository implements:

> **UVCGAN v2: An Improved Cycle‑Consistent GAN for Unpaired Image‑to‑Image Translation**

and applies it to **virtual H&E staining of label‑free BIT images of raw tissue**.

UVCGANv2 improves upon CycleGAN by:
- Enhanced generator & discriminator architectures  
- Better training stability  
- Improved perceptual and structural preservation  

This makes it particularly well‑suited for scientific imaging tasks such as virtual histopathology.

Original UVCGANv2 paper:  
[UVCGAN v2 – Rethinking CycleGAN](https://arxiv.org/abs/2010.13407)

---

## 🧪 Applying UVCGANv2 to Your Dataset

To train on your own microscopy data, organize your dataset as:

```bash
MUSE-BIT/            # Label‑free BIT images
    trainA/
    testA/

FFPE-HE/             # Ground‑truth H&E images
    trainB/
    testB/
