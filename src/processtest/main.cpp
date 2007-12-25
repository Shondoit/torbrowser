/**
 ** Test invoking Firefox from Qt
 ** Steven J. Murdoch <http://www.cl.cam.ac.uk/users/sjm217/>
 ** $Id$
 **/

#include <QApplication>
#include <QCoreApplication>
#include <iostream>

#include "processtest.h"

int main(int argc, char *argv[])
{
  // Initialize Qt
  QApplication app(argc, argv);

  // Check that a command has been specified
  if(QCoreApplication::arguments().size() < 2)
  {
    std::cerr << "Usage: processtest COMMANDLINE\n";
    return 1;
  }

  // Initialize the main window
  ProcessTest test;
  test.show();

  // Start the application
  return app.exec();
}
