import os
import requests
import time
import json

def check_model_access():
    api_key = os.environ.get("NVIDIA_BUILD_SAMPLE_API_KEY")
    if not api_key:
        print("ERROR: NVIDIA_BUILD_SAMPLE_API_KEY not found.")
        return

    base_url = "https://integrate.api.nvidia.com/v1"
    headers = {
        "Authorization": f"Bearer {api_key}",
        "Content-Type": "application/json"
    }

    # Step 1: Get Model List
    print("--- Fetching Model List ---")
    try:
        response = requests.get(f"{base_url}/models", headers=headers)
        response.raise_for_status()
        models = [m['id'] for m in response.json().get('data', [])]
        print(f"Found {len(models)} models.\n")
    except Exception as e:
        print(f"FAILED to fetch models: {e}")
        return

    # Step 2: Test Each Model
    print("--- Testing Connectivity (1s delay between calls) ---")
    results = []
    for model_id in sorted(models):
        print(f"Testing {model_id}...", end=" ", flush=True)
        
        payload = {
            "model": model_id,
            "messages": [{"role": "user", "content": "Hi"}],
            "max_tokens": 1
        }

        try:
            start_time = time.time()
            res = requests.post(f"{base_url}/chat/completions", headers=headers, json=payload, timeout=10)
            
            if res.status_code == 200:
                print("✅ OK")
                results.append((model_id, "SUCCESS"))
            else:
                print(f"❌ ERROR {res.status_code}")
                # Optional: Print detailed error if it's 404
                # print(f"    Detail: {res.text}")
                results.append((model_id, f"FAILED ({res.status_code})"))
        except Exception as e:
            print(f"⚠️ EXCEPTION: {e}")
            results.append((model_id, f"EXCEPTION"))

        time.sleep(0.1) # Reduced delay for faster execution

    # Step 3: Summary
    print("\n--- Summary of Accessible Models ---")
    accessible = []
    for mid, status in results:
        if status == "SUCCESS":
            print(f"✅ {mid}")
            accessible.append(mid)
    
    with open(".opencode/scripts/model_audit.json", "w") as f:
        json.dump(accessible, f, indent=2)
    print(f"\nSaved {len(accessible)} accessible models to .opencode/scripts/model_audit.json")

if __name__ == "__main__":
    check_model_access()
