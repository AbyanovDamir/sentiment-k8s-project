package lab;

import java.util.Locale;
import java.util.Set;
import java.util.regex.Pattern;
import org.springframework.stereotype.Service;

@Service
public class SentimentService {
    private static final Pattern WORD = Pattern.compile("[\\p{L}]+");
    private static final Set<String> POSITIVE = Set.of(
        "hello", "good", "great", "love", "excellent", "happy", "wonderful",
        "привет", "хорошо", "отлично", "супер", "нравится", "прекрасно");
    private static final Set<String> NEGATIVE = Set.of(
        "bad", "hate", "terrible", "awful", "sad", "horrible",
        "плохо", "ужас", "ужасно", "ненавижу", "грустно", "кошмар");

    public String classify(String text) {
        int score = 0;
        var words = WORD.matcher(text.toLowerCase(Locale.ROOT));
        while (words.find()) {
            String word = words.group();
            if (POSITIVE.contains(word)) {
                score++;
            } else if (NEGATIVE.contains(word)) {
                score--;
            }
        }

        return score > 0 ? "positive" : score < 0 ? "negative" : "neutral";
    }
}
