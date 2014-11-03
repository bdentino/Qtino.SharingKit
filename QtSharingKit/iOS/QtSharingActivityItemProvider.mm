#import "QtSharingActivityItemProvider.h"

#include "FBDialogs.h"
#include "FBAppCall.h"
#include "FBSession.h"
#include "FBOpenGraphAction.h"
#include "FBOpenGraphObject.h"
#include "FBErrorUtility.h"
#include "FBRequestConnection.h"

#include <QUrl>
#include <QDebug>

#include "ShareableItem.h"
#include "ShareableImageItem.h"
#include "TextItem.h"
#include "FacebookContent.h"
#include "TwitterContent.h"
#include "SmsContent.h"
#include "EmailContent.h"
#include "OpenGraphStory.h"
#include "OpenGraphAction.h"
#include "OpenGraphObject.h"

//TODO: Need to test different permissions/login scenarios
//TODO: Need to add signals for activity progress

id qVariantToNSObject(QVariant value)
{
    QMetaType::Type type = (QMetaType::Type)(value.type());

    if (type == QMetaType::Bool) {
        return [NSNumber numberWithBool: (value.toBool() ? YES : NO)];
    }
    else if (type == QMetaType::Int) {
        return [NSNumber numberWithInt: value.toInt()];
    }
    else if (type == QMetaType::Double) {
        return [NSNumber numberWithDouble: value.toDouble()];
    }
    else if (type == QMetaType::Float) {
        return [NSNumber numberWithFloat: value.toFloat()];
    }
    else if (type == QMetaType::QString) {
        return value.toString().toNSString();
    }
    else if (type == QMetaType::QUrl) {
        return value.toUrl().toNSURL();
    }
    else if (type == QMetaType::QStringList) {
        QStringList values = value.toStringList();
        NSMutableArray* array = [NSMutableArray arrayWithCapacity: values.size()];
        foreach (QString listItem, values)
        {
            [array addObject: listItem.toNSString()];
        }
        return [NSArray arrayWithArray: array];
    }
    else if (type == QMetaType::QVariantList) {
        QVariantList values = value.toList();
        NSMutableArray* array = [NSMutableArray arrayWithCapacity: values.size()];
        foreach (QVariant listItem, values)
        {
            [array addObject: qVariantToNSObject(listItem)];
        }
        return [NSArray arrayWithArray: array];
    }
    else if (type == QMetaType::QVariantMap) {
        QVariantMap valueMap = value.toMap();
        NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithCapacity: valueMap.keys().count()];
        foreach (QString name, valueMap.keys())
        {
            [dict setObject: qVariantToNSObject(valueMap.value(name)) forKey: name.toNSString()];
        }
        return [NSDictionary dictionaryWithDictionary: dict];
    }
    else if (value.canConvert(QMetaType::QVariantList)) {
        NSMutableArray* array = [NSMutableArray arrayWithCapacity: 1];
        QSequentialIterable iterable = value.value<QSequentialIterable>();
        foreach (QVariant listItem, iterable)
        {
            [array addObject: qVariantToNSObject(listItem)];
        }
        return [NSArray arrayWithArray: array];
    }
    else if (value.canConvert(QMetaType::QObjectStar)) {
        qWarning("QVariantToNSObject warning: QObject* types do not directly translate to a useful NSObject type.");
        return [[NSObject alloc] init];
    }
    else {
        qWarning("QVariantToNSObject warning: Conversion of MetaType %s to NSObject is not yet supported",
               qPrintable(value.typeName()));
        return nil;
    }
}

@interface QtSharingActivityItemProvider ()

- (void) shareWithFacebook;
- (NSArray*) defaultContent;

