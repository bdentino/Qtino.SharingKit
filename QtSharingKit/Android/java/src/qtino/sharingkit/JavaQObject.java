package qtino.sharingkit;

import java.util.HashMap;
import java.util.Set;
import java.util.List;
import java.util.ArrayList;

public class JavaQObject {

    private HashMap<String, Object> properties;

    public JavaQObject()
    {
        this.properties = new HashMap<String, Object>();
    }

    public List<String> propertyNames()
    {
        Set<String> keys = this.properties.keySet();
        ArrayList<String> keyList = new ArrayList<String>();
        keyList.addAll(keys);
        return keyList;
    }


    public void setProperty(String property, Object value)
    {
        properties.put(property, value);
    }

    @SuppressWarnings("unchecked")
    public <T> T getProperty(String property, T type)
    {
        Object object = properties.get(property);
        if (object == null) return type;

        if (type.getClass().isAssignableFrom(object.getClass())) {
            return (T)object;
        }
        return type;
    }

    public boolean hasProperty(String property)
    {
        return properties.containsKey(property);
    }

    public String getStringProperty(String property)
    {
        try {
            return (String)(properties.get(property));
        }
        catch (ClassCastException e) {
            return "";
        }
    }

    public boolean getBoolProperty(String property)
    {
        try {
            return (Boolean)(properties.get(property));
        }
        catch (ClassCastException e) {
            return false;
        }
    }

    public int getIntProperty(String property)
    {
        try {
            return (Integer)(properties.get(property));
        }
        catch (ClassCastException e) {
            return 0;
        }
    }

    public byte getByteProperty(String property)
    {
        try {
            return (Byte)(properties.get(property));
        }
        catch (ClassCastException e) {
            return 0;
        }
    }

    public short getShortProperty(String property)
    {
        try {
            return (Short)(properties.get(property));
        }
        catch (ClassCastException e) {
            return 0;
        }
    }

    public double getDoubleProperty(String property)
    {
        try {
            return (Double)(properties.get(property));
        }
        catch (ClassCastException e) {
            return 0.0f;
        }
    }

    public float getFloatProperty(String property)
    {
        try {
            return (Float)(properties.get(property));
        }
        catch (ClassCastException e) {
            return 0.0f;
        }
    }

    public long getLongProperty(String property)
    {
        try {
            return (Long)(properties.get(property));
        }
        catch (ClassCastException e) {
            return 0;
        }
    }

    public char getCharProperty(String property)
    {
        try {
            return (Character)(properties.get(property));
        }
        catch (ClassCastException e) {
            return '\0';
        }
    }
}

