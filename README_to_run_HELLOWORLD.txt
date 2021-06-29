Here is the procedure to follow to run a "Hello" test on the RTL platform:


-	You would require the PULP toolchain, checkout master branch and install it if not done yet: https://github.com/pulp-platform/pulp-riscv-gnu-toolchain.git ;
-	Source the installation path of the toolchain (environment variable needed to compile the tests);
-	After cloning the PULP platform ( https://github.com/pulp-platform/pulp.git ) checkout "fpu_integration_maintained" branch;
-	From the root of the folder, launch the "./update-ips"  script to build the RTL database (fetch all the Ips);
-	Once the procedure is completed with no errors export the VSIM path by executing "source setup/vsim.sh";
-	After that move to the sim folder: "cd sim", and run "make clean lib build opt" to build the RTL platform;
-	At this point you would require the runtime, just launch the "./update-pulp-runtime" script and this will clone the runtime into a dedicated folder;
-	After that you need to source the right configuration for the runtime: "cd pulp-runtime";      "source configs/pulp.sh";
-	Now you need to copy and extract the test suite (tests.tar.gz) into the current working directory of pulp (root folder);
-	After that go inside the folder of the test (e.g. hello) and compile the test with "make clean all";
-	Run the test with "make run" or eventually with "make run gui=1" to open the QuestaSim gui.
