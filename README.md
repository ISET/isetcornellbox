# isetcornellbox

This repository shares the data and software related to this article:

[Accurate smartphone camera simulation using 3D scenes](https://stanford.edu/~wandell/data/papers//2022-CornellBoxValidation-Lyu.pdf)
<br>Zheng Lyu, Thomas Goossens, Brian Wandell, Joyce Farrell

---

![image](https://user-images.githubusercontent.com/1837145/185008646-bcc9ebf4-87d8-464b-87e6-69dfd1182278.png)

This paper describes image systems validation of a smartphone camera.  We constructed and measured a Cornell Box and created a simulation of a Google Pixel 4a camera.  This is an end-to-end simulation (scene radiance to raw digital values) of the image system. We then acquired images of the box using the Google Pixel 4a and compared a number of properties of the measured data with the simulations.

The calculations in this repository depend on [ISETCam](https://github.com/ISET/isetcam/wiki) and [ISET3d (v3)](https://github.com/ISET/iset3d/wiki). The calculations are illustrated in the LiveScripts that are linked below.

- [Figures 1 and 2](https://htmlpreview.github.io/?https://github.com/ISET/isetcornellbox/blob/main/papers/IEEE_2022/Figure_01_2.html) - Cornell box physical measurements and optics modeling
- [Figure 3](https://htmlpreview.github.io/?https://github.com/ISET/isetcornellbox/blob/main/papers/IEEE_2022/Figure_03.html) - Color channel calibration and correction
- [Figure 4](https://htmlpreview.github.io/?https://github.com/ISET/isetcornellbox/blob/main/papers/IEEE_2022/Figure_04.html) - Qualitative comparison of measured and simulated images
- [Figure 5](https://htmlpreview.github.io/?https://github.com/ISET/isetcornellbox/blob/main/papers/IEEE_2022/Figure_05.html) - Relative illumination
- [Figure 6 and 7](https://htmlpreview.github.io/?https://github.com/ISET/isetcornellbox/blob/main/papers/IEEE_2022/Figure_06_7.html) - Optics validations (linespread and MTF)
- [Figure 8](https://htmlpreview.github.io/?https://github.com/ISET/isetcornellbox/blob/main/papers/IEEE_2022/Figure_08.html) - Sensor noise validation
- [Figure 9](https://htmlpreview.github.io/?https://github.com/ISET/isetcornellbox/blob/main/papers/IEEE_2022/Figure_09.html) - Inter-reflections validation
- [Figure 10](https://htmlpreview.github.io/?https://github.com/ISET/isetcornellbox/blob/main/papers/IEEE_2022/Figure_10.html) - Color channel validation
- [Figure 11](https://htmlpreview.github.io/?https://github.com/ISET/isetcornellbox/blob/main/papers/IEEE_2022/Figure_11.html) - Conversion gain estimation from digital values

---

A link to the [pre-publication arXiv paper](https://arxiv.org/abs/2201.07411)

**ARXIV Abstract**

We assess the accuracy of a smartphone camera simulation. The simulation is an end-to-end analysis that begins with a physical description of a high dynamic range 3D scene and includes a specification of the optics and the image sensor. The simulation is compared to measurements of a physical version of the scene. The image system simulation accurately matched measurements of optical blur, depth of field, spectral quantum efficiency, scene inter-reflections, and sensor noise. The results support the use of image systems simulation methods for soft prototyping cameras and for producing synthetic data in machine learning applications.

  
