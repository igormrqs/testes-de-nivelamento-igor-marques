package org.example;

import net.lingala.zip4j.ZipFile;
import net.lingala.zip4j.exception.ZipException;

import java.io.File;

public class ArquivosZip {
    public static void zipFiles(String[] files, String zipFileName) throws ZipException {
        ZipFile zipFile = new ZipFile(zipFileName);
        for (String file : files) {
            zipFile.addFile(new File(file));
        }
    }
}