- (void) shareOpenGraphStory: (OpenGraphStory*) story withSession: (FBSession*) session;
- (id<FBOpenGraphObject>) getFBObjectFrom: (OpenGraphObject*) object;
- (void) trySharingAction: (id<FBOpenGraphAction>) action ofType: (NSString*) actionType withPreviewProperty: (NSString*) previewProperty;
- (void) publishFBObject: (id<FBOpenGraphObject>) object thenDo: (void (^)(NSString* objectId)) successCallback;
- (void) postFBObject: (id<FBOpenGraphObject>) object thenDo: (void (^)(NSString* objectId)) successCallback;
- (void) openFBSessionForPublishThenDo: (void (^)(FBSession* session)) successCallback;
- (void) handleFBAuthError: (NSError*) error;

- (NSMutableArray*) getFBImageArrayFromObject: (OpenGraphObject*) action;
- (NSMutableArray*) getFBImageArrayFromAction: (OpenGraphAction*) object;
- (NSMutableArray*) getFBImageArrayFromProperty: (QVariant) imgProperty;
@end

@implementation QtSharingActivityItemProvider {
    QHash<QString, DefaultContent*> _contentItems;
    QtSharingKitApi* _api;
    BOOL _sharingToFB;
}

+ (void) load {
    NSLog(@"Loading QtSharingActivityItemProvider");
}

- (id) initWithContent: (QHash<QString, DefaultContent*>) content api: (QtSharingKitApi*) api
{
    _contentItems = content;
    _api = api;
    _sharingToFB = NO;
    return self;
}

- (void) sharingFinished
{
    if (!_sharingToFB)
        _api->sharingFinished();
}

- (NSArray*) activityViewController: (UIActivityViewController*) activityViewController
             itemsForActivityType: (NSString*) activityType
{
    if ([activityType isEqualToString:UIActivityTypePostToFacebook] && _contentItems.contains("FacebookContent"))
    {
        [activityViewController dismissViewControllerAnimated:YES completion: nil];
        [self shareWithFacebook];
        return nil;
    } else if ([activityType isEqualToString:UIActivityTypePostToTwitter] && _contentItems.contains("TwitterContent"))
    {
        TwitterContent* twitContent = qobject_cast<TwitterContent*>(_contentItems.value("TwitterContent"));
        if (!twitContent) return nil;
        NSMutableArray* array = [NSMutableArray arrayWithCapacity: 1];
        if (!twitContent->text().isEmpty())
        {
            [array addObject: twitContent->text().toNSString()];
        }
        foreach (ShareableItem* item, twitContent->attachments())
        {
            if (qobject_cast<TextItem*>(item))
            {
                [array addObject: qobject_cast<TextItem*>(item)->text().toNSString()];
            }
            else if (qobject_cast<ShareableImageItem*>(item))
            {
                QUrl imgUrl = qobject_cast<ShareableImageItem*>(item)->url();
                if (!imgUrl.isLocalFile())
                {
                    NSLog(@"[WARN] Cannot add image at URL %@ - Sharing non-local image files is not yet supported", imgUrl.toString().toNSString());
                    continue;
                }
                [array addObject: imgUrl.toNSURL()];
            }
        }
        return [NSArray arrayWithArray: array];
    } else if ([activityType isEqualToString:UIActivityTypeMessage] && _contentItems.contains("SmsContent")) {
        SmsContent* smsContent = qobject_cast<SmsContent*>(_contentItems.value("SmsContent"));
        if (!smsContent) return nil;
        NSMutableArray* array = [NSMutableArray arrayWithCapacity: 1];
        if (!smsContent->body().isEmpty())
        {
            [array addObject: smsContent->body().toNSString()];
        }
        foreach (ShareableItem* item, smsContent->attachments())
        {
            if (qobject_cast<TextItem*>(item))
            {
                [array addObject: qobject_cast<TextItem*>(item)->text().toNSString()];
            }
            else if (qobject_cast<ShareableImageItem*>(item))
            {
                QUrl imgUrl = qobject_cast<ShareableImageItem*>(item)->url();
                if (!imgUrl.isLocalFile())
                {
                    NSLog(@"[WARN] Cannot add image at URL %@ - Sharing non-local image files is not yet supported", imgUrl.toString().toNSString());
                    continue;
                }
                QString imgFile = imgUrl.path();
                UIImage* image = [UIImage imageWithContentsOfFile: imgFile.toNSString()];
                if (image != nil)
                {
                    [array addObject: image];
                }
            }
        }
        return [NSArray arrayWithArray: array];
    } else if ([activityType isEqualToString:UIActivityTypeMail] && _contentItems.contains("EmailContent")) {
        EmailContent* emailContent = qobject_cast<EmailContent*>(_contentItems.value("EmailContent"));
        if (!emailContent) return nil;
        NSMutableArray* array = [NSMutableArray arrayWithCapacity: 1];
        if (!emailContent->body().isEmpty()) {
            [array addObject: emailContent->body().toNSString()];
        }
        foreach (ShareableItem* item, emailContent->attachments())
        {
            if (qobject_cast<TextItem*>(item))
            {
                [array addObject: qobject_cast<TextItem*>(item)->text().toNSString()];
            }
            else if (qobject_cast<ShareableImageItem*>(item))
            {
                QUrl imgUrl = qobject_cast<ShareableImageItem*>(item)->url();
                if (!imgUrl.isLocalFile())
                {
                    NSLog(@"[WARN] Cannot add image at URL %@ - Sharing non-local image files is not yet supported", imgUrl.toString().toNSString());
                    continue;
                }
                QString imgFile = imgUrl.path();
                UIImage* image = [UIImage imageWithContentsOfFile: imgFile.toNSString()];
                if (image != nil) {
                    [array addObject: image];
                }
            }
        }
        return [NSArray arrayWithArray: array];
    } else {
        return [self defaultContent];
    }
}

