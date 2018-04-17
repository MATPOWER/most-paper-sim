MOST Paper Simulations
======================

_by Haeyong (David) Shin, Alberto J. Lamadrid, Ray D. Zimmerman_

---

This is a public repository of the code and data used in the simulations
presented in following paper:

>   A. J. Lamadrid, D. Muñoz-Álvarez, C. E. Murillo-Sánchez, R. D. Zimmerman,
    H. Shin and R. J. Thomas, "Using the MATPOWER Optimal Scheduling Tool to
    Test Power System Operation Methodologies Under Uncertainty," _IEEE
    Transactions on Sustainable Energy_, **under review**.


Background
----------

The simulations in the paper are based on a number of free-open source packages for the Matlab language.

- [MATPOWER][1] -- steady state power flow simulation and optimization for MATLAB and Octave
- [MOST][2] -- MATPOWER Optimal Scheduling Tool (installed with MATPOWER)
- [MP-Sim][3] -- simulator framework for MATLAB and Octave

While the above packages work on both MATLAB and Octave, the simulations in the paper require a high-performance MIP solver. We used [Gurobi][4], which is supported by MATPOWER only for MATLAB. At the time of this writing, Gurobi is available via a free license for academic use.


Getting Started
---------------

Before you can run these simulations, you will need to do the following steps to get set up.

1. Install MATLAB. This is commercial software available from [The MathWorks][5]. For system requirements and installation instructions, please refer to their documentation.

2. Install [Gurobi][4], and include it in your MATLAB path.

3. Install MATPOWER 6.0 or later, available from [the MATPOWER web site][1]. This includes MOST.

4. Install [MP-Sim][3].

5. Download (or clone) this repository and add the `lib` sub-directory to your MATLAB path (but not it's sub-directories).

6. Put the contents of the `sim_data` sub-directory in the MP-Sim `<INPUTDIR>` specified in the (optional) Step 4 of the MP-Sim installation. By default this is `<MPSIM>/sim_data`, where `<MPSIM>` refers to the location where you installed MP-Sim.


Testing Your Installation
-------------------------

At the MATLAB prompt, type:

    >> sim = mostpaper().run('testsim9');


Running the Simulations
-----------------------

At the MATLAB prompt, type:

    >> sim = mostpaper().run('sim118');


License and Terms of Use
------------------------

The MOST Paper Simulations code is distributed as open-source under the [3-clause BSD license][6].


[1]: http://www.pserc.cornell.edu/matpower
[2]: https://github.com/MATPOWER/most
[3]: https://github.com/MATPOWER/mpsim
[4]: http://www.gurobi.com
[5]: https://www.mathworks.com
[6]: LICENSE
