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

#include <QPushButton>
#include <QStringList>
#include <QCoreApplication>

#include "processtest.h"
#include "browserprocess.h"

ProcessTest::ProcessTest(QWidget *parent)
    : QWidget(parent)
{
    // Set the window size
    setFixedSize(200, 50);

    // Get the command line (main.cpp already checked the size
    _cmd = QCoreApplication::arguments().at(1);

    // Display the button
    _button = new QPushButton(tr("Go"), this);
    _button->setGeometry(10, 10, 180, 30);

    // Initialize the process handler
    _browser = new BrowserProcess();
    _appState = Stopped;
 
    // Connect up the button
    QObject::connect(_button, SIGNAL(clicked()), this, SLOT(onClicked()));
    
    // Connect up the process handler
    QObject::connect(_browser, SIGNAL(started()), this, SLOT(onStarted()));
    QObject::connect(_browser, SIGNAL(finished(int, QProcess::ExitStatus)), this, SLOT(onFinished()));
    QObject::connect(_browser, SIGNAL(startFailed(QString)), this, SLOT(onFailed()));
}

void ProcessTest::onClicked()
{
    if (Started == _appState)
    {
        // Application is running: kill it
        _button->setText(tr("Terminating..."));
        _appState = Terminating;
        _browser->terminate();
    }
    else if (Terminating == _appState)
    {
        // Application is terminating: really kill it
        _button->setText(tr("Killing..."));
        _browser->kill();
    }
    else
    {
        // Application is not running: start it
        _button->setText(tr("Starting...") + _cmd);
        _browser->start(_cmd, QStringList());
    }
}

void ProcessTest::onStarted()
{
    // Application has started
    _button->setText(tr("Running..."));
    _appState = Started;
}

void ProcessTest::onFinished()
{
    // Application has finished
    _button->setText(tr("Stopped"));
    _appState = Stopped;
}

void ProcessTest::onFailed()
{
    // Application failed to start
    _button->setText(tr("Failed"));
    _appState = Stopped;
}
