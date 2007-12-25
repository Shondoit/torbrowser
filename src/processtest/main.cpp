/****************************************************************
 *  This file is distributed under the following license
 *
 *  Copyright (C) 2007, Steven J. Murdoch
 *                      <http://www.cl.cam.ac.uk/users/sjm217/>
 *
 *  This program is free software; you can redistribute it and/or
 *  modify it under the terms of the GNU General Public License
 *  as published by the Free Software Foundation; either version 2
 *  of the License, or (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 51 Franklin Street, Fifth Floor,
 *  Boston, MA  02110-1301, USA.
 ****************************************************************/

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
