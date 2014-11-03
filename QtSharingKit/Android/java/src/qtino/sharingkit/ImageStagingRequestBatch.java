package qtino.sharingkit;

import com.facebook.*;
import com.facebook.android.*;
import com.facebook.widget.*;
import com.facebook.model.*;

import java.util.HashMap;
import java.util.List;
import java.util.ArrayList;
import java.io.File;

import android.util.Log;

public class ImageStagingRequestBatch {

    private HashMap<Request, String> stagingUris;
    private RequestBatch requestBatch;
    private List<Callback> callbacks;
    private Session session;

    public static class Callback {
        public void onCompleted(List<String> uris) {}
    }

    public ImageStagingRequestBatch(Session session) {
        this.stagingUris = new HashMap<Request, String>();
        this.requestBatch = new RequestBatch();
        this.requestBatch.addCallback(new RequestBatch.Callback() {
            public void onBatchCompleted(RequestBatch batch) {
                ImageStagingRequestBatch.this.onBatchCompleted(batch);
            }
        });
        this.callbacks = new ArrayList<Callback>();
        this.session = session;
    }

    public void addCallback(Callback callback) {
        this.callbacks.add(callback);
    }

    public void addImage(File imgFile) {
        Request.Callback imageCallback = new Request.Callback() {
            @Override
            public void onCompleted(Response response) {
                FacebookRequestError error = response.getError();
                if (error != null) {
                    Log.i("FBShareActivity", error.getErrorMessage());
                }
                else {
                    GraphObject object = response.getGraphObject();
                    String uri = object.getProperty("uri").toString();
                    if (uri != null && !uri.isEmpty()) {
                        ImageStagingRequestBatch.this.stagingUris.put(
                            response.getRequest(),
                            uri);
                    }
                }
            }
        };
        try {
            Request imageRequest = Request.newUploadStagingResourceWithImageRequest(
                session,
                imgFile,
                imageCallback);
            requestBatch.add(imageRequest);
        } catch (Exception e) {
            Log.w("FBShareActivity", "Couldn't create upload request for image file " + imgFile);
        }
    }

    public void executeAsync() {
        if (requestBatch.size() == 0) {
            onBatchCompleted(requestBatch);
            return;
        }
        requestBatch.executeAsync();
    }

    private void onBatchCompleted(RequestBatch batch) {
        if (batch != requestBatch) return;

        List<String> imageUris = new ArrayList<String>(stagingUris.values());
        for (Callback callback : callbacks) {
            callback.onCompleted(imageUris);
        }
    }
}

