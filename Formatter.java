import java.util.*;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.io.*;

public class Formatter {

    private static final ArrayList<String> list_of_bad_words = new ArrayList<String>() {
        static final long serialVersionUID = 1L;
        {
            try {
                BufferedReader br = new BufferedReader(new FileReader(".\\resources\\bad_words.txt"));
                String line;
                while ((line = br.readLine()) != null) {
                    add(line);
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
                BufferedReader br = new BufferedReader(new FileReader(".\\resources\\good_words.txt"));
                String line;
                while ((line = br.readLine()) != null) {
                    add(line);
                }
                br.close();
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    };

    public static void main(String[] args) {
        String file_path = "H:\\Repository\\gob-al\\Objects\\OrderConfirmationReport.al"; // File Path
        File file = new File(file_path);
        try (BufferedReader br = new BufferedReader(new FileReader(file))) {
            StringBuffer inputBuffer = new StringBuffer();
            String line;
            boolean bad_word_found = false;
            while ((line = br.readLine()) != null) {
                inputBuffer.append(line);
                inputBuffer.append('\n');
            }
            br.close();
            String inputStr = inputBuffer.toString();
            for (String bad_word : list_of_bad_words) {
                if (inputStr.contains(bad_word)) {
                    bad_word_found = true;
                    for (String good_word : list_of_correct_words) {
                        if (bad_word.equalsIgnoreCase(good_word)) {
                            inputStr = inputStr.replace(bad_word, good_word);
                        }
                    }
                }
            }
            if (bad_word_found) {
                FileOutputStream fileOut = new FileOutputStream(file_path);
                fileOut.write(inputStr.getBytes());
                fileOut.close();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}