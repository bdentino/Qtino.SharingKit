package qtino.sharingkit;

import java.io.File;
import java.util.ArrayList;
import java.util.List;
import java.util.HashMap;
import org.json.JSONObject;

import android.content.Intent;
import android.app.Activity;
import android.support.v4.app.Fragment;
import android.net.Uri;
import android.util.Log;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.ViewGroup;
import android.view.View;
import android.widget.Toast;

import com.facebook.*;
import com.facebook.android.*;
import com.facebook.widget.*;
import com.facebook.model.*;

import android.content.pm.PackageInfo;
import android.content.pm.Signature;
import android.content.pm.PackageManager;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;

public class QtinoFacebookShareFragment extends Fragment {

    private UiLifecycleHelper uiHelper;
    private Activity mainActivity;

    private List<JavaQObject> pendingObjects = new ArrayList<JavaQObject>();
    private OpenGraphAction pendingAction;
    private String pendingPreview = "";
    private boolean preparing = false;
    private boolean publishRequestedInSession = false;
    private JavaQObject pendingStory;

    public QtinoFacebookShareFragment(Activity mainActivity) {
        this.mainActivity = mainActivity;
        uiHelper = new UiLifecycleHelper(mainActivity, new Session.StatusCallback() {
            public void call(Session session, SessionState state, Exception exception) {
                Log.w("FBShareActivity", "StatusCallBack in state " + state.toString());
                if (exception != null) {
                    exception.printStackTrace();
                }
            }
        });
    }