- (NSArray*) defaultContent
{
    DefaultContent* defaultContent = _contentItems.value("DefaultContent");
    if (defaultContent == nil) return @[];

    NSMutableArray* array = [NSMutableArray arrayWithCapacity: 1];
    foreach (ShareableItem* item, defaultContent->attachments())
    {
        if (qobject_cast<TextItem*>(item))
        {
            [array addObject: qobject_cast<TextItem*>(item)->text().toNSString()];
        }
        else if (qobject_cast<ShareableImageItem*>(item))
        {
            [array addObject: qobject_cast<ShareableImageItem*>(item)->url().toNSURL()];
        }
    }
    return [NSArray arrayWithArray: array];
}

- (NSArray*) activityViewControllerPlaceholderItems: (UIActivityViewController*) activityViewController
{
    Q_UNUSED(activityViewController);
    return [self defaultContent];
}

- (NSString*) activityViewController: (UIActivityViewController*) activityViewController subjectForActivityType: (NSString*) activityType
{
    Q_UNUSED(activityViewController);
    if ([activityType isEqualToString:UIActivityTypeMail] && _contentItems.contains("EmailContent")) {
        EmailContent* emailContent = qobject_cast<EmailContent*>(_contentItems.value("EmailContent"));
        if (!emailContent) return nil;
        return emailContent->subject().toNSString();
    }
    return nil;
}

- (void) shareWithFacebook
{
    FacebookContent* fbContent = qobject_cast<FacebookContent*>(_contentItems.value("FacebookContent"));
    if (!fbContent) return;

    foreach (ShareableItem* item, fbContent->attachments())
    {
        if (qobject_cast<OpenGraphStory*>(item))
        {
            _sharingToFB = YES;
            bool prepublish = false;
            if (fbContent->attachments().size() > 1) {
                NSLog(@"[WARN] Sharing multiple attachments alongside an OpenGraphStory is not supported.");
            }
            OpenGraphStory* story = qobject_cast<OpenGraphStory*>(item);
            OpenGraphAction* action = story->action();
            QString previewProperty = story->previewPropertyName();
            if (action->publishProperties().size() > 0) {
                prepublish = true;
            }

            if (prepublish)
            {
                [self openFBSessionForPublishThenDo: ^(FBSession* session) {
                    [self shareOpenGraphStory: story withSession: session];
                }];
            }
            else
            {
                [self shareOpenGraphStory: story withSession: nil];
            }
        }
    }
}

