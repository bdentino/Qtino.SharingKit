#include "QtSharingKitApi.h"
#include "FBAppCredentials.h"
#include "QtSharingOSKCustomizations.h"
#include "QtSharingViewController.h"

#include "OvershareKit.h"
#include "OSKShareableContent.h"
#include "OSKShareableContentItem.h"
#include "OSKPresentationManager.h"
#include "OSKActivitiesManager.h"

#include <UIKit/UIKit.h>
#include <UIKit/UIImage.h>

#include <QtGui/5.3.1/QtGui/qpa/qplatformnativeinterface.h>
#include <QGuiApplication>
#include <QQuickWindow>

struct QtSharingKitPrivate {
    QtSharingOSKCustomizations* OSKCustomizations = nil;
    QtSharingViewController* OSKSharingSheet = nil;
    QtSharingKitApi* api = nil;
};

QtSharingKitApi::QtSharingKitApi(QQuickItem *parent):
    QQuickItem(parent),
    m_fbCredentials(NULL),
    m_privateData(NULL)
{
    m_privateData = new QtSharingKitPrivate();
    m_privateData->OSKCustomizations = [[QtSharingOSKCustomizations alloc] init];
    m_privateData->OSKSharingSheet = [[QtSharingViewController alloc] init];
    m_privateData->api = this;

    OSKActivitiesManager* activitiesMgr = [OSKActivitiesManager sharedInstance];
    activitiesMgr.customizationsDelegate = m_privateData->OSKCustomizations;
}

QtSharingKitApi::~QtSharingKitApi()
{
    if (m_fbCredentials) m_fbCredentials->deleteLater();
    if (m_privateData) {
        [QtSharingOSKCustomizations release];
        [QtSharingViewController release];
        delete m_privateData;
    }
}

FBAppCredentials* QtSharingKitApi::facebookAppCredentials()
{
    return m_fbCredentials;
}

void QtSharingKitApi::setFacebookAppCredentials(FBAppCredentials* credentials)
{
    if (m_fbCredentials == credentials) return;
    m_fbCredentials = credentials;

    [m_privateData->OSKCustomizations setFacebookCredentials: credentials];

    emit facebookAppCredentialsChanged();
}

void QtSharingKitApi::openShareSheetForContent(QString title,
                                               QString blurb,
                                               QString text)
{
    // Get the UIView that backs our QQuickWindow:
    UIView *view = static_cast<UIView *>(
                QGuiApplication::platformNativeInterface()
                ->nativeResourceForWindow("uiview", window()));
    UIViewController *qtController = [[view window] rootViewController];

    // 1) Create the shareable content from the user's source content.
    NSString* sheetTitle = title.toNSString();
    NSString* subjectText = blurb.toNSString();
    NSString* contentText = text.toNSString();

    OSKShareableContent* content = [[OSKShareableContent alloc] init];
    content.title = sheetTitle;

    OSKMicroblogPostContentItem* microBlogItem = [[OSKMicroblogPostContentItem alloc] init];
    microBlogItem.text = contentText;
    content.microblogPostItem = microBlogItem;

    OSKSMSContentItem* smsItem = [[OSKSMSContentItem alloc] init];
    smsItem.body = contentText;
    content.smsItem = smsItem;

    OSKFacebookContentItem* facebookItem = [[OSKFacebookContentItem alloc] init];
    facebookItem.text = contentText;
    content.facebookItem = facebookItem;

    OSKEmailContentItem* emailItem = [[OSKEmailContentItem alloc] init];
    emailItem.subject = subjectText;
    emailItem.body = contentText;
    content.emailItem = emailItem;

    //QtSharingViewController* sheetManager = [[QtSharingViewController alloc] init];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        NSDictionary *options = @{};

        // 4) Present the activity sheet via the presentation manager.
        [[OSKPresentationManager sharedInstance] presentActivitySheetForContent:content
                                                 presentingViewController:qtController
                                                 options:options];
    }
}
