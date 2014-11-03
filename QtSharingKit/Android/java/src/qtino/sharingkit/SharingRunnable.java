package qtino.sharingkit;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.io.File;

import android.app.Activity;
import android.app.AlertDialog;
import android.support.v4.app.FragmentTransaction;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentActivity;

import android.content.Intent;
import android.content.DialogInterface;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.content.pm.ActivityInfo;
import android.os.Bundle;
import android.util.Log;
import android.net.Uri;

import com.facebook.widget.FacebookDialog;
import com.facebook.widget.FacebookDialog.ShareDialogFeature;

public class SharingRunnable implements Runnable {

    Activity mainActivity;
    String title;
    JavaQObject contentObjects;
    ActivityIntentMap activityMap;
    long callerPtr;

    public SharingRunnable(Activity activity) {
        this.mainActivity = activity;
        contentObjects = new JavaQObject();
        activityMap = new ActivityIntentMap();
        title = "";
    }

    public void setTitle(String title) { this.title = title; }
    public void setContentObjects(JavaQObject contentObjects) {
        this.contentObjects = contentObjects;
        setupActivityMap();
    }
    public void setCallerPtr(long ptr) { this.callerPtr = ptr; }


    private void setupActivityMap() {
        activityMap = new ActivityIntentMap();
        PackageManager pkgManager = mainActivity.getPackageManager();

        if (contentObjects.hasProperty("FacebookContent"))
        {
            Intent facebookIntent = new Intent();
            JavaQObject fbObject = contentObjects.getProperty("FacebookContent", new JavaQObject());

            int textCount = setupTextAttachments(fbObject, facebookIntent);
            int imageCount = setupImageAttachments(fbObject, facebookIntent);

            String fbText = fbObject.getProperty("text", new String());
            String fbLink = fbObject.getProperty("link", new String());
            if (fbText != "" && fbLink != "") {
                fbText += ("\n" + fbLink);
            } else if (fbText == "" && fbLink != "") {
                fbText += fbLink;
            }

            if (fbText != "") {
                facebookIntent.putExtra(Intent.EXTRA_TEXT, fbText);
            }

            facebookIntent.setAction(Intent.ACTION_SEND);
            if (imageCount > 0) {
                facebookIntent.setType("image/*");
            }
            else {
                facebookIntent.setType("text/plain");
            }

            List<ResolveInfo> activities = pkgManager.queryIntentActivities(facebookIntent, 0);
            for (ResolveInfo info : activities) {
                if (info.activityInfo.name.contains("facebook")
                    && !activityMap.hasMappingForPackage(info.activityInfo.packageName)
                    && FacebookDialog.canPresentShareDialog(mainActivity, ShareDialogFeature.SHARE_DIALOG)) {
                    activityMap.addMapping(info, facebookIntent);
                }
            }
        }

        if (contentObjects.hasProperty("TwitterContent"))
        {
            Intent twitterIntent = new Intent();
            JavaQObject twObject = contentObjects.getProperty("TwitterContent", new JavaQObject());

            int imageCount = setupImageAttachments(twObject, twitterIntent);
            int textCount = setupTextAttachments(twObject, twitterIntent);

            String twText = twObject.getProperty("text", new String());
            if (twText != "") {
                twitterIntent.putExtra(Intent.EXTRA_TEXT, twText);
            }
            boolean hasText = ((twText != "") || textCount > 0);

            twitterIntent.setAction(Intent.ACTION_SEND);

            if (imageCount > 0 && hasText) {
                twitterIntent.setType("*/*");
            }
            else if (hasText) {
                twitterIntent.setType("text/*");
            }
            else if (imageCount > 0) {
                twitterIntent.setType("image/*");
            }

            List<ResolveInfo> activities = pkgManager.queryIntentActivities(twitterIntent, 0);
            for (ResolveInfo info : activities) {
                if ((info.activityInfo.name.toLowerCase().contains("tweet")
                || info.activityInfo.name.toLowerCase().contains("twitter"))
                && !activityMap.hasMappingForPackage(info.activityInfo.packageName)) {
                    activityMap.addMapping(info, twitterIntent);
                }
            }
        }

        if (contentObjects.hasProperty("EmailContent"))
        {
            Intent emailIntent = new Intent();
            emailIntent.setAction(Intent.ACTION_SENDTO);
            emailIntent.setData(Uri.fromParts("mailto", "", null));

            JavaQObject emailObj = contentObjects.getProperty("EmailContent", new JavaQObject());

            int imageCount = setupImageAttachments(emailObj, emailIntent);
            int textCount = setupTextAttachments(emailObj, emailIntent);

            String body = emailObj.getProperty("body", new String());
            String subject = emailObj.getProperty("subject", new String());
            emailIntent.putExtra(Intent.EXTRA_TEXT, body);
            emailIntent.putExtra(Intent.EXTRA_SUBJECT, subject);

            List<ResolveInfo> activities = pkgManager.queryIntentActivities(emailIntent, 0);
            for (ResolveInfo info : activities) {
                if (!activityMap.hasMappingForPackage(info.activityInfo.packageName)) {
                    activityMap.addMapping(info, emailIntent);
                }
            }
        }

        if (contentObjects.hasProperty("SmsContent"))
        {
            Intent responderIntent = new Intent();
            responderIntent.setAction(Intent.ACTION_SENDTO);

            Intent smsIntent = new Intent();
            smsIntent.setAction(Intent.ACTION_SEND);

            JavaQObject smsObj = contentObjects.getProperty("SmsContent", new JavaQObject());

            int imageCount = setupImageAttachments(smsObj, smsIntent);
            int textCount = setupTextAttachments(smsObj, smsIntent);

            String body = smsObj.getProperty("body", new String());
            smsIntent.putExtra("sms_body", body);
            smsIntent.putExtra(Intent.EXTRA_TEXT, body);

            if (imageCount > 0) {
                responderIntent.setData(Uri.parse("mmsto:"));
                smsIntent.setType("image/*");
            }
            else {
                responderIntent.setData(Uri.parse("smsto:"));
                smsIntent.setType("text/plain");
            }

            List<ResolveInfo> smsResponders = pkgManager.queryIntentActivities(responderIntent, 0);
            ArrayList<String> responderPackages = new ArrayList<String>();
            for (ResolveInfo info : smsResponders) {
                responderPackages.add(info.activityInfo.packageName);
            }

            List<ResolveInfo> activities = pkgManager.queryIntentActivities(smsIntent, 0);
            for (ResolveInfo info : activities) {
                if (responderPackages.contains(info.activityInfo.packageName)
                && !activityMap.hasMappingForPackage(info.activityInfo.packageName)) {
                    activityMap.addMapping(info, smsIntent);
                }
            }
        }

        if (contentObjects.hasProperty("DefaultContent"))
        {
            Intent defaultIntent = new Intent();
            JavaQObject defaultObject = contentObjects.getProperty("DefaultContent", new JavaQObject());
            int textCount = setupTextAttachments(defaultObject, defaultIntent);
            int imageCount = setupImageAttachments(defaultObject, defaultIntent);

            //TODO: Need real handling of multiple text/image/video/etc content items
            //      This includes using ACTION_SEND_MULTIPLE and setting the proper MIME type
            defaultIntent.setAction(Intent.ACTION_SEND);
            if (imageCount > 0) {
                defaultIntent.setType("image/*");
            }
            else if (textCount > 0) {
                defaultIntent.setType("text/plain");
            }
            List<ResolveInfo> activities = pkgManager.queryIntentActivities(defaultIntent, 0);
            for (ResolveInfo info : activities) {
                if (!activityMap.hasMappingForPackage(info.activityInfo.packageName)) {
                    activityMap.addMapping(info, defaultIntent);
                }
            }
        }
    }

