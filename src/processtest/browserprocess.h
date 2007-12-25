/**
 ** Test invoking Firefox from Qt
 ** Steven J. Murdoch <http://www.cl.cam.ac.uk/users/sjm217/>
 ** $Id$
 **/

#ifndef _BROWSERPROCESS_H
#define _BROWSERPROCESS_H

#include <QProcess>

class BrowserProcess : public QProcess
{
  Q_OBJECT

public:
  // Default constructor
  BrowserProcess(QObject *parent = 0);
  // Start the specified application
  void start(QString app, QStringList args);

private slots:
  // Invoked when underlying QProcess fails
  void onError(QProcess::ProcessError error);

signals:
  // Invoked when start() fails
  void startFailed(QString errorMessage);
};

#endif
