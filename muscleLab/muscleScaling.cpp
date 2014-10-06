//==============================================================================
//The OpenSim Main header must be included in all files
#include <iostream>
#include <sstream>
#include <OpenSim/OpenSim.h>
#include <OpenSim/Simulation/Model/Model.h>
// Set the namespace to shorten the declarations
// Note: Several classes appear in both namespaces and require using the full name
using namespace OpenSim;
using namespace SimTK;
//______________________________________________________________________________
/**
* @param argc Number of command line arguments(should be 3).
* @param argv Command line arguments : simmReadXML inFile
* /
*/

int main(int argc, char* argv[])
{
	
	// Prints each argument on the command line.
	/**
	for (int i = 0; i < argc; i++)
	{
		printf("arg %d: %s\n", i, argv[i]);
	}
	*/

    try {

		// Determine the lower limb muscle volume of the subject. 

		Model* myModel = new Model(argv[1]);
		
		double mass, height;

		mass = atof(argv[2]);
		height = atof(argv[3]);
		
		/**
		mass = 60;
		height = 1.7;

		volumeFunction = 47.05*mass*height + 1289.6;
		*/


        // **********  END CODE  **********
    }
    catch (OpenSim::Exception ex)
    {
        std::cout << ex.getMessage() << std::endl;
        return 1;
    }
    catch (SimTK::Exception::Base ex)
    {
        std::cout << ex.getMessage() << std::endl;
        return 1;
    }
    catch (std::exception ex)
    {
        std::cout << ex.what() << std::endl;
        return 1;
    }
    catch (...)
    {
        std::cout << "UNRECOGNIZED EXCEPTION" << std::endl;
        return 1;
    }
    std::cout << "OpenSim example completed successfully" << std::endl;
    std::cout << "Press return to continue" << std::endl;
	std::cout << "Hello World" << std::endl;
	std::cin.get();
    return 0;
 } 