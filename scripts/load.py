"""Send bounded concurrent HTTP requests to the application through Minikube."""
import concurrent.futures
import sys
import time
from urllib.parse import urlencode
from urllib.request import Request, urlopen

duration = int(sys.argv[2]) if len(sys.argv) > 2 else 180
url = sys.argv[1].rstrip("/") + "/api/sentiment?" + urlencode({"text": "excellent " * 100})
deadline = time.monotonic() + duration

def worker():
    counts = {}
    errors = 0
    while time.monotonic() < deadline:
        try:
            with urlopen(Request(url, headers={"Host": "sentiment.local"}), timeout=4) as response:
                response.read()
                pod = response.headers.get("X-Served-By", "unknown")
                counts[pod] = counts.get(pod, 0) + 1
        except OSError:
            errors += 1
            time.sleep(0.1)
    return counts, errors

with concurrent.futures.ThreadPoolExecutor(max_workers=16) as executor:
    totals = {}
    failures = 0
    for counts, errors in executor.map(lambda _: worker(), range(16)):
        for pod, count in counts.items():
            totals[pod] = totals.get(pod, 0) + count
        failures += errors

for pod, count in sorted(totals.items()):
    print(f"{pod}: {count}")
print(f"HTTP successes: {sum(totals.values())}, errors: {failures}")
sys.exit(not totals)
