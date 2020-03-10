package com.bahaso.qiscus_sdk;

import android.util.Log;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonElement;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import com.google.gson.TypeAdapter;
import com.google.gson.TypeAdapterFactory;
import com.google.gson.reflect.TypeToken;
import com.google.gson.stream.JsonReader;
import com.google.gson.stream.JsonWriter;

import org.json.JSONObject;

import java.io.IOException;

/**
 * Created by Chris on 22/02/15.
 */
public class EmptyCheckTypeAdapterFactory implements TypeAdapterFactory {

    @Override
    public <T> TypeAdapter<T> create(final Gson gson, final TypeToken<T> type) {
        // We filter out the EmptyCheckTypeAdapter as we need to check this for emptiness!
        if (JSONObject.class.isAssignableFrom(type.getRawType())) {
            final TypeAdapter<T> delegate = gson.getDelegateAdapter(this, type);
            final TypeAdapter<JsonElement> elementAdapter = gson.getAdapter(JsonElement.class);
            return new EmptyCheckTypeAdapter<T>(delegate, elementAdapter).nullSafe();
        }
        return null;
    }

    public static class EmptyCheckTypeAdapter<T> extends TypeAdapter<T> {

        private final TypeAdapter<T> delegate;
        private final TypeAdapter<JsonElement> elementAdapter;

        public EmptyCheckTypeAdapter(final TypeAdapter<T> delegate,
                                     final TypeAdapter<JsonElement> elementAdapter) {
            this.delegate = delegate;
            this.elementAdapter = elementAdapter;
        }

        @Override
        public void write(final JsonWriter out, final T value) throws IOException {
            JsonElement json = JsonParser.parseString(value.toString());
            // this is suppose to be delegate of inner Class Object to write out
            // in our case we only need JsonElement object to written
            // so if we use
            // this.elementAdapter.write(out, null);
            // it will be work too
            if (json.getAsJsonObject().entrySet().isEmpty())
                this.delegate.write(out, null);
            else
                this.elementAdapter.write(out, json);
        }

        @Override
        public T read(final JsonReader in) throws IOException {
            Log.e("SDK", "reading from json to object");
            final JsonObject asJsonObject = elementAdapter.read(in).getAsJsonObject();

            if (asJsonObject.entrySet().isEmpty()) return null;
            return this.delegate.fromJsonTree(asJsonObject);
        }
    }

}

class AmininGsonBuilder {

    public static Gson createGson() {
        return new GsonBuilder()
                .registerTypeAdapterFactory(
                        new EmptyCheckTypeAdapterFactory())
                .create();
    }


}