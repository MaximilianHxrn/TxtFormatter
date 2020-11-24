import java.io.BufferedReader;
import java.io.File;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
//import java.util.Scanner;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class Formatter {

    private static BufferedReader br;

    private static final ArrayList<String> list_of_bad_words = new ArrayList<String>() {
        static final long serialVersionUID = 1L;
        {
            try {
                br = new BufferedReader(new FileReader(".\\resources\\bad_words.txt"));
                String line;
                while ((line = br.readLine()) != null) {
                    if (!line.contains("#")) {
                        add(line);
                    }
                }
                br.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    };

    private static final ArrayList<String> list_of_correct_words = new ArrayList<String>() {
        static final long serialVersionUID = 1L;
        {
            try {
                br = new BufferedReader(new FileReader(".\\resources\\good_words.txt"));
                String line;
                while ((line = br.readLine()) != null) {
                    if (!line.contains("#")) {
                        add(line);
                    }
                }
                br.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    };

    private static final ArrayList<String> list_of_function_names = new ArrayList<String>() {
        static final long serialVersionUID = 1L;
        {
            try {
                br = new BufferedReader(new FileReader(".\\resources\\function_names.txt"));
                String line;
                while ((line = br.readLine()) != null) {
                    if (!line.contains("#")) {
                        add(line);
                    }
                }
                br.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    };

    public static void main(String[] args) {
        // Copied from:
        // https://stackoverflow.com/questions/3154488/how-do-i-iterate-through-the-files-in-a-directory-in-java
        File[] directoryListing = new File(args[0]).listFiles();
        long startTime = 0L;
        if (directoryListing != null) {
            // Copied from:
            // https://stackoverflow.com/questions/3382954/measure-execution-time-for-a-java-method
            startTime = System.currentTimeMillis();
            for (File child : directoryListing) {
                if (child.isDirectory()) {
                    for (File file : child.listFiles()) {
                        if (!getExtension(file).equals(".rdl")) {
                            processFile(file);
                        }
                    }
                }
                processFile(child);
            }
        }
        System.out.println("\nExecution-Time: " + ((System.currentTimeMillis() - startTime) / 1000) + " seconds");
    }

    // Copied from:
    // https://stackoverflow.com/questions/3571223/how-do-i-get-the-file-extension-of-a-file-in-java
    private static String getExtension(File file) {
        String extension = "";
        String fileName = file.getName();
        int i = fileName.lastIndexOf('.');
        int p = Math.max(fileName.lastIndexOf('/'), fileName.lastIndexOf('\\'));
        if (i > p) {
            extension = fileName.substring(i + 1);
        }
        return extension;
    }

    private static void processFile(File file) {
        boolean bad_word_found = false;
        try {
            br = new BufferedReader(new FileReader(file));
            StringBuffer inputBuffer = new StringBuffer();
            String line;
            while ((line = br.readLine()) != null) {
                inputBuffer.append(line);
                inputBuffer.append('\n');
            }
            if (inputBuffer.length() > 0) {
                inputBuffer.deleteCharAt(inputBuffer.length() - 1);
            }
            br.close();
            String inputStr = inputBuffer.toString();
            for (String bad_word : list_of_bad_words) {
                if (inputStr.contains(bad_word)) {
                    for (String good_word : list_of_correct_words) {
                        if (bad_word.equalsIgnoreCase(good_word)) {
                            bad_word_found = true;
                            inputStr = inputStr.replace(bad_word, good_word);
                        }
                    }
                }
            }
            for (String function_name : list_of_function_names) {
                Pattern pattern = Pattern.compile(function_name + ";");
                Matcher matcher = pattern.matcher(inputStr);
                if (matcher.find()) {
                    for (String good_word : list_of_correct_words) {
                        if (function_name.equalsIgnoreCase(good_word)) {
                            inputStr = inputStr.replace(function_name + ";", good_word + "();");
                        }
                    }
                }
            }
            // Copied from:
            // https://stackoverflow.com/questions/632204/java-string-replace-using-regular-expressions
            // https://stackoverflow.com/questions/16866077/regex-using-java-string-replaceall
            inputStr = Pattern.compile("\\)\n\\s*\\{\n\\s*\\}").matcher(inputStr).replaceAll(") { }");
            if (bad_word_found) {
                FileOutputStream fileOut = new FileOutputStream(file.getAbsolutePath());
                fileOut.write(inputStr.getBytes());
                fileOut.close();
            }
        } catch (IOException e) {
            return;
        }
    }
}