package com.tencent.liteav.demo.beauty;

import android.support.annotation.NonNull;
import android.support.annotation.Nullable;
import android.text.TextUtils;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.util.Collection;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;

public class VideoUtil {
    private static final String TAG = "VideoUtil";

    public VideoUtil() {
    }

    public static boolean isEmpty(@Nullable Collection object) {
        return null == object || object.isEmpty();
    }

    public static synchronized String unZip(@NonNull String zipFile, @NonNull String targetDir) {
        if (TextUtils.isEmpty(zipFile)) {
            return null;
        } else {
            File file = new File(zipFile);
            if (!file.exists()) {
                return null;
            } else {
                File targetFolder = new File(targetDir);
                if (!targetFolder.exists()) {
                    targetFolder.mkdirs();
                }

                String dataDir = null;
                short BUFFER = 4096;
                FileInputStream fis = null;
                ZipInputStream zis = null;
                FileOutputStream fos = null;
                BufferedOutputStream dest = null;

                try {
                    fis = new FileInputStream(file);
                    zis = new ZipInputStream(new BufferedInputStream(fis));

                    while (true) {
                        while (true) {
                            String strEntry;
                            ZipEntry entry;
                            do {
                                if ((entry = zis.getNextEntry()) == null) {
                                    return dataDir;
                                }

                                strEntry = entry.getName();
                            } while (strEntry.contains("../"));

                            if (entry.isDirectory()) {
                                String count1 = targetDir + File.separator + strEntry;
                                File data1 = new File(count1);
                                if (!data1.exists()) {
                                    data1.mkdirs();
                                }

                                if (TextUtils.isEmpty(dataDir)) {
                                    dataDir = data1.getPath();
                                }
                            } else {
                                byte[] data = new byte[BUFFER];
                                String targetFileDir = targetDir + File.separator + strEntry;
                                File targetFile = new File(targetFileDir);

                                try {
                                    fos = new FileOutputStream(targetFile);
                                    dest = new BufferedOutputStream(fos, BUFFER);

                                    int count;
                                    while ((count = zis.read(data)) != -1) {
                                        dest.write(data, 0, count);
                                    }

                                    dest.flush();
                                } catch (IOException var41) {
                                    var41.printStackTrace();
                                } finally {
                                    try {
                                        if (dest != null) {
                                            dest.close();
                                        }

                                        if (fos != null) {
                                            fos.close();
                                        }
                                    } catch (IOException var40) {
                                        var40.printStackTrace();
                                    }

                                }
                            }
                        }
                    }
                } catch (IOException e) {
                    e.printStackTrace();
                } finally {
                    try {
                        if (zis != null) {
                            zis.close();
                        }

                        if (fis != null) {
                            fis.close();
                        }
                    } catch (IOException e) {
                        e.printStackTrace();
                    }

                }

                return dataDir;
            }
        }
    }

}