    private int setupTextAttachments(JavaQObject contentObject, Intent intent) {
        int textCount = 0;
        ArrayList<JavaQObject> attachments = contentObject.getProperty("attachments", new ArrayList<JavaQObject>());
        for (JavaQObject object : attachments) {
            if (object.getProperty("meta.type", new ArrayList<String>()).contains("TextItem")) {
                String text = object.getProperty("text", new String());
                intent.putExtra(Intent.EXTRA_TEXT, text);
                textCount++;
            }
        }
        return textCount;
    }

    private int setupImageAttachments(JavaQObject contentObject, Intent intent) {
        int imageCount = 0;
        ArrayList<JavaQObject> attachments = contentObject.getProperty("attachments", new ArrayList<JavaQObject>());
        for (JavaQObject object : attachments) {
            if (object.getProperty("meta.type", new ArrayList<String>()).contains("ShareableImageItem")) {
                String path = object.getProperty("url", new String());
                Uri uri = Uri.parse(path);
                if (uri.getScheme().equals("file")) {
                    File imageFile = new File(uri.getPath());
                    if (!imageFile.exists()) {
                        Log.w("SharingRunnable", "Could not find the image file " + path);
                        continue;
                    }
                    imageFile.setReadable(true, false);
                    intent.putExtra(Intent.EXTRA_STREAM, Uri.fromFile(imageFile));
                    imageCount++;
                }
                else {
                    Log.w("SharingRunnable", "Unhandled URI scheme on path " + path);
                }
            }
        }
        return imageCount;
    }

