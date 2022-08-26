# isetcornellbox

This repository includes data and software to make the computational methods in this paper reproducible and shared.

![image](https://user-images.githubusercontent.com/1837145/185008646-bcc9ebf4-87d8-464b-87e6-69dfd1182278.png)

This paper describes constructing a Cornell Box, measuring its properties, and acquiring images of the box using a Google Pixel 4a.  We then used ISETCam and ISET3d tools to simulate the the scene radiance of the box, the optics of the phone, and the sensor.  This is an end-to-end simulation (scene radiance to raw digital values) of the iamge system.

The calculations in this repository depend on [ISETCam](https://github.com/ISET/isetcam/wiki) and [ISET3d (v3)](https://github.com/ISET/iset3d/wiki). The calculations are illustrated in the LiveScripts that are linked on the right side of this page.

The arXiv paper is a pre-print of the published article. 

- [Figures 1 and 2](https://htmlpreview.github.io/?https://github.com/ISET/isetcornellbox/blob/main/papers/IEEE_2022/Figure_01_2.html) - Cornell box physical measurements and optics modeling
- [Figure 3](https://htmlpreview.github.io/?https://github.com/ISET/isetcornellbox/blob/main/papers/IEEE_2022/Figure_03.html) - Color channel calibration and correction
- [Figure 4](https://htmlpreview.github.io/?https://github.com/ISET/isetcornellbox/blob/main/papers/IEEE_2022/Figure_04.html) - Color channel calibration and correction
- [Figure 5](https://htmlpreview.github.io/?https://github.com/ISET/isetcornellbox/blob/main/papers/IEEE_2022/Figure_05.html) - Color channel calibration and correction
- [Figure 6 and 7](https://htmlpreview.github.io/?https://github.com/ISET/isetcornellbox/blob/main/papers/IEEE_2022/Figure_06_07.html) - Color channel calibration and correction
- [Figure 8](https://htmlpreview.github.io/?https://github.com/ISET/isetcornellbox/blob/main/papers/IEEE_2022/Figure_08.html) - Color channel calibration and correction
- [Figure 9](https://htmlpreview.github.io/?https://github.com/ISET/isetcornellbox/blob/main/papers/IEEE_2022/Figure_09.html) - Color channel calibration and correction
- [Figure 10](https://htmlpreview.github.io/?https://github.com/ISET/isetcornellbox/blob/main/papers/IEEE_2022/Figure_10.html) - Color channel calibration and correction
- [Figure 11](https://htmlpreview.github.io/?https://github.com/ISET/isetcornellbox/blob/main/papers/IEEE_2022/Figure_11.html) - Color channel calibration and correction


**ARXIV Reference**

[Accurate smartphone camera simulation using 3D scenes](https://arxiv.org/abs/2201.07411)
<br>Zheng Lyu, Thomas Goossens, Brian Wandell, Joyce Farrell
<br> arXiv:2201.07411 [eess.IV]

**Abstract**

We assess the accuracy of a smartphone camera simulation. The simulation is an end-to-end analysis that begins with a physical description of a high dynamic range 3D scene and includes a specification of the optics and the image sensor. The simulation is compared to measurements of a physical version of the scene. The image system simulation accurately matched measurements of optical blur, depth of field, spectral quantum efficiency, scene inter-reflections, and sensor noise. The results support the use of image systems simulation methods for soft prototyping cameras and for producing synthetic data in machine learning applications.

  