- (void) shareOpenGraphStory: (OpenGraphStory*) story withSession: (FBSession*) session
{
    Q_UNUSED(session);

    NSLog(@"Sharing open graph story");
    OpenGraphAction* action = story->action();
    NSString* previewProperty = story->previewPropertyName().toNSString();
    QStringList prepublishable = action->publishProperties();
    NSString* actionType = action->type().toNSString();
    NSMutableDictionary* objectsToPublish = [NSMutableDictionary dictionaryWithCapacity: prepublishable.count()];

    NSMutableDictionary<FBOpenGraphAction>* fbAction = [FBGraphObject openGraphActionForPost];
    foreach (QString property, action->additionalProperties().keys())
    {
        QVariant value = action->additionalProperties().value(property);
        if (property == "image")
        {
            [fbAction setObject: [self getFBImageArrayFromProperty: value] forKey: @"image"];
        }
        else if (qvariant_cast<OpenGraphObject*>(value))
        {
            id<FBOpenGraphObject> fbObject = [self getFBObjectFrom: qvariant_cast<OpenGraphObject*>(value)];
            [fbAction setObject: fbObject forKey: property.toNSString()];
            if (prepublishable.contains(property))
                [objectsToPublish setObject: fbObject forKey: property.toNSString()];
        }
        else
        {
            id object = qVariantToNSObject(value);
            [fbAction setObject: object forKey: property.toNSString()];
        }
    }

    NSMutableArray* pendingObjects = [NSMutableArray arrayWithArray: [objectsToPublish allValues]];
    for (NSString* key in objectsToPublish)
    {
        id<FBOpenGraphObject> object = [objectsToPublish objectForKey: key];
        [self publishFBObject: object thenDo: ^(NSString* objectId) {
            [pendingObjects removeObject: object];
            [fbAction setObject: objectId forKey: key];
            if ([pendingObjects count] == 0) {
                [self trySharingAction: fbAction ofType: actionType withPreviewProperty: previewProperty];
            }
        }];
    }

    if ([pendingObjects count] == 0) {
        [self trySharingAction: fbAction ofType: actionType withPreviewProperty: previewProperty];
    }
}

