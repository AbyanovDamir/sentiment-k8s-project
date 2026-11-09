package lab;

import java.util.Map;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class SentimentHandler {
    private final SentimentService service;

    public SentimentHandler(SentimentService service) {
        this.service = service;
    }

    @GetMapping("/api/sentiment")
    public ResponseEntity<Map<String, String>> sentiment(@RequestParam String text) {
        if (text.isBlank() || text.length() > 4096) {
            return ResponseEntity.badRequest().body(Map.of("error", "Use 1 to 4096 characters"));
        }

        String result = service.classify(text);
        return ResponseEntity.ok()
            .header("X-Served-By", System.getenv().getOrDefault("HOSTNAME", "local"))
            .body(Map.of("sentiment", result));
    }
}
