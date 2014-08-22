#include "QtSharingKitApi.h"
#include "FBAppCredentials.h"
#include "QtSharingOSKCustomizations.h"
#include "QtSharingViewController.h"
#include "FacebookContent.h"
#include "MicroblogContent.h"
#include "SmsContent.h"
#include "EmailContent.h"

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
#include <QDir>
#include <QFile>

UIImage* screenshot();

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

void QtSharingKitApi::launchShareActivity()
{
    UIView *view = static_cast<UIView *>(
                QGuiApplication::platformNativeInterface()
                ->nativeResourceForWindow("uiview", window()));
    UIViewController *qtController = [[view window] rootViewController];

    OSKShareableContent* content = [[OSKShareableContent alloc] init];
    content.title = title().toNSString();

    UIImage* uiimage = screenshot();
    foreach (QObject* child, children())
    {
        if (qobject_cast<FacebookContent*>(child))
        {
            if (content.facebookItem != nil)
            {
                qWarning("Warning: Cannot share multiple FacebookContent items");
                continue;
            }
            FacebookContent* fbContent = qobject_cast<FacebookContent*>(child);
            OSKFacebookContentItem* facebookItem = [[OSKFacebookContentItem alloc] init];
            QString postText = fbContent->text();
            if (fbContent->attachScreenshot())
            {
                facebookItem.images = @[uiimage];
                if (fbContent->link().isValid())
                {
                    postText += "\n";
                    postText += fbContent->link().toString();
                }
            }
            else if (fbContent->link().isValid())
            {
                facebookItem.link = fbContent->link().toNSURL();
            }
            facebookItem.text = postText.toNSString();
            content.facebookItem = facebookItem;
        }
        if (qobject_cast<MicroblogContent*>(child))
        {
            if (content.microblogPostItem != nil)
            {
                qWarning("Warning: Cannot share multiple MicroblogContent items");
                continue;
            }
            MicroblogContent* mbContent = qobject_cast<MicroblogContent*>(child);
            OSKMicroblogPostContentItem* microblogItem = [[OSKMicroblogPostContentItem alloc] init];
            if (mbContent->attachScreenshot())
            {
                microblogItem.images = @[uiimage];
            }
            microblogItem.text = mbContent->text().toNSString();
            content.microblogPostItem = microblogItem;
        }
        if (qobject_cast<SmsContent*>(child))
        {
            if (content.smsItem != nil)
            {
                qWarning("Warning: Cannot share multiple SmsContent items");
                continue;
            }
            SmsContent* smsContent = qobject_cast<SmsContent*>(child);
            OSKSMSContentItem* smsItem = [[OSKSMSContentItem alloc] init];
            if (smsContent->attachScreenshot())
            {
                smsItem.attachments = @[uiimage];
            }
            smsItem.body = smsContent->body().toNSString();
            content.smsItem = smsItem;
        }
        if (qobject_cast<EmailContent*>(child))
        {
            if (content.emailItem != nil)
            {
                qWarning("Warning: Cannot share multiple SmsContent items");
                continue;
            }
            EmailContent* emailContent = qobject_cast<EmailContent*>(child);
            OSKEmailContentItem* emailItem = [[OSKEmailContentItem alloc] init];
            if (emailContent->attachScreenshot())
            {
                emailItem.attachments = @[uiimage];
            }
            emailItem.subject = emailContent->subject().toNSString();
            emailItem.body = emailContent->body().toNSString();
            content.emailItem = emailItem;
        }
    }

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        NSDictionary *options = @{};
        [[OSKPresentationManager sharedInstance] presentActivitySheetForContent:content
                                                 presentingViewController:qtController
                                                 options:options];
    }
}

UIImage* screenshot()
{
    CGSize imageSize = CGSizeZero;

    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        imageSize = [UIScreen mainScreen].bounds.size;
    } else {
        imageSize = CGSizeMake([UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
    }

    UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    for (UIWindow *window in [[UIApplication sharedApplication] windows]) {
        CGContextSaveGState(context);
        CGContextTranslateCTM(context, window.center.x, window.center.y);
        CGContextConcatCTM(context, window.transform);
        CGContextTranslateCTM(context, -window.bounds.size.width * window.layer.anchorPoint.x, -window.bounds.size.height * window.layer.anchorPoint.y);
        if (orientation == UIInterfaceOrientationLandscapeLeft) {
            CGContextRotateCTM(context, M_PI_2);
            CGContextTranslateCTM(context, 0, -imageSize.width);
        } else if (orientation == UIInterfaceOrientationLandscapeRight) {
            CGContextRotateCTM(context, -M_PI_2);
            CGContextTranslateCTM(context, -imageSize.height, 0);
        } else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
            CGContextRotateCTM(context, M_PI);
            CGContextTranslateCTM(context, -imageSize.width, -imageSize.height);
        }
        if ([window respondsToSelector:@selector(drawViewHierarchyInRect:afterScreenUpdates:)]) {
            [window drawViewHierarchyInRect:window.bounds afterScreenUpdates:YES];
        } else {
            [window.layer renderInContext:context];
        }
        CGContextRestoreGState(context);
    }

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
