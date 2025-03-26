package org.example;

import java.io.*;
import java.net.*;

public class BaixarArquivos {
    public static void downloadFile(String fileUrl, String saveAs) throws IOException {
        URL url = new URL(fileUrl);
        try (InputStream in = url.openStream();
             OutputStream out = new FileOutputStream(saveAs)) {
            byte[] buffer = new byte[1024];
            int bytesRead;
            while ((bytesRead = in.read(buffer)) != -1) {
                out.write(buffer, 0, bytesRead);
            }
        }
    }
}