# isetcornellbox
Data and scripts for evaluating the accuracy of simulating Google Pixel 4a images of a constructed and calibrated Cornell Box 

The arXiv paper cited below describes constructing a Cornell Box, measuring its properties, and acquiring images of the box using a Google Pixel 4a.  We then used ISETCam and ISET3d tools to simulate the end-to-end process (physics to raw digital values).

The key data and analyses of these data - comparing the measurements with the simulation - are implemented in this repository.  

The calculations in this repository depend on [ISETCam](https://github.com/ISET/isetcam/wiki) and [ISET3d (v3)](https://github.com/ISET/iset3d/wiki). The scripts to recreate key figures are

![image](https://user-images.githubusercontent.com/1837145/185008646-bcc9ebf4-87d8-464b-87e6-69dfd1182278.png)

* Figure_1
* Figure_2
* And so forth

LiveScript versions of these scripts are linked to on the repository's wiki page.

**Reference**

[Accurate smartphone camera simulation using 3D scenes](https://arxiv.org/abs/2201.07411)
<br>Zheng Lyu, Thomas Goossens, Brian Wandell, Joyce Farrell
<br> arXiv:2201.07411 [eess.IV]

**Abstract**

We assess the accuracy of a smartphone camera simulation. The simulation is an end-to-end analysis that begins with a physical description of a high dynamic range 3D scene and includes a specification of the optics and the image sensor. The simulation is compared to measurements of a physical version of the scene. The image system simulation accurately matched measurements of optical blur, depth of field, spectral quantum efficiency, scene inter-reflections, and sensor noise. The results support the use of image systems simulation methods for soft prototyping cameras and for producing synthetic data in machine learning applications.

  
