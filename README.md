PLPS
====

Polar Logarithmic Phase Screen
------------------------------

This is a CUDA implementation of the polar--logarithmic method (Burckel &  Gray, Turbulence phase screens based on polar-logarithmic spectral sampling, Appl. Opt., 52(19), Jul 2013) to generate turbulence phase screens.

The source code and documentation are generated from a *polarLogPhaseScreen.nw* using the literate programming parser [noweb](http://www.cs.tufts.edu/~nr/noweb/).

The source code for the CUDA kernel and the Matlab test script is generated with 
`noweb polarLogPhaseScreen.nw`
This command created 2 files: *plps.cu* and *plps.m*.
  In order to run the Matlab test script *plps.m*, the CUDA kernel is first compiled with
`nvcc -ptx plps.cu`
The PDF documentation is generated with
```
noweave -delay -x polarLogPhaseScreen.nw > polarLogPhaseScreen.tex
pdflatex polarLogPhaseScreen.tex
pdflatex polarLogPhaseScreen.tex
