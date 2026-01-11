# Multimedia Project (jan. 2026)

# Image to Audio to Image Conversion Using MATLAB

**Student:** Mariam Marhaba (2119)
**Course:** Multimedia – ULFG1

---

## 1. Introduction

This project demonstrates a multimedia signal processing system that converts an image into an audio signal and then reconstructs the image back from the audio. The system exploits the mathematical equivalence between images and spectrograms, using the Fourier Transform to move between spatial and temporal-frequency domains.

The work illustrates how visual information can be encoded as sound and later decoded, highlighting key concepts in multimedia representation, frequency analysis, and signal reconstruction.

---

## 2. Objectives

The main objectives of this project are:

* To understand the relationship between images and audio spectrograms.
* To apply Fourier Transform techniques in multimedia processing.
* To implement image-to-audio and audio-to-image conversion using MATLAB.
* To analyze the effects of magnitude, phase, normalization, and reconstruction on signal quality.

---

## 3. Tools and Environment

* **Software:** MATLAB
* **Key Functions Used:** `imread`, `imwrite`, `fft`, `ifft`, `audioread`, `audiowrite`, `spectrogram`
* **Data Types:** RGB images (PNG), audio signals (WAV)

---

## 4. System Overview

The system consists of two main stages:

1. **Forward System (Image → Audio)**
2. **Reverse System (Audio → Image)**

The image is treated as a time–frequency representation similar to a spectrogram, where:

* Image rows correspond to frequency bins
* Image columns correspond to time frames
* Pixel brightness corresponds to signal magnitude

---

## 5. Image → Audio Conversion (Forward System)

### 5.1 Image Preprocessing

* The input image is loaded and normalized.
* RGB channels are converted into luminance (Y) and chrominance (Cr, Cb) components.
* The luminance represents magnitude, while chrominance encodes phase information.

### 5.2 Magnitude and Phase Extraction

* **Magnitude (mag):** Derived from image brightness and represents sound energy.
* **Phase (ang):** Computed from chrominance channels and represents phase angle.

These are mathematically combined into a complex spectrum using:

$$
X = \text{mag} \cdot e^{j \cdot \text{ang}}
$$

### 5.3 Spectral Processing

* Frequency-dependent scaling is applied to balance perceptual loudness.
* Conjugate symmetry is enforced to ensure a real-valued time signal after IFFT.

### 5.4 Audio Reconstruction

* An inverse FFT converts each spectral column into a time-domain audio chunk.
* Chunks are concatenated into a 1D audio signal.
* Boundary averaging is applied to reduce audible clicks between chunks.
* The audio is normalized and saved as a WAV file.

---

## 6. Audio → Image Conversion (Reverse System)

### 6.1 Audio Preprocessing

* The audio file is loaded and converted to mono if necessary.
* The signal is split into equal-length chunks corresponding to image columns.
* Zero-padding is applied to ensure uniform chunk size.

### 6.2 Frequency Analysis

* Each chunk undergoes FFT to obtain frequency-domain data.
* FFT bins are reordered to match the original image frequency layout.
* Inverse brightness scaling is applied to compensate for forward processing.

### 6.3 Magnitude and Phase Recovery

* **Magnitude:** Extracted using `abs(fftStrips)`
* **Phase:** Extracted using `angle(fftStrips)`

These values are mapped back into Y, Cr, and Cb components.

### 6.4 Image Reconstruction

* YCrCb values are converted back to RGB color space.
* Values are clamped to valid ranges and converted to `uint16`.
* The reconstructed image is saved as a PNG file.

---

## 7. Spectrogram Visualization

A spectrogram of the generated audio is produced to visually verify that the image has been correctly encoded into time–frequency content. The spectrogram closely resembles the original image structure, confirming the correctness of the transformation.

---

## 8. Discussion and Observations

* Normalization is necessary to prevent audio clipping but removes absolute amplitude information.
* Phase information is crucial for accurate image reconstruction.
* Zero-padding ensures consistent chunk sizes but slightly increases data length.
* Small reconstruction artifacts may appear due to numerical precision and normalization.

---

## 9. Conclusion

This project successfully demonstrates a reversible multimedia transformation between images and audio signals. By leveraging Fourier analysis, visual information can be encoded as sound and later reconstructed with high fidelity. The system highlights fundamental multimedia concepts such as spectral representation, magnitude–phase separation, and signal normalization.

---

##
