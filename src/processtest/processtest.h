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

#ifndef PROCESSTEST_H
#define PROCESSTEST_H

#include <QWidget>
#include <QPushButton>

#include "browserprocess.h"

class ProcessTest : public QWidget
{
    Q_OBJECT

public:
    ProcessTest(QWidget *parent = 0);
private slots:
    // App has started
    void onStarted();
    // App has exited
    void onFinished();
    // App startup failed
    void onFailed();
    // Button was clicked
    void onClicked();
private:
    // What state is the application in
    enum AppStateEnum {
      Stopped,
      Started,
      Terminating
    };

    // The push button
    QPushButton *_button;
    // Process handler
    BrowserProcess *_browser;
    // Command line to start
    QString _cmd;
    // Is the application running
    AppStateEnum _appState;
};

#endif
