package qtino.sharingkit;

import java.util.Arrays;

import java.lang.reflect.Method;
import java.lang.reflect.Field;
import java.lang.reflect.Modifier;

import android.app.Activity;

public class AndroidSharingActivity
{
    public static Activity mainActivity;

    public void setupActivity(Activity activity)
    {
        System.out.println("setting up activity" + activity);
        mainActivity = activity;
        if (mainActivity != null) {
            Field[] fields = mainActivity.getClass().getDeclaredFields();
            System.out.printf("%d fields:%n", fields.length);
            for (Field field : fields) {
                System.out.printf("%s %s %s%n",
                    Modifier.toString(field.getModifiers()),
                    field.getType().getSimpleName(),
                    field.getName()
                );
            }
        }
    }

    public static void launchSharingSelection(
        String title,
        JavaQObject contentObjects,
        long callerPtr)
   {
        if (mainActivity == null) {
            System.out.println("Warning: No Activity Available");
            return;
        }

        System.out.println("Title is: " + title);
        System.out.println("Objects are: " + contentObjects.propertyNames().toString());

        SharingRunnable selectionWidget = new SharingRunnable(mainActivity);
        selectionWidget.setTitle(title);
        selectionWidget.setContentObjects(contentObjects);
        selectionWidget.setCallerPtr(callerPtr);

        mainActivity.runOnUiThread(selectionWidget);
    }
}

