#include "QtSharingKitApi.h"
#include "FBAppCredentials.h"
#include "FacebookContent.h"
#include "TwitterContent.h"
#include "SmsContent.h"
#include "EmailContent.h"
#include "ShareableItem.h"
#include "ShareableImageItem.h"

#include "QtSharingActivityItemProvider.h"
#include "QtSharingActivityViewController.h"

#include <UIKit/UIKit.h>
#include <UIKit/UIImage.h>
#include "FBDialogs.h"

#if QT_VERSION == 0x050500
#include <QtGui/5.5.0/QtGui/qpa/qplatformnativeinterface.h>
#elif QT_VERSION == 0x050400
#include <QtGui/5.4.0/QtGui/qpa/qplatformnativeinterface.h>
#elif QT_VERSION == 0x050300
#include <QtGui/5.3.0/QtGui/qpa/qplatformnativeinterface.h>
#endif


#include <QGuiApplication>
#include <QQuickWindow>
#include <QDir>
#include <QFile>

#import "FacebookCallbackHandler.h"
#import "QtSharingSwizzle.h"

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

struct QtSharingKitPrivate {
    QtSharingKitApi* api = nil;
    //FacebookCallbackHandler* fbHandler = [[FacebookCallbackHandler alloc] init];
};

QtSharingKitApi::QtSharingKitApi(QQuickItem *parent):
    QQuickItem(parent),
    m_privateData(NULL)
{
    m_privateData = new QtSharingKitPrivate();
    m_privateData->api = this;
}

QtSharingKitApi::~QtSharingKitApi()
{
    if (m_privateData) {
        delete m_privateData;
    }
}

void QtSharingKitApi::launchShareActivity()
{ 
    QHash<QString, DefaultContent*> contentItems;
    foreach (QObject* child, children())
    {
        if (qobject_cast<FacebookContent*>(child))
        {
            if (contentItems.contains("FacebookContent")) {
                qWarning("QtSharingKit - Cannot include multiple FacebookContent items. Only the first instance will be used.");
                return;
            }
            FacebookContent* fbContent = qobject_cast<FacebookContent*>(child);
            contentItems.insert("FacebookContent", fbContent);
        }
        else if (qobject_cast<TwitterContent*>(child))
        {
            if (contentItems.contains("TwitterContent")) {
                qWarning("QtSharingKit - Cannot include multiple TwitterContent items. Only the first instance will be used.");
                return;
            }
            TwitterContent* twContent = qobject_cast<TwitterContent*>(child);
            contentItems.insert("TwitterContent", twContent);
        }
        else if (qobject_cast<SmsContent*>(child))
        {
            if (contentItems.contains("SmsContent")) {
                qWarning("QtSharingKit - Cannot include multiple SmsContent items. Only the first instance will be used.");
                return;
            }
            SmsContent* smsContent = qobject_cast<SmsContent*>(child);
            contentItems.insert("SmsContent", smsContent);
        }
        else if (qobject_cast<EmailContent*>(child))
        {
            if (contentItems.contains("EmailContent")) {
                qWarning("QtSharingKit - Cannot include multiple EmailContent items. Only the first instance will be used.");
                return;
            }
            EmailContent* emailContent = qobject_cast<EmailContent*>(child);
            contentItems.insert("EmailContent", emailContent);
        }
        else if (qobject_cast<DefaultContent*>(child)) {
            if (contentItems.contains("DefaultContent")) {
                qWarning("QtSharingKit - Cannot include multiple DefaultContent items. Only the first instance will be used.");
                return;
            }
            DefaultContent* defaultContent = qobject_cast<DefaultContent*>(child);
            contentItems.insert("DefaultContent", defaultContent);
        }
    }

    UIView *view = static_cast<UIView *>(
                QGuiApplication::platformNativeInterface()
                ->nativeResourceForWindow("uiview", window()));
    UIViewController *qtController = [[view window] rootViewController];

    QtSharingActivityItemProvider* itemProvider = [[QtSharingActivityItemProvider alloc] initWithContent: contentItems api: this];
    UIActivityViewController* activityVC = [[QtSharingActivityViewController alloc] initWithDelegate: itemProvider];

    if (![FBDialogs canPresentShareDialog]) {
        activityVC.excludedActivityTypes = @[UIActivityTypePostToFacebook];
    }

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        [qtController presentViewController: activityVC animated: YES completion: nil];
    }
    else if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
    {
        QPointF point = this->mapToScene(QPointF(0, 0));
        CGRect rect = CGRectMake(point.x(), point.y(), width() == 0 ? 1 : width(), height() == 0 ? 1 : height());
        if(SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
        {
            activityVC.popoverPresentationController.sourceView = view;
            activityVC.popoverPresentationController.sourceRect = rect;
            [qtController presentViewController: activityVC animated: YES completion: nil];
        }
        else
        {
            UIPopoverController* popup = [[UIPopoverController alloc] initWithContentViewController: activityVC];
            [popup presentPopoverFromRect: rect inView: view permittedArrowDirections: UIPopoverArrowDirectionAny animated: YES];
        }
    }
}