- (void) trySharingAction: (id<FBOpenGraphAction>) action ofType: actionType withPreviewProperty: (NSString*) previewProperty
{

    NSArray* actionImages = [action objectForKey: @"image"];
    NSMutableArray* finalizedActionImages = [NSMutableArray arrayWithCapacity: [actionImages count]];
    for (NSDictionary* imageInfo in actionImages)
    {
        NSString* isLocal = [imageInfo objectForKey: @"local"];
        if ([isLocal isEqualToString: @"true"])
        {
            NSMutableDictionary* finalizedInfo = [NSMutableDictionary dictionaryWithDictionary: imageInfo];
            NSString* filePath = [imageInfo objectForKey: @"url"];
            [finalizedInfo setObject: [UIImage imageWithContentsOfFile: filePath] forKey: @"url"];
            [finalizedActionImages addObject: finalizedInfo];
        }
        else
        {
            [finalizedActionImages addObject: imageInfo];
        }
    }

    if ([finalizedActionImages count] > 0)
    {
        [action removeObjectForKey: @"image"];
        [action setObject: finalizedActionImages forKey: @"image"];
    }

    id previewObject = [action objectForKey: previewProperty];
    NSArray* previewImages = [previewObject objectForKey: @"image"];
    NSMutableArray* finalizedPreviewImages = [NSMutableArray arrayWithCapacity: [previewImages count]];
    for (NSDictionary* imageInfo in previewImages)
    {
        NSString* isLocal = [imageInfo objectForKey: @"local"];
        if ([isLocal isEqualToString: @"true"])
        {
            NSMutableDictionary* finalizedInfo = [NSMutableDictionary dictionaryWithDictionary: imageInfo];
            NSString* filePath = [imageInfo objectForKey: @"url"];
            [finalizedInfo setObject: [UIImage imageWithContentsOfFile: filePath] forKey: @"url"];
            [finalizedInfo removeObjectForKey: @"local"];
            [finalizedPreviewImages addObject: finalizedInfo];
        }
        else
        {
            [finalizedPreviewImages addObject: imageInfo];
        }
    }
    if ([finalizedPreviewImages count] > 0) {
        NSLog(@"Setting object images: %@", finalizedPreviewImages);
        [previewObject removeObjectForKey: @"image"];
        [previewObject setObject: finalizedPreviewImages forKey: @"image"];
    }

    NSLog(@"Presenting share dialog");
    [FBDialogs
        presentShareDialogWithOpenGraphAction: action
        actionType: actionType
        previewPropertyName: previewProperty
        handler: ^(FBAppCall* call, NSDictionary* results, NSError* error)
        {
            Q_UNUSED(call)
            if(error)
            {
                NSLog(@"[ERROR] Could Not Publish Story: %@", error.description);
            }
            else
            {
                NSLog(@"Story Shared Successfully! (Results = %@)", results);
            }
            _sharingToFB = NO;
            _api->sharingFinished();
        }
    ];
}

- (void) openFBSessionForPublishThenDo: (void (^)(FBSession*)) successCallback
{
    NSLog(@"Opening Session for Publish");
    [FBSession
        openActiveSessionWithPublishPermissions: @[@"publish_actions"]
        defaultAudience: FBSessionDefaultAudienceFriends
        allowLoginUI: true
        completionHandler: ^(FBSession* session, FBSessionState status, NSError* error)
        {
            NSLog(@"Completion handler called");
            if(error)
            {
                NSLog(@"[ERROR] Could Not Obtain Publish Permissions: %@", error.description);
                [self handleFBAuthError: error];
            }
            else if (status == FBSessionStateOpen)
            {
                [session refreshPermissionsWithCompletionHandler: ^(FBSession* session, NSError* error)
                {
                    if (error)
                    {
                        [self handleFBAuthError: error];
                        return;
                    }

                    if ([session.permissions indexOfObject: @"publish_actions"] != NSNotFound)
                    {
                        NSLog(@"Session opened with publish permission");
                        successCallback(session);
                    }
                    else {
                        UIAlertView* alert = [[UIAlertView alloc] initWithTitle: @"Enable Post Permissions to Allow Sharing on Facebook"
                                                                  message: @"This app will never post anything without your explicit approval."
                                                                  delegate: self
                                                                  cancelButtonTitle: @"Cancel"
                                                                  otherButtonTitles: @"Settings", nil];
                        [alert show];
                        _sharingToFB = NO;
                    }
                }];
            }
            else {
                NSLog(@"FBSession status is %d", status);
            }
        }
    ];
}

