package qtino.sharingkit;

import java.util.HashMap;
import android.content.pm.ResolveInfo;
import android.content.Intent;

public class ActivityIntentMap extends HashMap<ResolveInfo,Intent> {

    public ActivityIntentMap() { super(); }

    public void addMapping(ResolveInfo key, Intent value) {
        super.put(key, value);
    }

    public boolean hasMappingForPackage(String packageName) {
        System.out.println("Checking mapping for package name: " + packageName);
        for (ResolveInfo info : super.keySet()) {
            if (info.activityInfo.packageName.equals(packageName))
                return true;
        }
        return false;
    }
}
