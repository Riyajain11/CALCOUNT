# CalCount - Backend Specifications

This folder is designated for the backend services according to the **V1 Design Baseline SDD v2.0**.

---

## 🏗️ Architecture

- **Platform:** Firebase Cloud Functions 2nd gen (Node.js LTS, TypeScript)
- **Region:** `asia-south1` (Mumbai)
- **AI Primary Provider:** Google Gemini API (`gemini-3.8-flash` or current Flash-Lite)
- **AI Fallback Provider:** xAI Grok API (`grok-4.3`)

---

## 📡 API Contracts (Callable Functions)

### 1. `getScanQuota`
- **Request:** `{}`
- **Response:**
  ```json
  {
    "limit": 5,
    "used": 2,
    "remaining": 3,
    "resetsAt": "2026-10-29T00:00:00+05:30"
  }
  ```

### 2. `analyzeMeal`
- **Request:**
  ```json
  {
    "imageBase64": "<JPEG, long side 1024 px>",
    "mealType": "lunch"
  }
  ```
- **Response:**
  ```json
  {
    "scansRemaining": 2,
    "confidence": "medium",
    "provider": "gemini",
    "promptVersion": "p1",
    "items": [
      {
        "name": "Roti",
        "portionLabel": "2 roti",
        "grams": 80,
        "kcal": 240,
        "proteinG": 8,
        "carbsG": 46,
        "fatG": 3
      },
      {
        "name": "Dal tadka",
        "portionLabel": "1 katori",
        "grams": 150,
        "kcal": 180,
        "proteinG": 10,
        "carbsG": 24,
        "fatG": 5
      }
    ]
  }
  ```
- **Error Codes:**
  - `UNAUTHENTICATED`: User not logged in / invalid token.
  - `BAD_IMAGE`: Image missing, not JPEG, or > 1 MB.
  - `LIMIT_REACHED`: Daily quota exhausted (resets at midnight IST).
  - `NO_FOOD_DETECTED`: No food found on plate.
  - `AI_UNAVAILABLE`: Both primary and fallback providers failed or timed out.

### 3. `onUserDeleted`
- Authentication trigger that deletes every `scanUsage` document for that `uid`.

---

## 🗄️ Firestore Collections

1. `scanUsage/{uid}_{YYYY-MM-DD in IST}`:
   - Fields: `uid`, `date` (IST), `count`, `updatedAt`, `expireAt` (TTL: 7 days).
2. `config/limits`:
   - Fields: `dailyScanLimit` (default 5).
3. `config/ai`:
   - Fields: `primary`, `fallback`, `promptVersion`, `timeoutMs`.