- (void) publishFBObject: (id<FBOpenGraphObject>) object thenDo: (void (^)(NSString* objectId)) successCallback
{
    NSLog(@"Publishing Object");
    NSArray* images = [object objectForKey: @"image"];
    NSMutableArray* pendingImagePosts = [NSMutableArray arrayWithArray: images];
    NSMutableArray* finalImages = [NSMutableArray arrayWithCapacity: [images count]];

    for (NSDictionary* imageInfo in images)
    {
        NSString* local = [imageInfo objectForKey: @"local"];
        BOOL isLocal = [local isEqualToString: @"true"] ? YES : NO;
        if (isLocal)
        {
            NSMutableDictionary* newImageInfo = [NSMutableDictionary dictionaryWithDictionary: imageInfo];
            NSString* filePath = [imageInfo objectForKey: @"url"];
            UIImage* image = [UIImage imageWithContentsOfFile: filePath];
            if (image != nil)
            {
                [FBRequestConnection startForUploadStagingResourceWithImage:image completionHandler:^(FBRequestConnection* connection, id result, NSError* error) {
                    Q_UNUSED(connection);
                    if(!error)
                    {
                        NSLog(@"Image Staged");
                        [newImageInfo setObject: [result objectForKey:@"uri"] forKey: @"url"];
                        [newImageInfo setObject: @"false" forKey: @"local"];
                        [finalImages addObject: newImageInfo];
                    }
                    else
                    {
                        NSLog(@"[ERROR] Could Not Stage Image: %@", error.description);
                    }
                    [pendingImagePosts removeObject: imageInfo];
                    if ([pendingImagePosts count] == 0)
                    {
                        NSLog(@"Ready to post object");
                        [object setObject: finalImages forKey: @"image"];
                        [self postFBObject: object thenDo: successCallback];
                    }
                }];
            }
            else
            {
                NSLog(@"[ERROR] Could Not Load Image For Staging: %@", filePath);
            }
        }
        else {
            [finalImages addObject: imageInfo];
            [pendingImagePosts removeObject: imageInfo];
        }

        if ([pendingImagePosts count] == 0)
        {
            [object setObject: finalImages forKey: @"image"];
            [self postFBObject: object thenDo: successCallback];
        }
    }
}

- (void) postFBObject: (id<FBOpenGraphObject>) object thenDo: (void (^)(NSString* objectId)) successCallback
{
    NSLog(@"Posing FB Object");
    [FBRequestConnection startForPostOpenGraphObject:object completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        Q_UNUSED(connection);
        if(!error)
        {
            NSLog(@"Object posted: %@", result);
            successCallback(result);
        }
        else
        {
            NSLog(@"[ERROR] Could Not Post Open Graph Object: %@", error.description);
            _sharingToFB = NO;
            _api->sharingFinished();
        }
    }];
}

- (id<FBOpenGraphObject>) getFBObjectFrom: (OpenGraphObject*) object
{
    NSMutableDictionary<FBOpenGraphObject>* fbObject = [FBGraphObject openGraphObjectForPost];
    fbObject.type = object->type().toNSString();
    foreach (QString property, object->additionalProperties().keys())
    {
        QVariant value = object->additionalProperties().value(property);
        if (property == "image") {
            [fbObject setObject: [self getFBImageArrayFromProperty: value] forKey: @"image"];
        }
        else if (qvariant_cast<OpenGraphObject*>(value))
        {
            id<FBOpenGraphObject> childObject = [self getFBObjectFrom: qvariant_cast<OpenGraphObject*>(value)];
            [fbObject setObject: childObject forKey: property.toNSString()];
        }
        else
        {
            id object = qVariantToNSObject(value);
            [fbObject setObject: object forKey: property.toNSString()];
        }
    }
    return fbObject;
}

- (NSMutableArray*) getFBImageArrayFromObject: (OpenGraphObject*) object
{
    return [self getFBImageArrayFromProperty: object->additionalProperties().value("image")];
}

- (NSMutableArray*) getFBImageArrayFromAction: (OpenGraphAction*) action
{
    return [self getFBImageArrayFromProperty: action->additionalProperties().value("image")];
}

