/**
 ** Test invoking Firefox from Qt
 ** Steven J. Murdoch <http://www.cl.cam.ac.uk/users/sjm217/>
 ** $Id$
 **/

#include <QString>
  
#include "browserprocess.h"

BrowserProcess::BrowserProcess(QObject *parent)
: QProcess(parent)
{
  // Call error handling routine on errors
  QObject::connect(this, SIGNAL(error(QProcess::ProcessError)), this, SLOT(onError(QProcess::ProcessError)));
}

void
BrowserProcess::start(QString app, QStringList args) 
{
  // Start the specified application
  QProcess::start(app, args, QIODevice::ReadOnly | QIODevice::Text);
}

void
BrowserProcess::onError(QProcess::ProcessError error)
{
  // Pass up error messages on startup, but ignore the rest
  if (error == QProcess::FailedToStart) {
    emit startFailed(errorString());
  }
}
