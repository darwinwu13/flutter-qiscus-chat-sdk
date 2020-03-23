package com.bahaso.qiscus_sdk;


public class QiscusFileUploadProgressEvent {
    private int progress;

    public QiscusFileUploadProgressEvent(int progress) {
        this.progress = progress;
    }

    public int getProgress() {
        return progress;
    }
}
