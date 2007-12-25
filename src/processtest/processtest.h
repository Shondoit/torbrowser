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
    // The push button
    QPushButton *_button;
    // Process handler
    BrowserProcess *_browser;
    // Command line to start
    QString _cmd;
};

#endif