    public void run() {
        PackageManager pkgManager = mainActivity.getPackageManager();

        ArrayList<ResolveInfo> activities = new ArrayList<ResolveInfo>();
        activities.addAll(this.activityMap.keySet());
        Collections.sort(activities, new Comparator<ResolveInfo>() {
            public int compare(ResolveInfo first, ResolveInfo second) {
                return first.activityInfo.name.compareTo(second.activityInfo.name);
            }
        });

        AlertDialog.Builder builder = new AlertDialog.Builder(mainActivity);
        builder.setTitle(title);

        final ShareIntentListAdapter adapter
            = new ShareIntentListAdapter(mainActivity,
                                        activities.toArray(new ResolveInfo[0]));

        builder.setAdapter(adapter, new DialogInterface.OnClickListener() {
            @Override
            public void onClick(DialogInterface dialog, int which) {
                ResolveInfo info = adapter.getItem(which);
                Intent intent = activityMap.get(info);
                String pkgName = info.activityInfo.packageName;
                String activityName = info.activityInfo.name;

                // Handle with Facebook SDK
                if (pkgName.equals("com.facebook.katana")) {
                    FragmentManager fm = ((FragmentActivity)(mainActivity)).getSupportFragmentManager();
                    FragmentTransaction ft = fm.beginTransaction();
                    QtinoFacebookShareFragment fbFragment = new QtinoFacebookShareFragment(mainActivity);
                    ft.add(fbFragment, "FacebookShareFragment");
                    ft.commit();
                    fm.executePendingTransactions();

                    JavaQObject fbContent = contentObjects.getProperty("FacebookContent", new JavaQObject());
                    // If an OpenGraphStory is available, it will be shared to the exclusion of any other attachments
                    for (JavaQObject attachment : fbContent.getProperty("attachments", new ArrayList<JavaQObject>())) {
                        if (attachment.getProperty("meta.type", new ArrayList<String>()).contains("OpenGraphStory")) {
                            fbFragment.shareOpenGraphStory(attachment);
                            return;
                        }
                    }

                    // TODO: Handle case for simple status/photo share
                }
                else {
                    intent.setClassName(pkgName, activityName);
                    mainActivity.startActivityForResult(intent, 100);
                }
            }
        });

        builder.create().show();
    }
}
