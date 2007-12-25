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
 
    // Connect up the button
    QObject::connect(_button, SIGNAL(clicked()), this, SLOT(onClicked()));
    
    // Connect up the process handler
    QObject::connect(_browser, SIGNAL(started()), this, SLOT(onStarted()));
    QObject::connect(_browser, SIGNAL(finished(int, QProcess::ExitStatus)), this, SLOT(onFinished()));
    QObject::connect(_browser, SIGNAL(startFailed(QString)), this, SLOT(onFailed()));
}

void ProcessTest::onClicked()
{
    // Start the application
    _button->setText(tr("Starting...") + _cmd);
    _browser->start(_cmd, QStringList());
}

void ProcessTest::onStarted()
{
    // Application has started
    _button->setText(tr("Running..."));
}

void ProcessTest::onFinished()
{
    // Application has finished
    _button->setText(tr("Stopped"));
}

void ProcessTest::onFailed()
{
    // Application failed to start
    _button->setText(tr("Failed"));
}