- (NSMutableArray*) getFBImageArrayFromProperty: (QVariant) imgProperty
{
    if (!imgProperty.isValid() || imgProperty.isNull())
        return [NSMutableArray arrayWithCapacity: 0];

    NSMutableArray* array = [NSMutableArray arrayWithCapacity: 1];
    QMetaType::Type type = (QMetaType::Type)(imgProperty.type());
    if (qvariant_cast<ShareableImageItem*>(imgProperty))
    {
        // Single image object
        ShareableImageItem* image = qvariant_cast<ShareableImageItem*>(imgProperty);
        NSString* url = image->url().path().toNSString();
        NSString* userGenerated = @"false";
        NSString* local = image->url().isLocalFile() ? @"true" : @"false";
        [array addObject: @{
            @"url": url,
            @"user_generated": userGenerated,
            @"local": local
        }];
    }
    else if (type == QMetaType::QUrl)
    {
        NSString* url = imgProperty.toUrl().toString().toNSString();
        NSString* userGenerated = @"false";
        NSString* local = imgProperty.toUrl().isLocalFile() ? @"true" : @"false";
        [array addObject: @{
            @"url": url,
            @"user_generated": userGenerated,
            @"local": local
        }];
    }
    else if (type == QMetaType::QString)
    {
        NSString* url = imgProperty.toString().toNSString();
        NSString* userGenerated = @"false";
        NSString* local = imgProperty.toUrl().isLocalFile() ? @"true" : @"false";
        [array addObject: @{
            @"url": url,
            @"user_generated": userGenerated,
            @"local": local
        }];
    }
    else if (type == QMetaType::QVariantMap)
    {
        QVariantMap map = imgProperty.toMap();
        NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithCapacity: map.keys().count()];
        foreach (QString mapKey, map.keys())
        {
            NSString* key = mapKey.toNSString();
            NSString* value = map.value(mapKey).toString().toNSString();
            [dict setObject: value forKey: key];
        }
        QUrl url(QString::fromNSString([dict objectForKey: @"url"]));
        if (url.isLocalFile())
        {
            [dict setObject: @"true" forKey: @"local"];
        }
        else
        {
            [dict setObject: @"false" forKey: @"local"];
        }
        [array addObject: dict];
    }
    else if (imgProperty.canConvert(QMetaType::QVariantList))
    {
        // array of images
        QSequentialIterable iterable = imgProperty.value<QSequentialIterable>();
        foreach (QVariant listItem, iterable)
        {
            [array addObjectsFromArray: [self getFBImageArrayFromProperty: listItem]];
        }
    }
    return array;
}

- (void) handleFBAuthError: (NSError*) error
{
    FBErrorCategory category = [FBErrorUtility errorCategoryForError: error];
    NSLog(@"[ERROR] Facebook Authorization Error: Category = %d", category);
    if ([FBErrorUtility shouldNotifyUserForError: error])
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle: @"Can't Share on Facebook"
                                                  message: [FBErrorUtility userMessageForError:error]
                                                  delegate: self
                                                  cancelButtonTitle: @"OK"
                                                  otherButtonTitles: nil];
        [alert show];
        _sharingToFB = NO;
        _api->sharingFinished();
    }
    else
    {
        if (category == FBErrorCategoryUserCancelled) {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle: @"Can't Share on Facebook"
                                                      message: @"You must be logged in to share with Facebook"
                                                      delegate: self
                                                      cancelButtonTitle: @"OK"
                                                      otherButtonTitles: nil];
            [alert show];
            _sharingToFB = NO;
            _api->sharingFinished();
        }
        else if (category == FBErrorCategoryAuthenticationReopenSession)
        {
            [[FBSession activeSession] closeAndClearTokenInformation];
            [self openFBSessionForPublishThenDo: ^(FBSession* session) {
                Q_UNUSED(session);
                //TODO: Add Retry Sharing
                NSLog(@"Do Nothing...");
            }];

            _sharingToFB = NO;
            _api->sharingFinished();
        }
        else
        {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle: @"Something went wrong"
                                                      message: @"Please try sharing to Facebook again"
                                                      delegate: self
                                                      cancelButtonTitle: @"OK"
                                                      otherButtonTitles: nil];
            [alert show];
            _sharingToFB = NO;
            _api->sharingFinished();
        }
    }
}

@end