    @Override
    public void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Log.w("FBShareActivity", "OnCreate called for fragment");
        uiHelper.onCreate(null);
    }

    @Override
    public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState)
    {
        Log.w("FBShareActivity", "OnCreateView called for fragment");
        return null;
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        Log.w("FBShareActivity", "Activity result completed!");
        uiHelper.onActivityResult(requestCode, resultCode, data, new FacebookDialog.Callback() {
            @Override
            public void onError(FacebookDialog.PendingCall pendingCall, Exception error, Bundle data) {
                Log.w("FBShareActivity", String.format("Error: %s", error.toString()));
                error.printStackTrace();
            }

            @Override
            public void onComplete(FacebookDialog.PendingCall pendingCall, Bundle data) {
                Log.i("FBShareActivity", "Success!");
            }
        });
        Session.getActiveSession().onActivityResult(mainActivity, requestCode, resultCode, data);
        Log.w("FBShareActivity", "Done handling activity result " + resultCode);
    }

    @Override
    public void onResume() {
        Log.w("FBShareActivity", "OnResume called for fragment");
        super.onResume();
        uiHelper.onResume();
    }

    @Override
    public void onSaveInstanceState(Bundle outState) {
        super.onSaveInstanceState(outState);
        uiHelper.onSaveInstanceState(outState);
    }

    @Override
    public void onPause() {
        super.onPause();
        uiHelper.onPause();
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        uiHelper.onDestroy();
    }

    public void shareOpenGraphStory(JavaQObject story) {
        Session session = Session.getActiveSession();
        publishRequestedInSession = false;
        pendingStory = story;
        if (session == null || !session.isOpened()) {
            session = new Session.Builder(mainActivity).build();
        }
        final QtinoFacebookShareFragment fragmentContext = this;
        final JavaQObject storyContext = story;
        JavaQObject action = story.getProperty("action", new JavaQObject());
        boolean requirePublishPermissions = action.getProperty("publishProperties", new ArrayList<String>()).size() > 0;
        if (!(session.isOpened()) && requirePublishPermissions) {
            System.out.println("Opening Session");
            Session.setActiveSession(session);
            Session.OpenRequest openRequest = new Session.OpenRequest(this).setCallback(
                new Session.StatusCallback() {
                    public void call(Session session, SessionState state, Exception exception) {
                        Log.i("FBShareActivity", "Session Status Callback: " + state);
                        Log.i("FBShareActivity", "Exception " + exception);
                        if (state == SessionState.OPENED) {
                            List<String> permissions = new ArrayList<String>();
                            permissions.add("publish_actions");
                            List granted = session.getPermissions();
                            List declined = session.getDeclinedPermissions();
                            Log.i("FBShareActivity", "Session Opened - Granted: " + granted.toString());
                            Log.i("FBShareActivity", "Session Opened - Declined: " + declined.toString());
                            if (granted.contains("publish_actions")) {
                                fragmentContext.prepareOpenGraphStory(session, storyContext);
                            }
                            else if (fragmentContext.publishRequestedInSession) {
                                warnPublishPermissionsDeclined();
                            }
                            else {
                                requestPublishPermissions(session);
                            }
                        }
                        else if (state == SessionState.OPENED_TOKEN_UPDATED) {
                            List granted = session.getPermissions();
                            List declined = session.getDeclinedPermissions();
                            Log.i("FBShareActivity", "Session Updated - Granted: " + granted.toString());
                            Log.i("FBShareActivity", "Session Updated - Declined: " + declined.toString());
                            if (granted.contains("publish_actions")) {
                                prepareOpenGraphStory(session, storyContext);
                            }
                            else if (fragmentContext.publishRequestedInSession) {
                                warnPublishPermissionsDeclined();
                            }
                            else {
                                requestPublishPermissions(session);
                            }
                        }
                        else if (state == SessionState.CLOSED_LOGIN_FAILED) {
                            warnPublishPermissionsDeclined();
                            session.closeAndClearTokenInformation();
                        }
                    }
                }
            );
            session.openForRead(openRequest);
        }
        else if (requirePublishPermissions) {
            tryShareStoryInOpenSession(session, story, requirePublishPermissions);
        }
        else {
            tryShareStoryWithoutSession(story);
        }
    }

    private void tryShareStoryWithoutSession(JavaQObject story) {
        prepareOpenGraphStory(null, story);
    }

    private void tryShareStoryInOpenSession(Session session, JavaQObject story, boolean publishPermissions) {
        if (publishPermissions) {
            try {
                List<String> permissions = new ArrayList<String>();
                permissions.add("publish_actions");
                List granted = session.getPermissions();
                List declined = session.getDeclinedPermissions();
                if (granted.contains("publish_actions")) {
                    prepareOpenGraphStory(session, story);
                }
                else if (declined.contains("publish_actions")) {
                    warnPublishPermissionsDeclined();
                }
                else {
                    requestPublishPermissions(session);
                }
            } catch (Exception e) {
                int duration = Toast.LENGTH_SHORT;
                String alert = "Could not share to Facebook.";
                Toast toast = Toast.makeText(mainActivity, alert, duration);
                toast.show();
                e.printStackTrace();
            }
        }
        else {
            prepareOpenGraphStory(session, story);
        }
    }

    private void prepareOpenGraphStory(Session session, JavaQObject story) {
        final Session sessionContext = session;
        final JavaQObject storyContext = story;
        final QtinoFacebookShareFragment fragmentContext = this;

        final JavaQObject action = story.getProperty("action", new JavaQObject());
        final JavaQObject properties = action.getProperty("additionalProperties", new JavaQObject());
        final String type = action.getProperty("type", new String());
        final String previewProperty = story.getProperty("previewPropertyName", new String());
        ArrayList<String> publishable = action.getProperty("publishProperties", new ArrayList<String>());

        pendingAction = GraphObject.Factory.create(OpenGraphAction.class);
        pendingPreview = previewProperty;

        // Prepare Action
        final OpenGraphAction ogAction = pendingAction;
        ogAction.setType(type);
        preparing = true;
        for (final String property : properties.propertyNames()) {
            if (property.equals("image")) continue;

            Object obj = properties.getProperty(property, new Object());
            // Prepare object properties
            if (obj instanceof JavaQObject && ((JavaQObject)obj).getProperty("meta.type", new ArrayList<String>()).contains("OpenGraphObject")) {
                final boolean prepublish = publishable.contains(property);
                final JavaQObject jqObject = (JavaQObject)obj;
                pendingObjects.add(jqObject);
                prepareOpenGraphObject(sessionContext, jqObject, prepublish, new PrepareOpenGraphObjectCallback() {
                    public void onCompleted(OpenGraphObject ogObject) {
                        if (prepublish) {
                            fragmentContext.postOpenGraphObject(sessionContext, ogObject, new ObjectPostedCallback() {
                                public void onCompleted(OpenGraphObject ogObject) {
                                    fragmentContext.pendingObjects.remove(jqObject);
                                    ogAction.setProperty(property, ogObject);
                                    tryFinishOpenGraphStory();
                                }
                            });
                        }
                        else {
                            fragmentContext.pendingObjects.remove(jqObject);
                            ogAction.setProperty(property, ogObject);
                            tryFinishOpenGraphStory();
                        }
                    }
                });
            }

            // Set list properties as JSONObject
            else if (obj instanceof ArrayList) {
                Log.w("FBShareActivity", "Handling multiple values for property " + property + " is not implemented");
            }

            // Set untyped JavaQObject properties as JSONObject
            else if (obj instanceof JavaQObject) {
                Log.w("FBShareActivity", "Handling untyped map property for property " + property + " is not implemented");
            }

            // Set other properties
            else {
                System.out.println("Setting Action Property: " + property + " - " + obj.toString());
                ogAction.setProperty(property, obj);
            }
        }

        List<String> remoteImages = remotePaths(getImageUrls(action));
        ogAction.setImageUrls(remoteImages);

        preparing = false;
        tryFinishOpenGraphStory();
    }

    private void tryFinishOpenGraphStory() {
        if (pendingObjects.size() > 0 || preparing) return;
        if (pendingAction == null) return;
        if (pendingStory == null) return;

        JavaQObject jqAction = pendingStory.getProperty("action", new JavaQObject());

        FacebookDialog.OpenGraphActionDialogBuilder builder = new FacebookDialog.OpenGraphActionDialogBuilder(mainActivity, pendingAction, pendingAction.getType(), pendingPreview);

        // Set action images
        List<Bitmap> actionImages = new ArrayList<Bitmap>();
        for (String localImage : localPaths(getImageUrls(jqAction))) {
            actionImages.add(BitmapFactory.decodeFile(localImage));
        }
        boolean userGenerated = false; // TODO: Make this configurable
        if (actionImages.size() > 0) builder.setImageAttachmentsForAction(actionImages, userGenerated);

        ArrayList<String> prepublished = jqAction.getProperty("publishProperties", new ArrayList<String>());
        JavaQObject properties = jqAction.getProperty("additionalProperties", new JavaQObject());
        for (String property : properties.propertyNames()) {
            if (prepublished.contains(property)) continue; // This object has been published, which means its local images have already been staged

            JavaQObject value = properties.getProperty(property, new JavaQObject());
            if (value.getProperty("meta.type", new ArrayList<String>()).contains("OpenGraphObject")) {
                List<Bitmap> objectImages = new ArrayList<Bitmap>();
                for (String localImage : localPaths(getImageUrls(value))) {
                    Log.w("FBShareActivity", "Attaching " + localImage + " to object " + property);
                    objectImages.add(BitmapFactory.decodeFile(localImage));
                }
                userGenerated = false;
                if (objectImages.size() > 0) builder.setImageAttachmentsForObject(property, objectImages, userGenerated);
            }
        }

        FacebookDialog shareDialog = builder.setFragment(this).build();
        uiHelper.trackPendingDialogCall(shareDialog.present());
    }

    class PrepareOpenGraphObjectCallback {
        public void onCompleted(OpenGraphObject ogObject) { }
    }

    // Prepares open graph object (includes staging images)
    private void prepareOpenGraphObject(Session session, JavaQObject jqObject, boolean prepublish, PrepareOpenGraphObjectCallback callback) {
        final Session sessionContext = session;
        final String objectType = jqObject.getProperty("type", new String());
        final PrepareOpenGraphObjectCallback callbackContext = callback;
        final QtinoFacebookShareFragment fragmentContext = this;

        final OpenGraphObject mainOgObject = OpenGraphObject.Factory.createForPost(objectType);
        final JavaQObject properties = jqObject.getProperty("additionalProperties", new JavaQObject());

        for (final String property : properties.propertyNames()) {
            if (property.equals("image")) continue;

            Object object = properties.getProperty(property, new Object());
            // Prepare object properties
            if (object instanceof JavaQObject && ((JavaQObject)object).getProperty("meta.type", new ArrayList<String>()).contains("OpenGraphObject")) {
                final JavaQObject subObject = (JavaQObject)object;
                pendingObjects.add(subObject);
                prepareOpenGraphObject(sessionContext, subObject, true, new PrepareOpenGraphObjectCallback() {
                    public void onCompleted(OpenGraphObject ogObject) {
                        fragmentContext.pendingObjects.remove(subObject);
                        mainOgObject.setProperty(property, ogObject);
                        tryFinishOpenGraphStory();
                    }
                });
            }

            // Set list properties as JSONObject
            else if (object instanceof ArrayList) {
                Log.w("FBShareActivity", "Handling multiple values for property " + property + " is not supported (yet)");
            }

            // Set untyped JavaQObject properties as JSONObject
            else if (object instanceof JavaQObject) {
                Log.w("FBShareActivity", "Handling untyped map property for property " + property + " is not supported (yet)");
            }

            // Set other properties
            else {
                mainOgObject.setProperty(property, object);
            }
        }

        final List<Uri> uris = getImageUrls(jqObject);

        if (prepublish) {
            System.out.println("Staging " + localPaths(uris).size() + " images");
            stageImages(session, localPaths(uris), new ImageStagingRequestBatch.Callback() {
                public void onCompleted(List<String> stagedUris) {
                    for (String path : remotePaths(uris)) { stagedUris.add(path); }
                    mainOgObject.setImageUrls(stagedUris);
                    callbackContext.onCompleted(mainOgObject);
                }
            });
        }
        else {
            mainOgObject.setImageUrls(remotePaths(uris));
            callback.onCompleted(mainOgObject);
        }
    }

    private List<Uri> getImageUrls(JavaQObject object) {
        ArrayList<Uri> uris = new ArrayList<Uri>();
        ArrayList imagesContainer = new ArrayList();

        JavaQObject properties = object.getProperty("additionalProperties", new JavaQObject());
        Object imageProperty = properties.getProperty("image", new Object());
        if (!(imageProperty instanceof ArrayList)) {
            imagesContainer.add(imageProperty);
        } else {
            imagesContainer = (ArrayList)imageProperty;
        }

        for (Object imageObject : imagesContainer)  {
            System.out.println("ImageObject: " + imageObject.toString());
            if (imageObject instanceof JavaQObject) {
                uris.add(Uri.parse(((JavaQObject)imageObject).getProperty("url", new String())));
            }
            else if (imageObject instanceof String) {
                uris.add(Uri.parse((String)imageObject));
            }
            else {
                Log.w("FBShareActivity", "Unsupported type for OpenGraphObject image property");
            }
        }
        return uris;
    }

    private List<String> localPaths(List<Uri> urls) {
        List<String> localPaths = new ArrayList<String>();
        for (Uri uri : urls) {
            if (uri.getScheme().equals("file")) {
                String path = uri.getPath();
                if (!localPaths.contains(path)) { localPaths.add(path); }
            }
        }
        return localPaths;
    }

    private List<String> remotePaths(List<Uri> urls) {
        List<String> remotePaths = new ArrayList<String>();
        for (Uri uri : urls) {
            if (!uri.getScheme().equals("file")) {
                String path = uri.toString();
                if (!remotePaths.contains(path)) { remotePaths.add(path); }
            }
        }
        return remotePaths;
    }

    private void stageImages(Session session, List<String> paths, ImageStagingRequestBatch.Callback callback) {
        ImageStagingRequestBatch stagingBatch = new ImageStagingRequestBatch(session);
        stagingBatch.addCallback(callback);
        for (String path : paths) {
            stagingBatch.addImage(new File(path));
        }
        stagingBatch.executeAsync();
    }

    class ObjectPostedCallback {
        public void onCompleted(OpenGraphObject ogObject) { }
    }

    private void postOpenGraphObject(Session session, OpenGraphObject object, ObjectPostedCallback callback) {
        final Session sessionContext = session;
        final OpenGraphObject objectContext = object;
        final ObjectPostedCallback callbackContext = callback;

        Request postObjectRequest = Request.newPostOpenGraphObjectRequest(session, object, new Request.Callback() {
            @Override
            public void onCompleted(Response response) {
                Log.w("FBShareActivity", "Received Response: " + response.toString());
                GraphObject object = response.getGraphObject();
                String objectId = object.getProperty("id").toString();
                OpenGraphObject ogObject = OpenGraphObject.Factory.createForPost(objectContext.getType());
                ogObject.setCreateObject(false);
                ogObject.setId(objectId);

                if (response.getError() != null) {
                    callbackContext.onCompleted(objectContext);
                }
                else {
                    callbackContext.onCompleted(ogObject);
                }
            }
        });
        Log.w("FBShareActivity", "Request is " + postObjectRequest);
        try {
            postObjectRequest.executeAsync();
        } catch (Exception e) {
            Log.w("FBShareActivity","Caught Exception when posting");
            e.printStackTrace();
        }
    }

    private void requestPublishPermissions(Session session)  {
        publishRequestedInSession = true;
        List<String> permissions = new ArrayList<String>();
        permissions.add("publish_actions");
        Session.NewPermissionsRequest publishReq = new Session.NewPermissionsRequest(this, permissions);
        session.requestNewPublishPermissions(publishReq);
    }

    private void warnPublishPermissionsDeclined() {
        int duration = Toast.LENGTH_LONG;
        String alert = "You have declined this app permission to post on your timeline.";
        Toast toast = Toast.makeText(mainActivity, alert, duration);
        toast.show();
    }

    public void launchSharingIntent(Intent intent) {
        Session session = Session.getActiveSession();
        final Intent callbackIntent = intent;
        if (session == null) {
            session = new Session.Builder(mainActivity).build();
        }

        if (!(session.isOpened())) {
            Session.setActiveSession(session);
            Session.OpenRequest openRequest = new Session.OpenRequest(this).setCallback(
                new Session.StatusCallback() {
                    public void call(Session session, SessionState state, Exception exception) {
                        tryPublishImageFromIntent(session, callbackIntent);
                    }
                }
            );
            session.openForRead(openRequest);
        }
        else {
            tryPublishImageFromIntent(session, callbackIntent);
        }
    }

    private void tryPublishImageFromIntent(Session session, Intent intent) {
        List<String> permissions = new ArrayList<String>();
        permissions.add("publish_actions");
        List granted = session.getPermissions();
        List declined = session.getDeclinedPermissions();
        if (granted.contains("publish_actions")) {
            publishImageFromIntent(session, intent);
        }
        else if (!(declined.contains("publish_actions"))) {
            requestPublishPermissions(session);
        }
        else {
            warnPublishPermissionsDeclined();
        }
    }

    private void publishImageFromIntent(Session session, Intent intent) {
        try {
            String path = ((Uri)(intent.getParcelableExtra(Intent.EXTRA_STREAM))).getPath();
            final File imgFile = new File(path);
            Request request = Request.newUploadPhotoRequest(session, imgFile, new Request.Callback() {
                @Override
                public void onCompleted(Response response) {
                    int duration = Toast.LENGTH_SHORT;
                    String alert = "Shared to Facebook!";
                    if (response.getError() != null) {
                        alert = response.getError().getErrorUserMessage();
                    }
                    Toast toast = Toast.makeText(mainActivity, alert, duration);
                    toast.show();
                }
            });
            Bundle params = request.getParameters();
            params.putString("message", "Your Caption Here");
            request.setParameters(params);
            request.executeAsync();
        } catch (Exception e) {
            int duration = Toast.LENGTH_SHORT;
            String alert = "Could not share to Facebook.";
            Toast toast = Toast.makeText(mainActivity, alert, duration);
            toast.show();
            e.printStackTrace();
        }
    }
}
