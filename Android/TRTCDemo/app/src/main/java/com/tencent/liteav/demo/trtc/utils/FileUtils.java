package com.tencent.liteav.demo.trtc.utils;

import android.content.Context;
import android.content.res.AssetManager;
import android.text.TextUtils;
import android.util.Log;

import java.io.BufferedOutputStream;
import java.io.BufferedReader;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.RandomAccessFile;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.text.DecimalFormat;
import java.util.ArrayList;
import java.util.List;

public class FileUtils {
    private final static int MD5_FILE_BUFFER_LENGHT = 1 * 1024 * 1024; // 1MB
    private final static byte[] gSyncCode = new byte[0];

    public static InputStream getInputStream(File oFile) {
        InputStream oIn = null;
        try {
            oIn = new FileInputStream(oFile);
        } catch (FileNotFoundException ex) {
            oIn = null;
        }

        return oIn;
    }

    public static byte[] getBytes(String filePath) {
        byte[] buffer = null;
        FileInputStream fis = null;
        ByteArrayOutputStream bos = null;
        try {
            File file = new File(filePath);
            fis = new FileInputStream(file);
            bos = new ByteArrayOutputStream(1000);
            byte[] b = new byte[1000];
            int n;
            while ((n = fis.read(b)) != -1) {
                bos.write(b, 0, n);
            }
            buffer = bos.toByteArray();
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            if (fis != null) {
                try {
                    fis.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
            if (bos != null) {
                try {
                    bos.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }
        return buffer;
    }

    public static void getFile(byte[] bfile, String filePath, String fileName) {
        BufferedOutputStream bos = null;
        FileOutputStream fos = null;
        File file = null;
        try {
            File dir = new File(filePath);
            if (!dir.exists()) {// 判断文件目录是否存在
                boolean mkdirsResult = dir.mkdirs();
            }
            file = new File(filePath + fileName);
            fos = new FileOutputStream(file);
            bos = new BufferedOutputStream(fos);
            bos.write(bfile);
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (bos != null) {
                try {
                    bos.close();
                } catch (IOException e1) {
                    e1.printStackTrace();
                }
            }
            if (fos != null) {
                try {
                    fos.close();
                } catch (IOException e1) {
                    e1.printStackTrace();
                }
            }
        }
    }

    private final static String TAG = "FileUtils";
    public final static String FILE_EXTENSION_SEPARATOR = ".";

    /**
     * read file
     *
     * @param filePath
     * @param charsetName The name of a supported {@link java.nio.charset.Charset </code>charset<code>}
     * @return if file not exist, return null, else return content of file
     * @throws RuntimeException if an error occurs while operator BufferedReader
     */
    public static StringBuilder readFile(String filePath, String charsetName) {
        File file = new File(filePath);
        StringBuilder fileContent = new StringBuilder("");
        if (file == null || !file.isFile()) {
            return null;
        }

        BufferedReader reader = null;
        try {
            InputStreamReader is = new InputStreamReader(new FileInputStream(file), charsetName);
            reader = new BufferedReader(is);
            String line = null;
            while ((line = reader.readLine()) != null) {
                if (!fileContent.toString().equals("")) {
                    fileContent.append(System.getProperty("line.separator"));
                }
                fileContent.append(line);
            }
            reader.close();
            return fileContent;
        } catch (IOException e) {
            throw new RuntimeException("IOException occurred. ", e);
        } finally {
            if (reader != null) {
                try {
                    reader.close();
                } catch (IOException e) {
                    throw new RuntimeException("IOException occurred. ", e);
                }
            }
        }
    }

    /**
     * write file
     *
     * @param filePath
     * @param content
     * @param append   is append, if true, write to the end of file, else clear content of file and write into it
     * @return return false if content is empty, true otherwise
     * @throws RuntimeException if an error occurs while operator FileWriter
     */
    public static boolean writeFile(String filePath, String content, boolean append) {
        if (TextUtils.isEmpty(content)) {
            return false;
        }

        FileWriter fileWriter = null;
        try {
            makeDirs(filePath);
            fileWriter = new FileWriter(filePath, append);
            fileWriter.write(content);
            fileWriter.close();
            return true;
        } catch (IOException e) {
            throw new RuntimeException("IOException occurred. ", e);
        } finally {
            if (fileWriter != null) {
                try {
                    fileWriter.close();
                } catch (IOException e) {
                    throw new RuntimeException("IOException occurred. ", e);
                }
            }
        }
    }

    /**
     * write file
     *
     * @param filePath
     * @param contentList
     * @param append      is append, if true, write to the end of file, else clear content of file and write into it
     * @return return false if contentList is empty, true otherwise
     * @throws RuntimeException if an error occurs while operator FileWriter
     */
    public static boolean writeFile(String filePath, List<String> contentList, boolean append) {
        if (contentList == null || contentList.isEmpty()) {
            return false;
        }

        FileWriter fileWriter = null;
        try {
            makeDirs(filePath);
            fileWriter = new FileWriter(filePath, append);
            for (String line : contentList) {
                fileWriter.write(line);
                fileWriter.write(System.getProperty("line.separator"));
            }
            fileWriter.close();
            return true;
        } catch (IOException e) {
            throw new RuntimeException("IOException occurred. ", e);
        } finally {
            if (fileWriter != null) {
                try {
                    fileWriter.close();
                } catch (IOException e) {
                    throw new RuntimeException("IOException occurred. ", e);
                }
            }
        }
    }

    /**
     * write file, the string will be written to the begin of the file
     *
     * @param filePath
     * @param content
     * @return
     */
    public static boolean writeFile(String filePath, String content) {
        return writeFile(filePath, content, false);
    }

    /**
     * write file, the string list will be written to the begin of the file
     *
     * @param filePath
     * @param contentList
     * @return
     */
    public static boolean writeFile(String filePath, List<String> contentList) {
        return writeFile(filePath, contentList, false);
    }

    /**
     * write file, the bytes will be written to the begin of the file
     *
     * @param filePath
     * @param stream
     * @return
     * @see {@link #writeFile(String, InputStream, boolean)}
     */
    public static boolean writeFile(String filePath, InputStream stream) {
        return writeFile(filePath, stream, false);
    }

    /**
     * write file
     *
     * @param filePath the file to be opened for writing.
     * @param stream   the input stream
     * @param append   if <code>true</code>, then bytes will be written to the end of the file rather than the beginning
     * @return return true
     * @throws RuntimeException if an error occurs while operator FileOutputStream
     */
    public static boolean writeFile(String filePath, InputStream stream, boolean append) {
        return writeFile(filePath != null ? new File(filePath) : null, stream, append);
    }

    /**
     * write file, the bytes will be written to the begin of the file
     *
     * @param file
     * @param stream
     * @return
     * @see {@link #writeFile(File, InputStream, boolean)}
     */
    public static boolean writeFile(File file, InputStream stream) {
        return writeFile(file, stream, false);
    }

    /**
     * write file
     *
     * @param file   the file to be opened for writing.
     * @param stream the input stream
     * @param append if <code>true</code>, then bytes will be written to the end of the file rather than the beginning
     * @return return true
     * @throws RuntimeException if an error occurs while operator FileOutputStream
     */
    public static boolean writeFile(File file, InputStream stream, boolean append) {
        if (file == null || stream == null) {
            return false;
        }

        OutputStream o = null;
        try {
            makeDirs(file.getAbsolutePath());
            o = new FileOutputStream(file, append);
            byte data[] = new byte[1024];
            int length = -1;
            while ((length = stream.read(data)) != -1) {
                o.write(data, 0, length);
            }
            o.flush();
            return true;
        } catch (FileNotFoundException e) {
            throw new RuntimeException("FileNotFoundException occurred. ", e);
        } catch (IOException e) {
            throw new RuntimeException("IOException occurred. ", e);
        } finally {
            if (o != null) {
                try {
                    o.close();
                    stream.close();
                } catch (IOException e) {
                    throw new RuntimeException("IOException occurred. ", e);
                }
            }
        }
    }

    /**
     * copy file
     *
     * @param sourceFilePath
     * @param destFilePath
     * @return
     * @throws RuntimeException if an error occurs while operator FileOutputStream
     */
    public static boolean copyFile(String sourceFilePath, String destFilePath) {
        InputStream inputStream = null;
        try {
            inputStream = new FileInputStream(sourceFilePath);
        } catch (FileNotFoundException e) {
            throw new RuntimeException("FileNotFoundException occurred. ", e);
        }
        return writeFile(destFilePath, inputStream);
    }

    /**
     * read file to string list, a element of list is a line
     *
     * @param filePath
     * @param charsetName The name of a supported {@link java.nio.charset.Charset </code>charset<code>}
     * @return if file not exist, return null, else return content of file
     * @throws RuntimeException if an error occurs while operator BufferedReader
     */
    public static List<String> readFileToList(String filePath, String charsetName) {
        File file = new File(filePath);
        List<String> fileContent = new ArrayList<String>();
        if (file == null || !file.isFile()) {
            return null;
        }

        BufferedReader reader = null;
        try {
            InputStreamReader is = new InputStreamReader(new FileInputStream(file), charsetName);
            reader = new BufferedReader(is);
            String line = null;
            while ((line = reader.readLine()) != null) {
                fileContent.add(line);
            }
            reader.close();
            return fileContent;
        } catch (IOException e) {
            throw new RuntimeException("IOException occurred. ", e);
        } finally {
            if (reader != null) {
                try {
                    reader.close();
                } catch (IOException e) {
                    throw new RuntimeException("IOException occurred. ", e);
                }
            }
        }
    }

    /**
     * get file name from path, not include suffix
     * <p>
     * <pre>
     *      getFileNameWithoutExtension(null)               =   null
     *      getFileNameWithoutExtension("")                 =   ""
     *      getFileNameWithoutExtension("   ")              =   "   "
     *      getFileNameWithoutExtension("abc")              =   "abc"
     *      getFileNameWithoutExtension("a.mp3")            =   "a"
     *      getFileNameWithoutExtension("a.b.rmvb")         =   "a.b"
     *      getFileNameWithoutExtension("c:\\")              =   ""
     *      getFileNameWithoutExtension("c:\\a")             =   "a"
     *      getFileNameWithoutExtension("c:\\a.b")           =   "a"
     *      getFileNameWithoutExtension("c:a.txt\\a")        =   "a"
     *      getFileNameWithoutExtension("/home/admin")      =   "admin"
     *      getFileNameWithoutExtension("/home/admin/a.txt/b.mp3")  =   "b"
     * </pre>
     *
     * @param filePath
     * @return file name from path, not include suffix
     * @see
     */
    public static String getFileNameWithoutExtension(String filePath) {
        if (TextUtils.isEmpty(filePath)) {
            return filePath;
        }

        int extenPosi = filePath.lastIndexOf(FILE_EXTENSION_SEPARATOR);
        int filePosi = filePath.lastIndexOf(File.separator);
        if (filePosi == -1) {
            return (extenPosi == -1 ? filePath : filePath.substring(0, extenPosi));
        }
        if (extenPosi == -1) {
            return filePath.substring(filePosi + 1);
        }
        return (filePosi < extenPosi ? filePath.substring(filePosi + 1, extenPosi) : filePath.substring(filePosi + 1));
    }

    /**
     * get file name from path, include suffix
     * <p>
     * <pre>
     *      getFileName(null)               =   null
     *      getFileName("")                 =   ""
     *      getFileName("   ")              =   "   "
     *      getFileName("a.mp3")            =   "a.mp3"
     *      getFileName("a.b.rmvb")         =   "a.b.rmvb"
     *      getFileName("abc")              =   "abc"
     *      getFileName("c:\\")              =   ""
     *      getFileName("c:\\a")             =   "a"
     *      getFileName("c:\\a.b")           =   "a.b"
     *      getFileName("c:a.txt\\a")        =   "a"
     *      getFileName("/home/admin")      =   "admin"
     *      getFileName("/home/admin/a.txt/b.mp3")  =   "b.mp3"
     * </pre>
     *
     * @param filePath
     * @return file name from path, include suffix
     */
    public static String getFileName(String filePath) {
        if (TextUtils.isEmpty(filePath)) {
            return filePath;
        }

        int filePosi = filePath.lastIndexOf(File.separator);
        return (filePosi == -1) ? filePath : filePath.substring(filePosi + 1);
    }

    /**
     * get folder name from path
     * <p>
     * <pre>
     *      getFolderName(null)               =   null
     *      getFolderName("")                 =   ""
     *      getFolderName("   ")              =   ""
     *      getFolderName("a.mp3")            =   ""
     *      getFolderName("a.b.rmvb")         =   ""
     *      getFolderName("abc")              =   ""
     *      getFolderName("c:\\")              =   "c:"
     *      getFolderName("c:\\a")             =   "c:"
     *      getFolderName("c:\\a.b")           =   "c:"
     *      getFolderName("c:a.txt\\a")        =   "c:a.txt"
     *      getFolderName("c:a\\b\\c\\d.txt")    =   "c:a\\b\\c"
     *      getFolderName("/home/admin")      =   "/home"
     *      getFolderName("/home/admin/a.txt/b.mp3")  =   "/home/admin/a.txt"
     * </pre>
     *
     * @param filePath
     * @return
     */
    public static String getFolderName(String filePath) {

        if (TextUtils.isEmpty(filePath)) {
            return filePath;
        }

        int filePosi = filePath.lastIndexOf(File.separator);
        return (filePosi == -1) ? "" : filePath.substring(0, filePosi);
    }

    /**
     * get suffix of file from path
     * <p>
     * <pre>
     *      getFileExtension(null)               =   ""
     *      getFileExtension("")                 =   ""
     *      getFileExtension("   ")              =   "   "
     *      getFileExtension("a.mp3")            =   "mp3"
     *      getFileExtension("a.b.rmvb")         =   "rmvb"
     *      getFileExtension("abc")              =   ""
     *      getFileExtension("c:\\")              =   ""
     *      getFileExtension("c:\\a")             =   ""
     *      getFileExtension("c:\\a.b")           =   "b"
     *      getFileExtension("c:a.txt\\a")        =   ""
     *      getFileExtension("/home/admin")      =   ""
     *      getFileExtension("/home/admin/a.txt/b")  =   ""
     *      getFileExtension("/home/admin/a.txt/b.mp3")  =   "mp3"
     * </pre>
     *
     * @param filePath
     * @return
     */
    public static String getFileExtension(String filePath) {
        if (TextUtils.isEmpty(filePath)) {
            return filePath;
        }

        int extenPosi = filePath.lastIndexOf(FILE_EXTENSION_SEPARATOR);
        int filePosi = filePath.lastIndexOf(File.separator);
        if (extenPosi == -1) {
            return "";
        }
        return (filePosi >= extenPosi) ? "" : filePath.substring(extenPosi + 1);
    }

    /**
     * Creates the directory named by the trailing filename of this file, including the complete directory path required
     * to create this directory. <br/>
     * <br/>
     * <ul>
     * <strong>Attentions:</strong>
     * <li>makeDirs("C:\\Users\\Trinea") can only create users folder</li>
     * <li>makeFolder("C:\\Users\\Trinea\\") can create Trinea folder</li>
     * </ul>
     *
     * @param filePath
     * @return true if the necessary directories have been created or the target directory already exists, false one of
     * the directories can not be created.
     * <ul>
     * <li>if {@link FileUtils#getFolderName(String)} return null, return false</li>
     * <li>if target directory already exists, return true</li>
     * <li>return {@link File#}</li>
     * </ul>
     */
    public static boolean makeDirs(String filePath) {
        String folderName = getFolderName(filePath);
        if (TextUtils.isEmpty(folderName)) {
            return false;
        }

        File folder = new File(folderName);
        return (folder.exists() && folder.isDirectory()) ? true : folder.mkdirs();
    }

    /**
     * @param filePath
     * @return
     * @see #makeDirs(String)
     */
    public static boolean makeFolders(String filePath) {
        return makeDirs(filePath);
    }

    /**
     * Indicates if this file represents a file on the underlying file system.
     *
     * @param filePath
     * @return
     */
    public static boolean isFileExist(String filePath) {
        if (TextUtils.isEmpty(filePath)) {
            return false;
        }

        File file = new File(filePath);
        return (file.exists() && file.isFile());
    }

    public static boolean isFolder(String filePath) {
        if (TextUtils.isEmpty(filePath)) {
            return false;
        }

        File file = new File(filePath);
        return file.isDirectory();
    }

    /**
     * Indicates if this file represents a file on the underlying file system.
     *
     * @param filePath
     * @return
     */
    public static boolean isFileExist(String filePath, long size) {
        if (TextUtils.isEmpty(filePath)) {
            return false;
        }

        File file = new File(filePath);
        return (file.exists() && file.isFile() && (file.length() == size));
    }

    /**
     * Indicates if this file represents a file on the underlying file system.
     *
     * @param filePath
     * @return
     */
    public static boolean isFileExist(String filePath, long size, String checkSum) {

        if (TextUtils.isEmpty(filePath)) {
            return false;
        }
        if (TextUtils.isEmpty(checkSum)) {
            return false;
        }
        File file = new File(filePath);
        if (!file.exists() || !file.isFile()) {
            return false;
        }
        String fileSum = "";
        try {
            fileSum = getMD5FromFile(filePath);
        } catch (IOException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        }
        return ((file.length() == size) && checkSum.equals(fileSum));
    }

    /**
     * Indicates if this file represents a directory on the underlying file system.
     *
     * @param directoryPath
     * @return
     */
    public static boolean isFolderExist(String directoryPath) {
        if (TextUtils.isEmpty(directoryPath)) {
            return false;
        }

        File dire = new File(directoryPath);
        return (dire.exists() && dire.isDirectory());
    }

    /**
     * delete file or directory
     * <ul>
     * <li>if path is null or empty, return true</li>
     * <li>if path not exist, return true</li>
     * <li>if path exist, delete recursion. return true</li>
     * <ul>
     *
     * @param path
     * @return
     */
    public static boolean deleteFile(String path) {

        synchronized (gSyncCode) {
            if (TextUtils.isEmpty(path)) {
                return true;
            }

            File file = new File(path);
            if (!file.exists()) {
                return true;
            }
            if (file.isFile()) {
                return file.delete();
            }
            if (!file.isDirectory()) {
                return false;
            }
            File[] filesList = file.listFiles();

            if (filesList != null) {
                for (File f : filesList) {
                    if (f.isFile()) {
                        f.delete();
                    } else if (f.isDirectory()) {
                        deleteFile(f.getAbsolutePath());
                    }
                }
            }

            return file.delete();
        }

    }

    /**
     * @param fromName 需要重命名的文件，为文件绝对路径
     * @param toName   要改成的名字，为文件绝对路径
     * @return boolean 成功或失败
     * @Method: fileRename
     * @Description: 将文件从fromName命名为toName，由于使用的是File自带的renameTo()接口，需要注意： <li>读写存储器权限</li> <li>
     * fromName和toName这两个路径在相同的挂载点。如果不在同一挂载点，重命名失败。</li>
     */
    public static boolean fileRename(String fromName, String toName) {
        synchronized (gSyncCode) {
            // TODO: 根据文件名判断是否属于同一挂载点
            File fromFile = new File(fromName);
            File toFile = new File(toName);
            if (!fromFile.exists()) {
                return false;
            }
            boolean result = fromFile.renameTo(toFile);
            if (result) {
            }
            return result;
        }

    }

    /**
     * get file size
     * <ul>
     * <li>if path is null or empty, return -1</li>
     * <li>if path exist and it is a file, return file size, else return -1</li>
     * <ul>
     *
     * @param path
     * @return returns the length of this file in bytes. returns -1 if the file does not exist.
     */
    public static long getFileSize(String path) {
        if (TextUtils.isEmpty(path)) {
            return -1;
        }

        File file = new File(path);
        return (file.exists() && file.isFile() ? file.length() : -1);
    }

    public static String getMD5FromFile(String filePath) throws IOException {
        if (filePath == null) {
            return null;
        }
        String digestString = null;

        File file = new File(filePath);

        byte[] buffer = new byte[1024];
        InputStream inputStream = null;
        MessageDigest digest = null;

        try {
            digest = MessageDigest.getInstance("MD5");
        } catch (NoSuchAlgorithmException e1) {
            // TODO Auto-generated catch block
            e1.printStackTrace();
            Log.e(TAG, new StringBuilder("NoSuchAlgorithmException: ").append(e1).toString());
        }

        long fileSize = file.length();

        if (fileSize > (3 * MD5_FILE_BUFFER_LENGHT)) {
            RandomAccessFile raf = null;
            Log.d(TAG, "fileSize is greater than 3MB");
            // 大于3MB时，分段，分头、中、尾，各1MB
            try {
                raf = new RandomAccessFile(file, "r");
                raf.seek(0);
                int bytesRead = 0;
                int totalRead = 0;
                int bytesToRead = 3 * MD5_FILE_BUFFER_LENGHT;

                /*
                 * 计算中、尾部起始位置，头部起始为0，不用计算 ------------------------------------------------- |Head 1MB| 间隔大小 | Mid 1MB| 间隔大小
                 * | Tail 1MB| ------------------------------------------------- 其中间隔大小计算方式为： (fileSize - 3 *
                 * MD5_FILE_BUFFER_LENGHT) / 2 所以中部起始位置为：Head + 一个间隔的大小 尾部起始点为：(fileSize - MD5_FILE_BUFFER_LENGHT)
                 */
                int midStartPosition = MD5_FILE_BUFFER_LENGHT + (int) (fileSize - 3 * MD5_FILE_BUFFER_LENGHT) / 2;
                int tailStartPosition = (int) (fileSize - MD5_FILE_BUFFER_LENGHT);

                Log.d(TAG,
                        String.format("midStartPosition = %d, tailStartPosition = %d", midStartPosition, tailStartPosition));
                byte[] data = new byte[128 * 1024];
                while (totalRead < bytesToRead) {
                    // Log.d(TAG, "count = " + (++count));
                    bytesRead = raf.read(data);
                    totalRead += bytesRead;

                    if (totalRead == MD5_FILE_BUFFER_LENGHT) {
                        // 读完头部，开始读取中部
                        Log.d(TAG, "totalRead == MD5_FILE_BUFFER_LENGHT");
                        raf.seek(midStartPosition);
                    } else if (totalRead == 2 * MD5_FILE_BUFFER_LENGHT) {
                        // 读完中部，开始读取尾部
                        Log.d(TAG, "totalRead == 2 * MD5_FILE_BUFFER_LENGHT");
                        raf.seek(tailStartPosition);
                    }
                    digest.update(data);
                }
            } catch (Exception e) {
                e.printStackTrace();
            } finally {
                if (raf != null) {
                    try {
                        raf.close();
                    } catch (Exception e2) {
                        e2.printStackTrace();
                    }
                }
            }
        } else {
            Log.d(TAG, "fileSize is smaller than 3MB");
            try {
                inputStream = new FileInputStream(file);
                int readSize = 0;
                while (readSize != -1) {
                    readSize = inputStream.read(buffer, 0, buffer.length);
                    if (readSize > 0) {
                        digest.update(buffer, 0, readSize);
                        // Log.d(TAG, "update: " + BytesUtil.byte2hexWithoutSpace(digest.digest()));
                    }
                }
            } catch (Exception e) {
                e.printStackTrace();
            } finally {
                if (inputStream != null) {
                    try {
                        inputStream.close();
                    } catch (Exception e2) {
                        e2.printStackTrace();
                    }
                }
            }
        }
        if (digest != null) {
            digestString = byte2hexWithoutSpace(digest.digest());
        }
        return digestString;
    }

    public static String byte2hexWithoutSpace(byte[] buffer) {
        String h = "";

        for (int i = 0; i < buffer.length; i++) {
            String temp = Integer.toHexString(buffer[i] & 0xFF);
            if (temp.length() == 1) {
                temp = "0" + temp;
            }
            h = h + temp;
        }

        return h;
    }

    /**
     * @param lenght
     * @return 返回类型：String
     * @Method: convertSize
     * @Description: 将字节换算为B、KB、MB、GB显示
     */
    public static String convertSize(long lenght) {
        DecimalFormat df = new DecimalFormat("#.00");
        String fileSizeString = "";
        if (lenght < 1024) {
            fileSizeString = df.format((double) lenght) + " B";
        } else if (lenght < 1048576) {
            fileSizeString = df.format((double) lenght / 1024) + " KB";
        } else if (lenght < 1073741824) {
            fileSizeString = df.format((double) lenght / 1048576) + " MB";
        } else {
            fileSizeString = df.format((double) lenght / 1073741824) + " GB";
        }
        return fileSizeString;
    }

    /**
     * @param context
     * @param filePath
     * @return 返回类型：String
     * @Method: getConfigFromAsserts
     * @Description: 从Asset配置文件中读取配置，丢弃#符号注释行，保留=符号所在行
     */
    public static String getConfigFromFile(Context context, String filePath) {
        InputStreamReader inputStreamReader = null;
        BufferedReader bufferedReader = null;
        try {
            /*
             * inputStreamReader = new InputStreamReader(new FileInputStream(filePath), "utf-8");
             * 构建InputStreamReader是可以指定字符编码格式，如windows下默认的gb2312，常用的utf-8，不指定是默认是utf-8
             */
            inputStreamReader = new InputStreamReader(new FileInputStream(filePath));
            bufferedReader = new BufferedReader(inputStreamReader);
            String line = "";
            StringBuilder result = new StringBuilder();
            while ((line = bufferedReader.readLine()) != null) {
                line = line.trim();
                // 过滤首字符带#的，满足带=好的
                if (!(line.matches("#.*")) && line.matches(".*=.*")) {
                    // 如果改行中带#，截取#之前部分
                    if (line.matches(".*#.*")) {
                        line = line.substring(0, line.indexOf("#"));
                    }
                    result.append(line.trim()).append("\n");
                }

            }

            bufferedReader.close();
            inputStreamReader.close();

            return result.toString();
        } catch (IOException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        } finally {
            if (bufferedReader != null) {
                try {
                    bufferedReader.close();
                } catch (IOException e) {
                    // TODO Auto-generated catch block
                    e.printStackTrace();
                } finally {
                    bufferedReader = null;
                }

            }

            if (inputStreamReader != null) {
                try {
                    inputStreamReader.close();
                } catch (IOException e) {
                    // TODO Auto-generated catch block
                    e.printStackTrace();
                } finally {
                    inputStreamReader = null;
                }
            }

        }
        return null;
    }

    /**
     * @param context
     * @param assetFile
     * @return 返回类型：String
     * @Method: getConfigFromAsserts
     * @Description: 从Asset配置文件中读取配置，丢弃#符号注释行，保留=符号所在行
     */
    public static String getConfigFromAsserts(Context context, String assetFile) {
        AssetManager assetManager = context.getAssets();
        InputStreamReader inputStreamReader = null;
        BufferedReader bufferedReader = null;
        try {
            /*
             * inputStreamReader = new InputStreamReader(assetManager.open(assetFile), "utf-8");
             * 构建InputStreamReader是可以指定字符编码格式，如windows下默认的gb2312，常用的utf-8，不指定是默认是utf-8
             */
            inputStreamReader = new InputStreamReader(assetManager.open(assetFile));
            bufferedReader = new BufferedReader(inputStreamReader);
            String line = "";
            StringBuilder result = new StringBuilder();
            while ((line = bufferedReader.readLine()) != null) {
                line = line.trim();
                // 过滤首字符带#的，满足带=好的
                if (!(line.matches("#.*")) && line.matches(".*=.*")) {
                    // 如果改行中带#，截取#之前部分
                    if (line.matches(".*#.*")) {
                        line = line.substring(0, line.indexOf("#"));
                    }
                    result.append(line.trim()).append("\n");
                }

            }

            bufferedReader.close();
            inputStreamReader.close();

            return result.toString();
        } catch (IOException e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
        } finally {
            if (bufferedReader != null) {
                try {
                    bufferedReader.close();
                } catch (IOException e) {
                    // TODO Auto-generated catch block
                    e.printStackTrace();
                } finally {
                    bufferedReader = null;
                }

            }

            if (inputStreamReader != null) {
                try {
                    inputStreamReader.close();
                } catch (IOException e) {
                    // TODO Auto-generated catch block
                    e.printStackTrace();
                } finally {
                    inputStreamReader = null;
                }
            }

        }
        return null;
    }

    /**
     * @param context
     * @param assetFilename 需要拷贝的assets文件路径
     * @param dstPath
     * @return
     * @throws IOException
     * @Method: copyFromAssetToSdcard
     * @Description: 执行拷贝任务
     * @返回类型：boolean
     */
    public static boolean copyFromAssetToSdcard(Context context, String assetFilename, String dstPath)
            throws IOException {
        InputStream source = null;
        OutputStream destination = null;
        try {
            source = context.getAssets().open(new File(assetFilename).getPath());
            File destinationFile = new File(dstPath, assetFilename);

            destinationFile.getParentFile().mkdirs();
            destination = new FileOutputStream(destinationFile);
            byte[] buffer = new byte[1024];
            int nread;

            while ((nread = source.read(buffer)) != -1) {
                if (nread == 0) {
                    nread = source.read();
                    if (nread < 0)
                        break;
                    destination.write(nread);
                    continue;
                }
                destination.write(buffer, 0, nread);
            }
        } finally {
            if (source != null) {
                try {
                    source.close();
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
            if (destination != null) {
                try {
                    destination.close();
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }
        return true;
    }

    /**
     * 拷贝assets目录下的 指定文件夹 下的所有文件夹及文件到指定文件夹
     *
     * @param context
     * @param assetsPath assets下指定文件夹
     * @param savePath   目标指定文件夹
     */
    public static void copyFilesFromAssets(Context context, String assetsPath, String savePath) {
        InputStream is = null;
        FileOutputStream fos = null;
        try {
            File file = new File(savePath);
            if (!file.getParentFile().exists()) {
                file.getParentFile().mkdirs();
            }
            String fileNames[] = context.getAssets().list(assetsPath);// 获取assets目录下的所有文件及目录名
            if (fileNames.length > 0) {// 如果是目录
                file.mkdirs();// 如果文件夹不存在，则递归
                for (String fileName : fileNames) {
                    copyFilesFromAssets(context, assetsPath + "/" + fileName,
                            savePath + "/" + fileName);
                }
            } else {// 如果是文件
                is = context.getAssets().open(assetsPath);
                fos = new FileOutputStream(new File(savePath));
                byte[] buffer = new byte[1024];
                int byteCount = 0;
                while ((byteCount = is.read(buffer)) != -1) {// 循环从输入流读取
                    // buffer字节
                    fos.write(buffer, 0, byteCount);// 将读取的输入流写入到输出流
                }
                fos.flush();// 刷新缓冲区
                is.close();
                fos.close();
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            try {
                if (is != null) {
                    is.close();
                }
                if (fos != null) {
                    fos.close();
                }
            } catch (IOException e) {
                e.printStackTrace();
            }

        }
    }

    /**
     * @param path
     * @return 返回类型：boolean
     * @Method: deleteLocalFile
     * @Description: 删除当前的文件
     */
    public static boolean deleteLocalFile(String path) {

        File file = new File(path);
        if (file.exists()) {
            file.delete();
        }

        return true;
    }

    /**
     * 根据文件路径获取json配置string
     *
     * @param filePath 配置文件的绝对路径
     * @return
     */
    public static String getJsonFromFile(String filePath) {
        //获取json数据
        String configJsonStr = "";
        String tempString;
        BufferedReader bufferedReader = null;
        try {
            FileInputStream fileInputStream = new FileInputStream(filePath);
            bufferedReader = new BufferedReader(new InputStreamReader(fileInputStream));
            while ((tempString = bufferedReader.readLine()) != null) {
                configJsonStr += tempString;
            }
            bufferedReader.close();
        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            if (bufferedReader != null) {
                try {
                    bufferedReader.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }
        return configJsonStr;
    }

}
