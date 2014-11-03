package qtino.sharingkit;

import java.util.Arrays;

import android.app.Activity;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewParent;
import android.view.LayoutInflater;
import android.view.ViewGroup.LayoutParams;
import android.view.ViewGroup.MarginLayoutParams;
import android.view.Gravity;

import android.widget.ArrayAdapter;
import android.widget.ImageView;
import android.widget.TextView;

import android.util.DisplayMetrics;
import android.util.TypedValue;

import android.content.pm.ResolveInfo;
import android.content.pm.PackageManager;

public class ShareIntentListAdapter extends ArrayAdapter<ResolveInfo>
{
    Activity context;
    ResolveInfo[] items;
    int layoutId;

    public ShareIntentListAdapter(Activity context, ResolveInfo[] items) {
        super(context, android.R.layout.activity_list_item);
        addAll(items);
        this.context = context;
        this.items = items;
        this.layoutId = android.R.layout.activity_list_item;
    }

    public View getView(int pos, View convertView, ViewGroup parent) {
        LayoutInflater inflater = context.getLayoutInflater();
        View row = inflater.inflate(layoutId, parent, false);

        // Get the 'preferred row height' from the system
        int rowHeight = 0;
        TypedValue typedValue = new TypedValue();
        context.getTheme().resolveAttribute(android.R.attr.listPreferredItemHeight, typedValue, true);
        DisplayMetrics metrics = new android.util.DisplayMetrics();
        context.getWindowManager().getDefaultDisplay().getMetrics(metrics);
        rowHeight = (int)typedValue.getDimension(metrics);

        MarginLayoutParams parentMargins = (MarginLayoutParams)parent.getLayoutParams();
        if (parentMargins != null) {
            parent.setLayoutParams(parentMargins);
        }

        // Setup row size/layout
        LayoutParams params = row.getLayoutParams();
        if (params != null) {
            params.height = (int)(rowHeight * 0.75);
            row.setLayoutParams(params);
        }

        // Setup icon size/layout
        ImageView icon = (ImageView) row.findViewById(android.R.id.icon);
        params = icon.getLayoutParams();
        if (params != null) {
            params.height = LayoutParams.MATCH_PARENT;
            params.width = LayoutParams.WRAP_CONTENT;
            ((MarginLayoutParams)params).topMargin = (int)(rowHeight * 0.05);
            ((MarginLayoutParams)params).bottomMargin = (int)(rowHeight * 0.05);
            ((MarginLayoutParams)params).leftMargin = 10;
            ((MarginLayoutParams)params).rightMargin = 0;
            icon.setLayoutParams(params);
        }
        icon.setScaleType(ImageView.ScaleType.CENTER_INSIDE);
        icon.setImageDrawable(items[pos].loadIcon(context.getPackageManager()));

        // Setup label size/layout
        TextView label = (TextView) row.findViewById(android.R.id.text1);
        params = label.getLayoutParams();
        if (params != null) {
            params.height = LayoutParams.MATCH_PARENT;
            ((MarginLayoutParams)params).leftMargin = 10;
            ((MarginLayoutParams)params).rightMargin = 0;
            label.setLayoutParams(params);
        }
        label.setGravity(Gravity.CENTER_VERTICAL);
        label.setTextSize(TypedValue.COMPLEX_UNIT_PX, (float)(rowHeight * 0.28));
        label.setText(items[pos].loadLabel(context.getPackageManager()).toString());

        return(row);
    }
}


